import 'package:flutter/material.dart';
import 'package:habit_tracker/components/habit_tile.dart';
import 'package:habit_tracker/components/progress_graph.dart';
import 'package:habit_tracker/data/habit_database.dart';
import 'package:intl/intl.dart';

class HomepageBody extends StatelessWidget {
  final HabitDatabase db;
  final Function checkBoxTapped;
  final Function openHabitSettings;
  final Function deleteHabit;

  const HomepageBody({
    super.key,
    required this.db,
    required this.checkBoxTapped,
    required this.openHabitSettings,
    required this.deleteHabit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // The main padding is now applied here
      padding: const EdgeInsets.all(12.0), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Home",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          Text(
            DateFormat('EEEE, MMMM d').format(DateTime.now()),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 50),
          Center(child: ProgressGraph(db: db)),
          const SizedBox(height: 50),
          Expanded(
            child: Container(
              // FIX: This container now defines the single outer border.
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.builder(
                // FIX: No padding, so the tiles touch the container's edge.
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return HabitTile(
                    habitName: db.todaysHabitList[index][0],
                    habitCompleted: db.todaysHabitList[index][1],
                    onChanged: (value) => checkBoxTapped(value, index),
                    settingsTapped: ((context) {
                      openHabitSettings(index);
                    }),
                    deleteTapped: (context) => deleteHabit(index),
                  );
                },
                itemCount: db.todaysHabitList.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}