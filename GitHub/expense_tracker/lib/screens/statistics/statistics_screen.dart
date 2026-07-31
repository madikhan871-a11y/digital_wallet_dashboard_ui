import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/utils/app_colors.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final isDark = provider.isDarkMode;
    final _ = provider.activeCurrencySymbol;
    final rate = provider.currencyMultiplier;

    final totalIncome = provider.totalIncome * rate;
    final totalExpense = provider.totalExpense * rate;
    final _ = totalIncome + totalExpense;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        backgroundColor: AppColors.getBackground(isDark),
        elevation: 0,
        title: Text("Analytics", style: TextStyle(color: AppColors.getTextDark(isDark), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: totalIncome == 0 && totalExpense == 0
          ? Center(child: Text("No data rows yet.", style: TextStyle(color: AppColors.getTextLight(isDark))))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 55,
                  sections: [
                    PieChartSectionData(color: AppColors.greenSmooth, value: totalIncome > 0 ? totalIncome : 1, title: 'Income', radius: 50, titleStyle: const TextStyle(color: Colors.white)),
                    PieChartSectionData(color: AppColors.primary, value: totalExpense > 0 ? totalExpense : 1, title: 'Expense', radius: 50, titleStyle: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
