import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/expense_model.dart';
import '../../providers/expense_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food';
  bool _isIncome = false;
  bool _isLoading = false;

  final List<String> _categories = ['Food', 'Salary', 'Transport', 'Shopping', 'Entertainment', 'Other'];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    if (_titleController.text.trim().isEmpty || _amountController.text.trim().isEmpty) return;
    final amt = double.tryParse(_amountController.text.trim());
    if (amt == null || amt <= 0) return;

    final userId = AuthService().currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      final newExp = ExpenseModel(
        id: '',
        userId: userId,
        title: _titleController.text.trim(),
        amount: amt,
        category: _selectedCategory,
        date: DateTime.now(),
        isIncome: _isIncome,
      );
      await context.read<ExpenseProvider>().addExpense(newExp);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Add transaction fail: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.read<ExpenseProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        backgroundColor: AppColors.getBackground(isDark),
        title: Text("Add Transaction", style: TextStyle(color: AppColors.getTextDark(isDark))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(_isIncome ? "Income Input Mode" : "Expense Input Mode", style: TextStyle(color: AppColors.getTextDark(isDark))),
              value: _isIncome,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => _isIncome = val),
            ),
            TextField(controller: _titleController, style: TextStyle(color: AppColors.getTextDark(isDark)), decoration: const InputDecoration(labelText: "Description / Title")),
            TextField(controller: _amountController, keyboardType: TextInputType.number, style: TextStyle(color: AppColors.getTextDark(isDark)), decoration: const InputDecoration(labelText: "Amount Value")),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              dropdownColor: AppColors.getCardBackground(isDark),
              style: TextStyle(color: AppColors.getTextDark(isDark)),
              decoration: const InputDecoration(labelText: "Category Setup"),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v ?? 'Other'),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: _isLoading ? null : _saveExpense,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Confirm Entry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
