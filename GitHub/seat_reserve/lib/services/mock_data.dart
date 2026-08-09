import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/seat_model.dart';
import '../models/reservation_model.dart';
import '../models/app_settings_model.dart';

class MockData {
  static final AppSettingsModel defaultSettings = AppSettingsModel(
    totalSeats: 30,
    noShowFine: 200.0,
    reservationDeadline: const TimeOfDay(hour: 10, minute: 0),
    attendanceCutoff: const TimeOfDay(hour: 12, minute: 0),
    cancellationDeadline: const TimeOfDay(hour: 9, minute: 0),
  );

  static List<UserModel> get initialUsers => [
    UserModel(
      id: 'admin_primary',
      name: 'Teacher Admin',
      email: 'admin123@gmail.com',
      phone: '1234567890',
      role: UserRole.admin,
      status: UserStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    UserModel(
      id: 'student_sarah',
      name: 'Sarah Jenkins',
      email: 'sarah.j@tech.edu',
      phone: '0987654321',
      role: UserRole.student,
      status: UserStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
  ];

  static List<SeatModel> generateSeats(int count) {
    return List.generate(count, (index) {
      final int seatId = index + 1;
      final String seatNumber = 'S-${seatId.toString().padLeft(2, '0')}';

      String zone = 'Main Lab';
      if (seatId > 20) {
        zone = 'Quiet Zone';
      } else if (seatId > 10) {
        zone = 'Collab Space';
      }

      return SeatModel(
        id: seatId,
        seatNumber: seatNumber,
        isActive: true,
        zone: zone,
      );
    });
  }

  static List<ReservationModel> getInitialReservations(DateTime today) {
    return [
      ReservationModel(
        id: 'res_mock_1',
        studentId: 'student_sarah',
        studentName: 'Sarah Jenkins',
        seatId: 12,
        seatNumber: 'S-12',
        reservationDate: today,
        status: ReservationStatus.checked_in,
        createdAt: today.subtract(const Duration(hours: 1)),
        checkInTime: today.subtract(const Duration(minutes: 30)),
      ),
    ];
  }
}
