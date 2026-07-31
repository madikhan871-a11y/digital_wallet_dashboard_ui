import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/expense_card.dart';
import '../../utils/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
String _searchQuery = "";
String _activeTimeFilter = "All Time";
final List<String> _timeIntervals = ["All Time", "Today", "This Week", "This Month"];

bool _evaluateTimelineScope(DateTime targetDate) {
final now = DateTime.now();
if (_activeTimeFilter == "Today") {
return targetDate.day == now.day && targetDate.month == now.month && targetDate.year == now.year;
} else if (_activeTimeFilter == "This Week") {
return targetDate.isAfter(now.subtract(const Duration(days: 7)));
} else if (_activeTimeFilter == "This Month") {
return targetDate.month == now.month && targetDate.year == now.year;
}
return true;
}

void _triggerPdfExportEngine(int count) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Row(
children: [
const SizedBox(
width: 20,
height: 20,
child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
),
const SizedBox(width: 16),
Text("Compiling PDF Report for $count logs..."),
],
),
backgroundColor: AppColors.primary,
),
);
}
@override
Widget build(BuildContext context) {
  final isDark = Provider.of<ExpenseProvider>(context).isDarkMode;

  return Scaffold(
    backgroundColor: AppColors.getBackground(isDark),
    appBar: AppBar(
      backgroundColor: AppColors.getBackground(isDark),
      elevation: 0,
      title: Text(
        "Reports Workspace",
        style: TextStyle(color: AppColors.getTextDark(isDark), fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    ),
    body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _timeIntervals.length,
              itemBuilder: (context, index) {
                final label = _timeIntervals[index];
                final isSel = _activeTimeFilter == label;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: isSel,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.getCardBackground(isDark),
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : AppColors.getTextDark(isDark),
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) => setState(() => _activeTimeFilter = label),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            style: TextStyle(color: AppColors.getTextDark(isDark)),
            decoration: InputDecoration(
              hintText: "Search descriptions...",
              hintStyle: TextStyle(color: AppColors.getTextLight(isDark)),
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              fillColor: AppColors.getCardBackground(isDark),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: Consumer<ExpenseProvider>(
              builder: (context, provider, child) {
                final operationalLogs = provider.expenses.where((expense) {
                  return expense.title.toLowerCase().contains(_searchQuery) &&
                      _evaluateTimelineScope(expense.date);
                }).toList();

                if (operationalLogs.isEmpty) {
                  return Center(
                    child: Text(
                      "No records found.",
                      style: TextStyle(color: AppColors.getTextLight(isDark)),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: operationalLogs.length,
                  itemBuilder: (context, index) {
                    final log = operationalLogs[index];
                    return ExpenseCard(
                      expense: log,
                      onDelete: () => provider.deleteExpense(log.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
}
