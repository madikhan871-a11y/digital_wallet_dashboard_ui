import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/expense_model.dart';
import '../../providers/expense_provider.dart';

class EditExpenseScreen extends StatefulWidget {
  final ExpenseModel expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late String _selectedCategory;
  late bool _isIncome;
  bool _isLoading = false;

  final List<String> _categories = ['Food', 'Salary', 'Transport', 'Shopping', 'Entertainment', 'Other'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense.title);
    _amountController = TextEditingController(text: widget.expense.amount.toString());
    _selectedCategory = widget.expense.category;
    _isIncome = widget.expense.isIncome;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _updateExpense() async {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();

    if (title.isEmpty || amountText.isEmpty) return;

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    setState(() => _isLoading = true);

    try {
      final updatedExpense = ExpenseModel(
        id: widget.expense.id,
        userId: widget.expense.userId,
        title: title,
        amount: amount,
        category: _selectedCategory,
        date: widget.expense.date,
        isIncome: _isIncome,
      );

      await ReadContext(context).read<ExpenseProvider>().updateExpense(widget.expense.id, updatedExpense);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Edit Transaction")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text("Expense")),
                    selected: !_isIncome,
                    selectedColor: Colors.red.shade100,
                    onSelected: (val) => setState(() => _isIncome = false),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text("Income")),
                    selected: _isIncome,
                    selectedColor: Colors.green.shade100,
                    onSelected: (val) => setState(() => _isIncome = true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Title",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Amount",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val ?? 'Other'),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: _isLoading ? null : _updateExpense,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on BuildContext {
}
