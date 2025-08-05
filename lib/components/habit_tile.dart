import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HabitTile extends StatelessWidget {
  final String habitName;
  final bool habitCompleted;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? settingsTapped;
  final Function(BuildContext)? deleteTapped;

  const HabitTile({
    super.key,
    required this.habitName,
    required this.habitCompleted,
    required this.onChanged,
    required this.settingsTapped,
    required this.deleteTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: deleteTapped,
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                // FIX: No rounded border on delete action to make it a clean rectangle.
                borderRadius: BorderRadius.zero,
              ),
              SlidableAction(
                onPressed: settingsTapped,
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                foregroundColor: Colors.blue,
                icon: Icons.settings,
                // FIX: No rounded border here either.
                borderRadius: BorderRadius.zero,
              ),
            ],
          ),
          child: Container(
            // FIX: Padding inside the container for spacing around the content.
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
            // FIX: No decoration, no border, no radius.
            decoration: const BoxDecoration(
              color: Colors.white70,
            ),
            child: Row(
              children: [
                Icon(Icons.task_outlined, size: 20, color: Colors.blue),
                const SizedBox(width: 16),
                Text(
                  habitName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Checkbox(
                  value: habitCompleted,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ),
        // FIX: Add a Divider between each tile.
        const Divider(height: 1, thickness: 1, color: Colors.black12),
      ],
    );
  }
}