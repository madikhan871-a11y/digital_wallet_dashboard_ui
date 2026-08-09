import 'package:supabase_flutter/supabase_flutter.dart';

class BillingService {
  final client = Supabase.instance.client;

  Future<void> addBill({
    required String patient,
    required String amount,
  }) async {
    await client.from("bills").insert({
      "patient_name": patient,
      "amount": double.parse(amount),
    });
  }

  Future<List<Map<String, dynamic>>> getBills() async {
    return await client
        .from("bills")
        .select()
        .order("created_at");
  }

  Future<void> deleteBill(String id) async {
    await client.from("bills").delete().eq("id", id);
  }
}