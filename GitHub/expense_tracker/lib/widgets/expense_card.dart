import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../utils/app_colors.dart';

class ExpenseCard extends StatelessWidget {
final ExpenseModel expense;
final VoidCallback? onDelete;

const ExpenseCard({super.key, required this.expense, this.onDelete});

// Long press modal popup trigger to modify titles inline dynamically
void _showEditTransactionDialog(BuildContext context, bool isDark) {
final titleController = TextEditingController(text: expense.title);
final amountController = TextEditingController(text: expense.amount.toString());

showDialog(
context: context,
builder: (context) {
return AlertDialog(
backgroundColor: AppColors.getCardBackground(isDark),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
title: Text(
"Modify Log Entry",
style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.getTextDark(isDark)),
),
content: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextField(
controller: titleController,
style: TextStyle(color: AppColors.getTextDark(isDark)),
decoration: InputDecoration(
labelText: "Edit Title/Description",
labelStyle: TextStyle(color: AppColors.getTextLight(isDark)),
border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
),
),
const SizedBox(height: 15),
TextField(
controller: amountController,
keyboardType: TextInputType.number,
style: TextStyle(color: AppColors.getTextDark(isDark)),
decoration: InputDecoration(
labelText: "Modify Base Amount",
labelStyle: TextStyle(color: AppColors.getTextLight(isDark)),
border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
),
),
],
),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text("Dismiss", style: TextStyle(color: Colors.grey)),
),
ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: AppColors.primary,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
),
onPressed: () async {
final newAmt = double.tryParse(amountController.text.trim()) ?? expense.amount;
final newTitle = titleController.text.trim();

if (newTitle.isNotEmpty) {
final updatedObj = ExpenseModel(
id: expense.id,
userId: expense.userId,
title: newTitle,
amount: newAmt,
category: expense.category,
date: expense.date,
isIncome: expense.isIncome,
);

await Provider.of<ExpenseProvider>(context, listen: false).updateExpense(expense.id, updatedObj);
if (context.mounted) Navigator.pop(context);
}
},
child: const Text("Save Logs", style: TextStyle(color: Colors.white)),
),
],
);
},
);
}
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final isDark = provider.isDarkMode;

    // Dynamic Active Multi-Currency Conversions System integration
    final currencySymbol = provider.activeCurrencySymbol;
    final rate = provider.currencyMultiplier;
    final convertedAmount = expense.amount * rate;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      color: AppColors.getCardBackground(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.getBorder(isDark)),
      ),
      child: ListTile(
        onLongPress: () => _showEditTransactionDialog(context, isDark),
        leading: CircleAvatar(
          backgroundColor: expense.isIncome
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
          child: Icon(
            expense.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: expense.isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          expense.title,
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.getTextDark(isDark)),
        ),
        subtitle: Text(
          DateFormat('dd MMM yyyy').format(expense.date),
          style: TextStyle(color: AppColors.getTextLight(isDark), fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${expense.isIncome ? '+' : '-'}$currencySymbol ${convertedAmount.toStringAsFixed(2)}",
              style: TextStyle(
                color: expense.isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                onPressed: onDelete,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
