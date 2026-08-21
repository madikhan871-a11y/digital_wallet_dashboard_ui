import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/ride.dart';

class LocationCard extends StatelessWidget {
  final Ride ride;

  const LocationCard({
    super.key,
    required this.ride,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          _locationRow(
            color: AppColors.yellow,
            icon: Icons.my_location_rounded,
            title: 'Pickup',
            value: ride.pickup,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 8,
              top: 5,
              bottom: 5,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 1,
                height: 17,
                color: AppColors.border,
              ),
            ),
          ),
          _locationRow(
            color: AppColors.red,
            icon: Icons.location_on_rounded,
            title: 'Destination',
            value: ride.destination,
          ),
        ],
      ),
    );
  }

  Widget _locationRow({
    required Color color,
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 17,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 8,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}