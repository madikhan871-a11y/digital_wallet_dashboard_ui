import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/ride.dart';

class DriverCard extends StatelessWidget {
  final Ride ride;

  const DriverCard({
    super.key,
    required this.ride,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: AppColors.yellow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.background,
              size: 27,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  ride.driverName,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ride.carName} • ${ride.carNumber}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          _circleButton(
            Icons.call_rounded,
            AppColors.green,
          ),
          const SizedBox(width: 8),
          _circleButton(
            Icons.chat_bubble_outline_rounded,
            AppColors.yellow,
          ),
        ],
      ),
    );
  }

  Widget _circleButton(
      IconData icon,
      Color color,
      ) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 17,
      ),
    );
  }
}