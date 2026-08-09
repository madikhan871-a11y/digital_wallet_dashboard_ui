import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum BadgeType { pending, approved, reserved, checkedIn, missed, available }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case BadgeType.pending:
        bg = Colors.amber.shade100.withValues(alpha: 0.8);
        fg = Colors.amber.shade900;
        break;
      case BadgeType.approved:
      case BadgeType.checkedIn:
        bg = AppTheme.onTertiaryContainer.withValues(alpha: 0.15);
        fg = AppTheme.onTertiaryContainer;
        break;
      case BadgeType.reserved:
        bg = AppTheme.secondary.withValues(alpha: 0.1);
        fg = AppTheme.secondary;
        break;
      case BadgeType.missed:
        bg = AppTheme.error.withValues(alpha: 0.1);
        fg = AppTheme.error;
        break;
      case BadgeType.available:
        bg = AppTheme.onSurfaceVariant.withValues(alpha: 0.1);
        fg = AppTheme.onSurfaceVariant;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: fg,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
