import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/habit_model.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final DBHelper dbHelper = DBHelper();

  Future<void> saveHabit() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );
      return;
    }

    Habit habit = Habit(
      title: titleController.text,
      description: descriptionController.text,
    );

    await dbHelper.insertHabit(habit);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Habit"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Habit Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveHabit,
                child: const Text("Save Habit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}