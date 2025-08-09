import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habit_tracker/constants/colors.dart';

class HabitTile extends StatelessWidget {
  final String habitName;
  final String habitCategory;
  final IconData habitIconData;
  final bool habitCompleted;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? settingsTapped;
  final Function(BuildContext)? deleteTapped;

  const HabitTile({
    super.key,
    required this.habitName,
    required this.habitCategory,
    required this.habitIconData,
    required this.habitCompleted,
    required this.onChanged,
    required this.settingsTapped,
    required this.deleteTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Slidable(
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
                  backgroundColor: Color.fromARGB(179, 255, 245, 245),
                  foregroundColor: darkGreenColor,
                  icon: Icons.settings,
                  // FIX: No rounded border here either.
                  borderRadius: BorderRadius.zero,
                ),
              ],
            ),
            child: Container(
              // FIX: Padding inside the container for spacing around the content.
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
              // FIX: No decoration, no border, no radius.
              decoration: const BoxDecoration(
                color: Color.fromARGB(179, 251, 243, 243),
              ),
              child: Row(
                children: [
                  Icon(habitIconData, size: 28, color: darkGreenColor),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habitName[0].toUpperCase() + habitName.substring(1),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        habitCategory[0].toUpperCase() + habitCategory.substring(1),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Checkbox(
                    value: habitCompleted,
                    onChanged: onChanged,
                    activeColor: mintColor,
                    checkColor: Colors.white,
                    side: const BorderSide(
                        color: Color.fromARGB(255, 131, 129, 129),
                        width: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Colors.black45),
      ],
    );
  }
}
