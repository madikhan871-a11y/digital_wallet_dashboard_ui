import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../models/app_settings_model.dart';
import '../models/fine_model.dart';
import '../models/notification_model.dart';
import '../models/reservation_model.dart';
import '../models/seat_model.dart';
import '../models/user_model.dart';

class AppProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  UserModel? _currentUser;
  AppSettingsModel _settings = AppSettingsModel(
    totalSeats: 30,
    reservationDeadline: const TimeOfDay(hour: 10, minute: 0),
    attendanceCutoff: const TimeOfDay(hour: 12, minute: 0),
    cancellationDeadline: const TimeOfDay(hour: 9, minute: 0),
    noShowFine: 200.0,
  );
  List<UserModel> _users = [];
  List<SeatModel> _seats = [];
  List<ReservationModel> _reservations = [];
  List<FineModel> _fines = [];
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  Timer? _countdownTimer;
  Duration _timeUntilDeadline = Duration.zero;

  UserModel? get currentUser => _currentUser;
  AppSettingsModel get settings => _settings;
  List<UserModel> get users => List.unmodifiable(_users);
  List<SeatModel> get seats => List.unmodifiable(_seats);
  List<ReservationModel> get reservations => List.unmodifiable(_reservations);
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  List<FineModel> get fines => List.unmodifiable(_fines);
  bool get isLoading => _isLoading;
  Duration get timeUntilDeadline => _timeUntilDeadline;

  // --- Metrics for Dashboard & Reports ---
  List<UserModel> get pendingStudents => _users.where((u) => u.status == UserStatus.pending && u.role == UserRole.student).toList();
  String get todayDateString => DateFormat('yyyy-MM-dd').format(DateTime.now());
  
  List<ReservationModel> get todayReservations => _reservations.where((r) => 
    DateFormat('yyyy-MM-dd').format(r.reservationDate) == todayDateString && r.status != ReservationStatus.cancelled
  ).toList();

  int get occupiedSeatsCount => todayReservations.where((r) => r.status == ReservationStatus.checked_in || r.status == ReservationStatus.reserved).length;
  int get activeSeatsCount => _seats.where((s) => s.isActive).length;
  int get availableSeatsCount => (activeSeatsCount - occupiedSeatsCount).clamp(0, activeSeatsCount);
  double get occupancyPercentage => activeSeatsCount == 0 ? 0.0 : (occupiedSeatsCount / activeSeatsCount);
  int get presentTodayCount => todayReservations.where((r) => r.status == ReservationStatus.checked_in).length;
  int get absentTodayCount => todayReservations.where((r) => r.status == ReservationStatus.absent).length;
  int get expectedTodayCount => todayReservations.length;
  double get totalUnpaidFinesAmount => _fines.where((f) => f.status == FineStatus.unpaid).fold(0.0, (sum, f) => sum + f.amount);
  
  bool get hasUserReservedToday {
    if (_currentUser == null) return false;
    return todayReservations.any((r) => r.studentId == _currentUser!.id);
  }

  bool get isPastDeadline {
    final now = TimeOfDay.fromDateTime(DateTime.now());
    final dl = _settings.reservationDeadline;
    return (now.hour * 60 + now.minute) >= (dl.hour * 60 + dl.minute);
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _supabase.auth.onAuthStateChange.listen((data) async {
      if (data.event == AuthChangeEvent.signedIn) {
        await _loadUserData(data.session!.user.id);
      } else if (data.event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        _clearData();
        notifyListeners();
      }
    });

    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _loadUserData(session.user.id);
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateDeadlineTimer());
    _isLoading = false;
    notifyListeners();
  }

  void _clearData() {
    _users = []; _seats = []; _reservations = []; _fines = []; _notifications = [];
  }

  Future<void> _loadUserData(String userId) async {
    try {
      final profileData = await _supabase.from('profiles').select().eq('id', userId).single();
      _currentUser = UserModel.fromMap(profileData);
      await refreshData();
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  Future<void> refreshData() async {
    if (_currentUser == null) return;
    try {
      final results = await Future.wait([
        _supabase.from('system_settings').select().eq('id', 1).maybeSingle(),
        _supabase.from('seats').select().order('seat_number'),
        _supabase.from('reservations').select('*, profiles(full_name), seats(seat_number)').order('reservation_date', ascending: false),
        _supabase.from('fines').select('*, profiles(full_name)').order('created_at', ascending: false),
        _supabase.from('notifications').select().eq('user_id', _currentUser!.id).order('created_at', ascending: false),
        if (_currentUser!.role == UserRole.admin) _supabase.from('profiles').select().order('created_at', ascending: false),
      ]);

      if (results[0] != null) _settings = AppSettingsModel.fromMap(results[0] as Map<String, dynamic>);
      _seats = (results[1] as List).map((d) => SeatModel.fromMap(d)).toList();
      _reservations = (results[2] as List).map((d) => ReservationModel.fromMap(d)).toList();
      _fines = (results[3] as List).map((d) => FineModel.fromMap(d)).toList();
      _notifications = (results[4] as List).map((d) => NotificationModel.fromMap(d)).toList();
      if (_currentUser!.role == UserRole.admin) {
        _users = (results[5] as List).map((d) => UserModel.fromMap(d)).toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Refresh error: $e');
    }
  }

  void _updateDeadlineTimer() {
    final now = DateTime.now();
    DateTime target = DateTime(now.year, now.month, now.day, _settings.reservationDeadline.hour, _settings.reservationDeadline.minute);
    if (now.isAfter(target)) target = target.add(const Duration(days: 1));
    _timeUntilDeadline = target.difference(now);
    notifyListeners();
  }

  // --- Auth & Admin Actions ---

  Future<String?> registerStudent({
    required String fullName,
    required String email,
    required String password,
    String phone = '',
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );

      final user = response.user;

      if (user == null) {
        return 'Registration failed. Please try again.';
      }

      await _supabase.from('profiles').insert({
        'id': user.id,
        'full_name': fullName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'role': 'student',
        'approval_status': 'pending',
      });

      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Registration failed: $e';
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        final profile = await _supabase
            .from('profiles')
            .select()
            .eq('id', res.user!.id)
            .single();

        final user = UserModel.fromMap(profile);

        if (user.role == UserRole.student &&
            user.status == UserStatus.pending) {
          await logout();
          return "Account pending approval.";
        }

        return null;
      }

      return "Login failed";
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async => await _supabase.auth.signOut();



  Future<void> approveStudent(String id) async {
    await _supabase.from('profiles').update({'approval_status': 'approved'}).eq('id', id);
    await _supabase.from('notifications').insert({'user_id': id, 'title': 'Approved', 'message': 'You can now book seats.'});
    await refreshData();
  }

  Future<void> rejectStudent(String id) async {
    await _supabase.from('profiles').update({'approval_status': 'rejected'}).eq('id', id);
    await refreshData();
  }

  Future<void> markCheckedIn(String id) async {
    await _supabase.from('reservations').update({'status': 'checked_in', 'check_in_time': DateTime.now().toIso8601String()}).eq('id', id);
    await refreshData();
  }

  Future<void> markAbsent(String id) async {
    await _supabase.from('reservations').update({'status': 'absent'}).eq('id', id);
    final res = _reservations.firstWhere((r) => r.id == id);
    await _supabase.from('fines').insert({'student_id': res.studentId, 'reservation_id': id, 'amount': _settings.noShowFine, 'reason': 'No-show'});
    await refreshData();
  }

  Future<String?> updateSettings(AppSettingsModel newSettings) async {
    try {
      await _supabase
          .from('system_settings')
          .upsert({
        ...newSettings.toMap(),
        'id': 1,
      });

      await refreshData();
      return null;
    } catch (e) {
      debugPrint('Update settings error: $e');
      return e.toString();
    }
  }

  Future<String?> addSeat(String number, [String zone = 'Main Lab']) async {
    try {
      await _supabase.from('seats').insert({'seat_number': number, 'zone': zone});
      await refreshData(); return null;
    } catch (e) { return e.toString(); }
  }

  Future<void> toggleSeatStatus(int id, bool isActive) async {
    await _supabase.from('seats').update({'is_active': isActive}).eq('id', id);
    await refreshData();
  }

  Future<String?> deleteSeat(int id) async {
    try {
      await _supabase.from('seats').delete().eq('id', id);
      await refreshData(); return null;
    } catch (e) { return "Cannot delete seat with reservation history."; }
  }

  Future<void> markFinePaid(String id) async {
    await _supabase.from('fines').update({'status': 'paid', 'paid_at': DateTime.now().toIso8601String()}).eq('id', id);
    await refreshData();
  }

  Future<void> waiveFine(String id) async {
    await _supabase.from('fines').update({'status': 'waived'}).eq('id', id);
    await refreshData();
  }

  Future<void> broadcastNotice(String title, String msg) async {
    final ids = _users.where((u) => u.role == UserRole.student && u.status == UserStatus.approved).map((u) => u.id).toList();
    if (ids.isEmpty) return;
    final inserts = ids.map((id) => {'user_id': id, 'title': title, 'message': msg}).toList();
    await _supabase.from('notifications').insert(inserts);
  }

  Future<String?> reserveSeat(SeatModel seat) async {
    if (_currentUser == null) {
      return 'Please login again.';
    }

    if (_currentUser!.role != UserRole.student) {
      return 'Only students can reserve seats.';
    }

    if (_currentUser!.status != UserStatus.approved) {
      return 'Your account is not approved yet.';
    }

    if (isPastDeadline) {
      return 'Booking deadline has passed.';
    }

    if (hasUserReservedToday) {
      return 'You have already reserved a seat today.';
    }

    final alreadyBooked = todayReservations.any(
          (reservation) => reservation.seatId == seat.id,
    );

    if (alreadyBooked) {
      return 'This seat has already been reserved today.';
    }

    try {
      await _supabase.from('reservations').insert({
        'student_id': _currentUser!.id,
        'seat_id': seat.id,
        'reservation_date': todayDateString,
        'status': 'reserved',
      });

      await _supabase.from('notifications').insert({
        'user_id': _currentUser!.id,
        'title': 'Seat Reserved',
        'message': 'Seat ${seat.seatNumber} has been reserved successfully.',
        'type': 'reservation_confirmed',
        'is_read': false,
      });

      await refreshData();

      return null;
    } on PostgrestException catch (e) {
      debugPrint('Reservation Supabase Error: ${e.message}');
      debugPrint('Details: ${e.details}');
      debugPrint('Hint: ${e.hint}');
      return e.message;
    } catch (e) {
      debugPrint('Reservation Error: $e');
      return 'Booking failed: $e';
    }
  }

  Future<String?> cancelReservation(String id) async {
    await _supabase
        .from('reservations')
        .update({'status': 'cancelled'})
        .eq('id', id);

    await refreshData();
    return null;
  }


// Mark ONE notification as read
  Future<void> markNotificationAsRead(int id) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id);

      await refreshData();
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

// Mark ALL notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      if (_currentUser == null) return;

      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', _currentUser!.id);

      await refreshData();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
