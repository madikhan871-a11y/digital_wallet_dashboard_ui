import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings_model.dart';
import '../models/reservation_model.dart';
import '../models/seat_model.dart';
import '../models/user_model.dart';

class StorageService {
  static const String _settingsKey = 'app_settings';
  static const String _usersKey = 'users';
  static const String _seatsKey = 'seats';
  static const String _reservationsKey = 'reservations';
  static const String _currentUserKey = 'current_user';

  SharedPreferences? _prefs;

  // ------------------------------------------------------------
  // INITIALIZATION
  // ------------------------------------------------------------

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> get _preferences async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ------------------------------------------------------------
  // SETTINGS
  // ------------------------------------------------------------

  Future<AppSettingsModel> loadSettings() async {
    final prefs = await _preferences;
    final data = prefs.getString(_settingsKey);

    if (data == null || data.isEmpty) {
      return AppSettingsModel(
        totalSeats: 20,
        noShowFine: 200.0,
        reservationDeadline: const TimeOfDay(hour: 10, minute: 0),
        attendanceCutoff: const TimeOfDay(hour: 12, minute: 0),
        cancellationDeadline: const TimeOfDay(hour: 9, minute: 0),
      );
    }

    try {
      final map = jsonDecode(data) as Map<String, dynamic>;
      return AppSettingsModel.fromMap(map);
    } catch (_) {
      return AppSettingsModel(
        totalSeats: 20,
        noShowFine: 200.0,
        reservationDeadline: const TimeOfDay(hour: 10, minute: 0),
        attendanceCutoff: const TimeOfDay(hour: 12, minute: 0),
        cancellationDeadline: const TimeOfDay(hour: 9, minute: 0),
      );
    }
  }

  Future<void> saveSettings(AppSettingsModel settings) async {
    final prefs = await _preferences;
    await prefs.setString(
      _settingsKey,
      jsonEncode(settings.toMap()),
    );
  }

  // ------------------------------------------------------------
  // USERS
  // ------------------------------------------------------------

  Future<List<UserModel>> loadUsers() async {
    final prefs = await _preferences;
    final data = prefs.getString(_usersKey);

    if (data == null || data.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded
          .map(
            (item) => UserModel.fromMap(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveUsers(List<UserModel> users) async {
    final prefs = await _preferences;
    final data = users.map((user) => user.toMap()).toList();
    await prefs.setString(
      _usersKey,
      jsonEncode(data),
    );
  }

  // ------------------------------------------------------------
  // SEATS
  // ------------------------------------------------------------

  Future<List<SeatModel>> loadSeats(int totalSeats) async {
    final prefs = await _preferences;
    final data = prefs.getString(_seatsKey);

    if (data == null || data.isEmpty) {
      return _generateDefaultSeats(totalSeats);
    }

    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded
          .map(
            (item) => SeatModel.fromMap(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } catch (_) {
      return _generateDefaultSeats(totalSeats);
    }
  }

  Future<void> saveSeats(List<SeatModel> seats) async {
    final prefs = await _preferences;
    final data = seats.map((seat) => seat.toMap()).toList();
    await prefs.setString(
      _seatsKey,
      jsonEncode(data),
    );
  }

  List<SeatModel> _generateDefaultSeats(int count) {
    return List.generate(
      count,
          (index) {
        final seatId = index + 1;
        String zone = 'Main Lab, 1st Floor';
        if (seatId > 15) {
          zone = 'Quiet Zone, 3rd Floor';
        } else if (seatId > 10) {
          zone = 'Collab Space, 2nd Floor';
        }
        return SeatModel(
          id: seatId,
          seatNumber: 'Seat $seatId',
          isActive: true,
          zone: zone,
        );
      },
    );
  }

  // ------------------------------------------------------------
  // RESERVATIONS
  // ------------------------------------------------------------

  Future<List<ReservationModel>> loadReservations() async {
    final prefs = await _preferences;
    final data = prefs.getString(_reservationsKey);

    if (data == null || data.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded
          .map(
            (item) => ReservationModel.fromMap(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveReservations(List<ReservationModel> reservations) async {
    final prefs = await _preferences;
    final data = reservations.map((reservation) => reservation.toMap()).toList();
    await prefs.setString(
      _reservationsKey,
      jsonEncode(data),
    );
  }

  // ------------------------------------------------------------
  // CURRENT USER
  // ------------------------------------------------------------

  Future<UserModel?> loadCurrentUser() async {
    final prefs = await _preferences;
    final data = prefs.getString(_currentUserKey);

    if (data == null || data.isEmpty) {
      return null;
    }

    try {
      final map = jsonDecode(data) as Map<String, dynamic>;
      return UserModel.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCurrentUser(UserModel user) async {
    final prefs = await _preferences;
    await prefs.setString(
      _currentUserKey,
      jsonEncode(user.toMap()),
    );
  }

  Future<void> clearCurrentUser() async {
    final prefs = await _preferences;
    await prefs.remove(_currentUserKey);
  }

  // ------------------------------------------------------------
  // CLEAR ALL LOCAL DATA
  // ------------------------------------------------------------

  Future<void> clearAll() async {
    final prefs = await _preferences;
    await prefs.remove(_settingsKey);
    await prefs.remove(_usersKey);
    await prefs.remove(_seatsKey);
    await prefs.remove(_reservationsKey);
    await prefs.remove(_currentUserKey);
  }
}
