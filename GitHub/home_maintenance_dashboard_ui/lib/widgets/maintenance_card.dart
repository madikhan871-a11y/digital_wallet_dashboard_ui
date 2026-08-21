import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/maintenance.dart';

class MaintenanceCard extends StatelessWidget {
  final Maintenance item;

  const MaintenanceCard({
    super.key,
    required this.item,
  });

  IconData _getIcon() {
    switch (item.type) {
      case 'ac':
        return Icons.ac_unit_rounded;
      case 'water':
        return Icons.water_drop_outlined;
      case 'electric':
        return Icons.bolt_rounded;
      case 'cleaning':
        return Icons.cleaning_services_outlined;
      default:
        return Icons.home_repair_service_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor =
    item.urgent ? AppColors.red : AppColors.green;

    final iconBackground =
    item.urgent ? AppColors.lightRed : AppColors.lightGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _getIcon(),
              color: iconColor,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${item.location} • ${item.date}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.cost,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}