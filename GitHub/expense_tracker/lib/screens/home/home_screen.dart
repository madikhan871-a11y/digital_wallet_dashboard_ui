import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/expense_card.dart';
import '../expense/add_expense_screen.dart';
import '../../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
final List<String> _filterCategories = ['All', 'Food', 'Salary', 'Transport', 'Shopping', 'Entertainment', 'Other'];

@override
void initState() {
super.initState();
WidgetsBinding.instance.addPostFrameCallback((_) {
context.read<ExpenseProvider>().fetchExpenses();
});
}

@override
Widget build(BuildContext context) {
final provider = Provider.of<ExpenseProvider>(context);
final isDark = provider.isDarkMode;
final user = AuthService().currentUser;
final userName = user?.userMetadata?['full_name'] ?? 'User';
final rate = provider.currencyMultiplier;

return Scaffold(
backgroundColor: AppColors.getBackground(isDark),
appBar: AppBar(
backgroundColor: AppColors.getBackground(isDark),
elevation: 0,
title: Row(
children: [
const CircleAvatar(
backgroundColor: AppColors.primary,
child: Icon(Icons.person_rounded, color: Colors.white),
),
const SizedBox(width: 12),
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
"Hello,",
style: TextStyle(fontSize: 13, color: AppColors.getTextLight(isDark)),
),
Text(
userName,
style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.getTextDark(isDark)),
),
],
),
],
),
),
  body: RefreshIndicator(
    onRefresh: () => provider.fetchExpenses(),
    color: AppColors.primary,
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SummaryCard(
            totalBalance: provider.totalBalance * rate,
            totalIncome: provider.totalIncome * rate,
            totalExpense: provider.totalExpense * rate,
            isWarningActive: provider.isBudgetExceeded,
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterCategories.length,
              itemBuilder: (context, index) {
                final catName = _filterCategories[index];
                final isSelected = provider.selectedCategoryFilter.toLowerCase() == catName.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(catName),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    onSelected: (_) => provider.changeCategoryFilter(catName),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.getTextDark(isDark),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 25),
          Text(
            "Recent Transactions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.getTextDark(isDark)),
          ),
          const SizedBox(height: 10),
          provider.expenses.isEmpty
              ? Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Text(
                "No records found.",
                style: TextStyle(color: AppColors.getTextLight(isDark)),
              ),
            ),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.expenses.length,
            itemBuilder: (context, index) {
              final expense = provider.expenses[index];
              return ExpenseCard(
                expense: expense,
                onDelete: () => provider.deleteExpense(expense.id),
              );
            },
          ),
        ],
      ),
    ),
  ),
  floatingActionButton: FloatingActionButton(
    backgroundColor: AppColors.primary,
    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
    child: const Icon(Icons.add, color: Colors.white),
  ),
);
}
}
