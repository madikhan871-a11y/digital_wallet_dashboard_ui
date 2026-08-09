class SeatModel {
  final int id;
  final String seatNumber;
  final bool isActive;
  final String zone;

  SeatModel({
    required this.id,
    required this.seatNumber,
    this.isActive = true,
    required this.zone,
  });

  SeatModel copyWith({
    int? id,
    String? seatNumber,
    bool? isActive,
    String? zone,
  }) {
    return SeatModel(
      id: id ?? this.id,
      seatNumber: seatNumber ?? this.seatNumber,
      isActive: isActive ?? this.isActive,
      zone: zone ?? this.zone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'seat_number': seatNumber,
      'is_active': isActive,
      'zone': zone,
    };
  }

  factory SeatModel.fromMap(Map<String, dynamic> map) {
    return SeatModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      seatNumber: map['seat_number']?.toString() ?? '',
      isActive: map['is_active'] as bool? ?? true,
      zone: map['zone']?.toString() ?? 'Main Lab',
    );
  }

  factory SeatModel.fromJson(Map<String, dynamic> json) => SeatModel.fromMap(json);
}
