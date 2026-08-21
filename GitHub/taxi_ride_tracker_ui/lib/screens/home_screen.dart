import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/ride.dart';
import '../widgets/driver_card.dart';
import '../widgets/location_card.dart';
import '../widgets/ride_status_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const ride = Ride(
    driverName: 'Ahmed Khan',
    carName: 'Toyota Corolla',
    carNumber: 'LEA-2847',
    pickup: 'Emporium Mall, Lahore',
    destination: 'Liberty Market, Lahore',
    eta: '04 min',
    fare: 'Rs. 680',
    progress: 0.68,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            18,
            18,
            18,
            25,
          ),
          children: [
            _header(),
            const SizedBox(height: 20),
            RideStatusCard(ride: ride),
            const SizedBox(height: 16),
            LocationCard(ride: ride),
            const SizedBox(height: 16),
            DriverCard(ride: ride),
            const SizedBox(height: 18),
            _fareBreakdown(),
            const SizedBox(height: 18),
            _cancelButton(context),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'Good evening 👋',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your Ride',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: const Icon(
            Icons.more_horiz_rounded,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _fareBreakdown() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                color: AppColors.yellow,
                size: 18,
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Fare estimate',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Text(
                'Rs. 680',
                style: TextStyle(
                  color: AppColors.yellow,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _fareRow('Base fare', 'Rs. 300'),
          const SizedBox(height: 8),
          _fareRow('Distance', 'Rs. 280'),
          const SizedBox(height: 8),
          _fareRow('Service fee', 'Rs. 100'),
        ],
      ),
    );
  }

  Widget _fareRow(String title, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _cancelButton(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ride cancellation requested'),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.red,
          side: const BorderSide(
            color: AppColors.red,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Cancel Ride',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}