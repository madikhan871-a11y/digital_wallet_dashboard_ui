import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/expense_model.dart';
import '../../services/expense_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final ExpenseService expenseService = ExpenseService();

  List<ExpenseModel> expenses = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    expenses = await expenseService.getExpenses();

    setState(() {
      loading = false;
    });
  }

  double get totalExpense {
    double total = 0;

    for (var e in expenses) {
      total += e.amount;
    }

    return total;
  }

  double categoryTotal(String category) {
    double total = 0;

    for (var e in expenses) {
      if (e.category == category) {
        total += e.amount;
      }
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          "Statistics",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "Total Expense",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Rs ${totalExpense.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 260,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 45,
                  sectionsSpace: 3,
                  sections: [
                    PieChartSectionData(
                      value: categoryTotal("Food"),
                      color: Colors.red,
                      title: "Food",
                    ),
                    PieChartSectionData(
                      value: categoryTotal("Travel"),
                      color: Colors.orange,
                      title: "Travel",
                    ),
                    PieChartSectionData(
                      value: categoryTotal("Shopping"),
                      color: Colors.blue,
                      title: "Shop",
                    ),
                    PieChartSectionData(
                      value: categoryTotal("Bills"),
                      color: Colors.green,
                      title: "Bills",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            buildCard(
              Icons.fastfood,
              "Food",
              Colors.red,
              categoryTotal("Food"),
            ),

            buildCard(
              Icons.directions_car,
              "Travel",
              Colors.orange,
              categoryTotal("Travel"),
            ),

            buildCard(
              Icons.shopping_cart,
              "Shopping",
              Colors.blue,
              categoryTotal("Shopping"),
            ),

            buildCard(
              Icons.receipt_long,
              "Bills",
              Colors.green,
              categoryTotal("Bills"),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard(
      IconData icon,
      String title,
      Color color,
      double amount,
      ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
        title: Text(title),
        trailing: Text(
          "Rs ${amount.toStringAsFixed(0)}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}