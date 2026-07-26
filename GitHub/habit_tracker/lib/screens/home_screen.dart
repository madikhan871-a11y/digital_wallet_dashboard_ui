import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/habit_model.dart';
import '../widgets/habit_tile.dart';
import 'add_habit_screen.dart';
import 'edit_habit_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DBHelper dbHelper = DBHelper();
  List<Habit> habits = [];

  @override
  void initState() {
    super.initState();
    loadHabits();
  }

  Future<void> loadHabits() async {
    habits = await dbHelper.getHabits();
    setState(() {});
  }

  Future<void> deleteHabit(int id) async {
    await dbHelper.deleteHabit(id);
    loadHabits();
  }

  Future<void> toggleHabit(Habit habit) async {

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (!habit.isCompleted) {

      if (habit.lastCompletedDate == null) {
        habit.streak = 1;
      } else {
        DateTime lastDate =
        DateTime.parse(habit.lastCompletedDate!);

        int difference =
            DateTime.now().difference(lastDate).inDays;

        if (difference == 1) {
          habit.streak++;
        } else if (difference > 1) {
          habit.streak = 1;
        }
      }

      habit.lastCompletedDate = today;
    }

    habit.isCompleted = !habit.isCompleted;

    await dbHelper.updateHabit(habit);

    loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Habit Tracker"),
        centerTitle: true,
      ),
      body: habits.isEmpty
          ? const Center(
        child: Text(
          "No Habits Yet\nClick + to add one",
          textAlign: TextAlign.center,
        ),
      )
          : ListView.builder(
        itemCount: habits.length,
        itemBuilder: (context, index) {
          final habit = habits[index];

          return HabitTile(
            habit: habit,
            onDelete: () => deleteHabit(habit.id!),
            onToggle: () => toggleHabit(habit),
            onEdit: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditHabitScreen(
                    habit: habit,
                  ),
                ),
              );

              if (result == true) {
                loadHabits();
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddHabitScreen(),
            ),
          );

          if (result == true) {
            loadHabits();
          }
        },
      ),
    );
  }
}