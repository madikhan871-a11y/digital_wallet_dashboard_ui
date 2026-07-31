import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../utils/app_colors.dart';

class SummaryCard extends StatelessWidget {
final double totalBalance;
final double totalIncome;
final double totalExpense;
final bool isWarningActive;

const SummaryCard({
super.key,
required this.totalBalance,
required this.totalIncome,
required this.totalExpense,
this.isWarningActive = false,
});

@override
Widget build(BuildContext context) {
final provider = Provider.of<ExpenseProvider>(context);
final currencySymbol = provider.activeCurrencySymbol;
final isDark = provider.isDarkMode;

return Container(
padding: const EdgeInsets.all(24),
decoration: BoxDecoration(
gradient: LinearGradient(
colors: isWarningActive
? [Colors.red.shade900, Colors.red.shade700]
: [AppColors.accent, const Color(0xFF2C2C2C)],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
borderRadius: BorderRadius.circular(24),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
const Text(
"TOTAL NET ACCOUNT BALANCE",
style: TextStyle(
color: Colors.white60,
fontSize: 11,
fontWeight: FontWeight.bold,
letterSpacing: 0.5,
),
),
if (isWarningActive)
Container(
padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
decoration: BoxDecoration(
color: Colors.amber,
borderRadius: BorderRadius.circular(20),
),
child: const Text(
"LIMIT EXCEEDED",
style: TextStyle(
color: Colors.black,
fontSize: 10,
fontWeight: FontWeight.bold,
),
),
),
],
),
const SizedBox(height: 12),
Text(
"$currencySymbol ${totalBalance.toStringAsFixed(2)}",
style: const TextStyle(
color: Colors.white,
fontSize: 32,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 30),
  Row(
    children: [
      Expanded(
        child: Row(
          children: [
            const Icon(Icons.arrow_downward, color: Colors.green, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Inflow", style: TextStyle(color: Colors.white60, fontSize: 12)),
                Text(
                  "$currencySymbol ${totalIncome.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(Icons.arrow_upward, color: Colors.red, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("Outflow", style: TextStyle(color: Colors.white60, fontSize: 12)),
                Text(
                  "$currencySymbol ${totalExpense.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  ),
],
),
);
}
}
