import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/expense_card.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Transactions"), centerTitle: true),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.expenses.isEmpty) {
            return const Center(child: Text("No records found."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: provider.expenses.length,
            itemBuilder: (context, index) {
              final expense = provider.expenses[index];
              return ExpenseCard(
                expense: expense,
                onDelete: () => provider.deleteExpense(expense.id),
              );
            },
          );
        },
      ),
    );
  }
}
