enum FineStatus { unpaid, paid, waived }

class FineModel {
  final String id;
  final String studentId;
  final String? reservationId;
  final double amount;
  final String reason;
  final FineStatus status;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? studentName;

  FineModel({
    required this.id,
    required this.studentId,
    this.reservationId,
    required this.amount,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.paidAt,
    this.studentName,
  });

  factory FineModel.fromMap(Map<String, dynamic> map) {
    return FineModel(
      id: map['id']?.toString() ?? '',
      studentId: map['student_id']?.toString() ?? '',
      reservationId: map['reservation_id']?.toString(),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      reason: map['reason'] ?? '',
      status: FineStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => FineStatus.unpaid,
      ),
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      paidAt: map['paid_at'] != null ? DateTime.parse(map['paid_at']) : null,
      studentName: map['profiles']?['full_name'],
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'student_id': studentId,
    'reservation_id': reservationId,
    'amount': amount,
    'reason': reason,
    'status': status.name,
    'created_at': createdAt.toIso8601String(),
    'paid_at': paidAt?.toIso8601String(),
  };
}
