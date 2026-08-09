enum ReservationStatus {
  reserved,
  checked_in,
  missed,
  absent,
  cancelled,
}

class ReservationModel {
  final String id;
  final String studentId;
  final String studentName;
  final int seatId;
  final String seatNumber;
  final DateTime reservationDate;
  final ReservationStatus status;
  final DateTime createdAt;
  final DateTime? checkInTime;

  ReservationModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.seatId,
    required this.seatNumber,
    required this.reservationDate,
    required this.status,
    required this.createdAt,
    this.checkInTime,
  });

  ReservationModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    int? seatId,
    String? seatNumber,
    DateTime? reservationDate,
    ReservationStatus? status,
    DateTime? createdAt,
    DateTime? checkInTime,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      seatId: seatId ?? this.seatId,
      seatNumber: seatNumber ?? this.seatNumber,
      reservationDate: reservationDate ?? this.reservationDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      checkInTime: checkInTime ?? this.checkInTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'seat_id': seatId,
      'seat_number': seatNumber,
      'reservation_date': reservationDate.toIso8601String(),
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'check_in_time': checkInTime?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory ReservationModel.fromMap(Map<String, dynamic> map) {
    return ReservationModel(
      id: map['id']?.toString() ?? '',
      studentId: map['student_id']?.toString() ?? '',
      studentName: map['profiles']?['full_name'] ?? map['student_name'] ?? 'Unknown',
      seatId: (map['seat_id'] as num?)?.toInt() ?? 0,
      seatNumber: map['seats']?['seat_number'] ?? map['seat_number']?.toString() ?? 'N/A',
      reservationDate: map['reservation_date'] != null
          ? DateTime.parse(map['reservation_date'].toString())
          : DateTime.now(),
      status: ReservationStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => ReservationStatus.reserved,
      ),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
      checkInTime: map['check_in_time'] != null
          ? DateTime.parse(map['check_in_time'].toString())
          : null,
    );
  }

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel.fromMap(json);
  }
}
