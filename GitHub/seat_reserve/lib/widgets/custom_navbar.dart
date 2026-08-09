import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomNavbar extends StatelessWidget {
  final int currentIndex;
  final List<Map<String, dynamic>> items;
  final ValueChanged<int> onTap;

  const CustomNavbar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: AppTheme.surfaceContainerLowest,
      indicatorColor: AppTheme.secondaryFixedDim.withValues(alpha: 0.35),
      elevation: 3,
      height: 72,
      destinations: items.map((item) {
        return NavigationDestination(
          icon: Icon(
            item['icon'] as IconData,
            color: AppTheme.onSurfaceVariant,
          ),
          selectedIcon: Icon(
            item['icon'] as IconData,
            color: AppTheme.secondary,
          ),
          label: item['title'] as String,
        );
      }).toList(),
    );
  }
}