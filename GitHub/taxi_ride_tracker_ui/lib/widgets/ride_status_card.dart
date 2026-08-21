import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/ride.dart';

class RideStatusCard extends StatelessWidget {
  final Ride ride;

  const RideStatusCard({
    super.key,
    required this.ride,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.yellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_taxi_rounded,
                  color: AppColors.background,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR RIDE',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 8,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Driver is on the way',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 125,
            decoration: BoxDecoration(
              color: const Color(0xFF20241F),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 22,
                  right: 22,
                  top: 61,
                  child: Container(
                    height: 2,
                    color: AppColors.border,
                  ),
                ),
                Positioned(
                  left: 35,
                  top: 53,
                  child: _mapPoint(
                    AppColors.yellow,
                    Icons.local_taxi_rounded,
                  ),
                ),
                Positioned(
                  right: 35,
                  top: 53,
                  child: _mapPoint(
                    AppColors.red,
                    Icons.location_on_rounded,
                  ),
                ),
                Positioned(
                  left: 75,
                  right: 75,
                  top: 59,
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _info(
                Icons.schedule_rounded,
                ride.eta,
                'ETA',
              ),
              const SizedBox(width: 10),
              _info(
                Icons.payments_outlined,
                ride.fare,
                'FARE',
              ),
              const SizedBox(width: 10),
              _info(
                Icons.navigation_rounded,
                '${(ride.progress * 100).round()}%',
                'TRIP',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mapPoint(Color color, IconData icon) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 12,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: AppColors.background,
        size: 15,
      ),
    );
  }

  Widget _info(
      IconData icon,
      String value,
      String label,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 11,
          horizontal: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.yellow,
              size: 15,
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}