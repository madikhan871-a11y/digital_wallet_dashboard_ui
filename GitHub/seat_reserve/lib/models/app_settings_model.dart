import 'package:flutter/material.dart';

class AppSettingsModel {
  final int totalSeats;
  final double noShowFine;
  final TimeOfDay reservationDeadline;
  final TimeOfDay attendanceCutoff;
  final TimeOfDay cancellationDeadline;

  AppSettingsModel({
    required this.totalSeats,
    required this.noShowFine,
    required this.reservationDeadline,
    required this.attendanceCutoff,
    required this.cancellationDeadline,
  });

  AppSettingsModel copyWith({
    int? totalSeats,
    double? noShowFine,
    TimeOfDay? reservationDeadline,
    TimeOfDay? attendanceCutoff,
    TimeOfDay? cancellationDeadline,
  }) {
    return AppSettingsModel(
      totalSeats: totalSeats ?? this.totalSeats,
      noShowFine: noShowFine ?? this.noShowFine,
      reservationDeadline: reservationDeadline ?? this.reservationDeadline,
      attendanceCutoff: attendanceCutoff ?? this.attendanceCutoff,
      cancellationDeadline: cancellationDeadline ?? this.cancellationDeadline,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalSeats': totalSeats,
      'noShowFine': noShowFine,
      'reservationDeadlineHour': reservationDeadline.hour,
      'reservationDeadlineMinute': reservationDeadline.minute,
      'attendanceCutoffHour': attendanceCutoff.hour,
      'attendanceCutoffMinute': attendanceCutoff.minute,
      'cancellationDeadlineHour': cancellationDeadline.hour,
      'cancellationDeadlineMinute': cancellationDeadline.minute,
    };
  }

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      totalSeats: map['totalSeats'] as int? ?? 20,
      noShowFine: (map['noShowFine'] as num?)?.toDouble() ?? 200.0,
      reservationDeadline: TimeOfDay(
        hour: map['reservationDeadlineHour'] as int? ?? 10,
        minute: map['reservationDeadlineMinute'] as int? ?? 0,
      ),
      attendanceCutoff: TimeOfDay(
        hour: map['attendanceCutoffHour'] as int? ?? 12,
        minute: map['attendanceCutoffMinute'] as int? ?? 0,
      ),
      cancellationDeadline: TimeOfDay(
        hour: map['cancellationDeadlineHour'] as int? ?? 9,
        minute: map['cancellationDeadlineMinute'] as int? ?? 0,
      ),
    );
  }
}