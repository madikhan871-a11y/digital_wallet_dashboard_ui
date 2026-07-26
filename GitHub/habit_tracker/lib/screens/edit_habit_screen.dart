import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/habit_model.dart';

class EditHabitScreen extends StatefulWidget {
  final Habit habit;

  const EditHabitScreen({
    super.key,
    required this.habit,
  });

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  final DBHelper dbHelper = DBHelper();

  late TextEditingController titleController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.habit.title,
    );

    descriptionController = TextEditingController(
      text: widget.habit.description,
    );
  }

  Future<void> updateHabit() async {
    widget.habit.title = titleController.text;
    widget.habit.description = descriptionController.text;

    await dbHelper.updateHabit(widget.habit);

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
        title: const Text("Edit Habit"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Habit Title",
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: updateHabit,
                child: const Text("Update Habit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}