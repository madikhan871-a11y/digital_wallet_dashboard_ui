import 'package:flutter/material.dart';
import '../models/habit_model.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const HabitTile({
    super.key,
    required this.habit,
    required this.onDelete,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Checkbox(
          value: habit.isCompleted,
          onChanged: (_) => onToggle(),
        ),

        title: Text(
          habit.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            decoration:
            habit.isCompleted
                ? TextDecoration.lineThrough
                : null,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            Text(habit.description),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                  size: 20,
                ),

                const SizedBox(width: 5),

                Text(
                  "Streak : ${habit.streak} Days",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),

        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.edit,
                color: Colors.blue,
              ),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}