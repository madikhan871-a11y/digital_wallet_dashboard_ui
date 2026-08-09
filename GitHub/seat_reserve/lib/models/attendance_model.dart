enum AttendanceStatus { checked_in, absent }

class AttendanceModel {
  final int id;
  final int reservationId;
  final String studentId;
  final DateTime attendanceDate;
  final AttendanceStatus status;
  final DateTime? checkInTime;
  final String? markedBy;
  final DateTime createdAt;

  AttendanceModel({
    required this.id,
    required this.reservationId,
    required this.studentId,
    required this.attendanceDate,
    required this.status,
    this.checkInTime,
    this.markedBy,
    required this.createdAt,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'],
      reservationId: map['reservation_id'],
      studentId: map['student_id'],
      attendanceDate: DateTime.parse(map['attendance_date']),
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AttendanceStatus.checked_in,
      ),
      checkInTime: map['check_in_time'] != null ? DateTime.parse(map['check_in_time']) : null,
      markedBy: map['marked_by'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
