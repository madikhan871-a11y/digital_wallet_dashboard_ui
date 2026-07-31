import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense_model.dart';

class ExpenseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Realtime Cloud Database Fetch Request Rows Controller
  Future<List<ExpenseModel>> getExpenses() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('expenses')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);

    return (response as List).map((json) => ExpenseModel.fromJson(json)).toList();
  }

  // Insert Expense Object inside Supabase Cloud Database Table
  Future<void> addExpense(ExpenseModel expense) async {
    await _supabase.from('expenses').insert(expense.toJson());
  }

  // Update Dynamic metadata attributes entries inside Cloud Server
  Future<void> updateExpense(String id, ExpenseModel expense) async {
    await _supabase.from('expenses').update(expense.toJson()).eq('id', id);
  }

  // Remote Delete specific record UUID indices tracking references
  Future<void> deleteExpense(String id) async {
    await _supabase.from('expenses').delete().eq('id', id);
  }
}
