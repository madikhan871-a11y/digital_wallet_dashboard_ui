import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';

class ExpenseProvider extends ChangeNotifier {
final ExpenseService _expenseService = ExpenseService();
List<ExpenseModel> _allExpenses = [];
String _selectedCategoryFilter = 'All';
double _monthlyBudgetLimit = 500.0;
bool _isLoading = false;

// Theme and Currency global settings indicators
bool _isDarkMode = false;
String _activeCurrencySymbol = '\$';
double _currencyExchangeMultiplier = 1.0;

ExpenseProvider() {
_loadAppPreferences();
}

List<ExpenseModel> get expenses {
if (_selectedCategoryFilter == 'All') return _allExpenses;
return _allExpenses.where((e) => e.category.toLowerCase() == _selectedCategoryFilter.toLowerCase()).toList();
}

// Reactive Logic Getters
bool get isLoading => _isLoading;
String get selectedCategoryFilter => _selectedCategoryFilter;
double get monthlyBudgetLimit => _monthlyBudgetLimit;
bool get isDarkMode => _isDarkMode;
String get activeCurrencySymbol => _activeCurrencySymbol;
double get currencyMultiplier => _currencyExchangeMultiplier;
bool get isBudgetExceeded => (totalExpense * _currencyExchangeMultiplier) > _monthlyBudgetLimit;
  // Multi-Currency and Theme Controller Systems
  void setCurrencyFormat(String symbol, double conversionRate) {
    _activeCurrencySymbol = symbol;
    _currencyExchangeMultiplier = conversionRate;
    notifyListeners();
  }

  void toggleTheme(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  void _loadAppPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  void changeCategoryFilter(String category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  void updateBudgetLimit(double newLimit) {
    _monthlyBudgetLimit = newLimit;
    notifyListeners();
  }

  double get totalIncome => _allExpenses.where((e) => e.isIncome).fold(0.0, (sum, item) => sum + item.amount);
  double get totalExpense => _allExpenses.where((e) => !e.isIncome).fold(0.0, (sum, item) => sum + item.amount);
  double get totalBalance => totalIncome - totalExpense;

  Future<void> fetchExpenses() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allExpenses = await _expenseService.getExpenses();
    } catch (e) {
      debugPrint("Sync operational break: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _expenseService.addExpense(expense);
    await fetchExpenses();
  }

  Future<void> updateExpense(String id, ExpenseModel expense) async {
    await _expenseService.updateExpense(id, expense);
    await fetchExpenses();
  }

  Future<void> deleteExpense(String id) async {
    await _expenseService.deleteExpense(id);
    await fetchExpenses();
  }
}
