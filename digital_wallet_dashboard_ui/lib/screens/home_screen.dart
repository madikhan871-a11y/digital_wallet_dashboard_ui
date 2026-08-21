import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/transaction.dart';
import '../widgets/action_button.dart';
import '../widgets/balance_card.dart';
import '../widgets/bank_card.dart';
import '../widgets/transaction_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const transactions = [
    WalletTransaction(
      title: 'Salary Received',
      subtitle: 'ABC Technologies',
      amount: '+ Rs. 65,000',
      type: 'salary',
      time: 'Today',
    ),
    WalletTransaction(
      title: 'Food & Coffee',
      subtitle: 'Coffee Planet',
      amount: '- Rs. 850',
      type: 'food',
      time: 'Today',
    ),
    WalletTransaction(
      title: 'Money Sent',
      subtitle: 'Ali Ahmed',
      amount: '- Rs. 2,500',
      type: 'transfer',
      time: 'Yesterday',
    ),
    WalletTransaction(
      title: 'Shopping',
      subtitle: 'Style Store',
      amount: '- Rs. 4,200',
      type: 'shopping',
      time: 'Yesterday',
    ),
  ];

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
            30,
          ),
          children: [
            _header(),
            const SizedBox(height: 20),
            const BalanceCard(),
            const SizedBox(height: 17),
            _incomeExpense(),
            const SizedBox(height: 22),
            _sectionTitle('Quick Actions'),
            const SizedBox(height: 11),
            _actions(context),
            const SizedBox(height: 23),
            _sectionTitle('Recent Transactions'),
            const SizedBox(height: 11),
            ...transactions.map(
                  (transaction) => TransactionTile(
                transaction: transaction,
              ),
            ),
            const SizedBox(height: 14),
            _sectionTitle('My Card'),
            const SizedBox(height: 11),
            const BankCard(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showScanMessage(context);
        },
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.background,
        child: const Icon(Icons.qr_code_scanner_rounded),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(
            color: AppColors.emerald,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_rounded,
            color: AppColors.background,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 9,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Madiha 👋',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.white,
            size: 21,
          ),
        ),
      ],
    );
  }

  Widget _incomeExpense() {
    return Row(
      children: [
        Expanded(
          child: _moneyCard(
            icon: Icons.arrow_downward_rounded,
            title: 'Income',
            amount: 'Rs. 65,000',
            color: AppColors.emerald,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _moneyCard(
            icon: Icons.arrow_upward_rounded,
            title: 'Expenses',
            amount: 'Rs. 7,550',
            color: AppColors.red,
          ),
        ),
      ],
    );
  }

  Widget _moneyCard({
    required IconData icon,
    required String title,
    required String amount,
    required Color color,
  }) {
    return Container(
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
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 9),
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
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Row(
      children: [
        ActionButton(
          icon: Icons.arrow_upward_rounded,
          label: 'Send Money',
          color: AppColors.emerald,
          onTap: () => _showAction(context, 'Send Money'),
        ),
        const SizedBox(width: 9),
        ActionButton(
          icon: Icons.arrow_downward_rounded,
          label: 'Receive',
          color: AppColors.gold,
          onTap: () => _showAction(context, 'Receive Money'),
        ),
        const SizedBox(width: 9),
        ActionButton(
          icon: Icons.qr_code_scanner_rounded,
          label: 'Scan & Pay',
          color: AppColors.blue,
          onTap: () => _showAction(context, 'Scan & Pay'),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const Text(
          'See all',
          style: TextStyle(
            color: AppColors.emerald,
            fontSize: 8,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  void _showAction(
      BuildContext context,
      String action,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action selected'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showScanMessage(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Scan & Pay',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'QR scanner is ready for payment.',
            style: TextStyle(
              color: AppColors.textMuted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: AppColors.emerald,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}