import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final WalletTransaction transaction;

  const TransactionTile({
    super.key,
    required this.transaction,
  });

  IconData _icon() {
    switch (transaction.type) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'transfer':
        return Icons.arrow_upward_rounded;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'salary':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.payments_outlined;
    }
  }

  Color _color() {
    switch (transaction.type) {
      case 'salary':
        return AppColors.emerald;
      case 'transfer':
        return AppColors.gold;
      case 'shopping':
        return AppColors.blue;
      default:
        return AppColors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              _icon(),
              color: color,
              size: 19,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.subtitle} • ${transaction.time}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 7,
                  ),
                ),
              ],
            ),
          ),
          Text(
            transaction.amount,
            style: TextStyle(
              color: transaction.amount.startsWith('+')
                  ? AppColors.emerald
                  : AppColors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}