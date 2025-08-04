import 'package:flutter/material.dart';
import 'package:habit_tracker/components/habit_tile.dart';
import 'package:habit_tracker/components/progress_graph.dart';
import 'package:habit_tracker/data/habit_database.dart';
import 'package:intl/intl.dart';

class HomepageBody extends StatefulWidget {
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
  State<HomepageBody> createState() => _HomepageBodyState();
}

class _HomepageBodyState extends State<HomepageBody> {
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
          Center(child: ProgressGraph(db: widget.db)),
          const SizedBox(height: 50),
          Expanded(
            child: Container(
              // FIX: This container now defines the single outer border.
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return HabitTile(
                    habitName: widget.db.todaysHabitList[index][0],
                    habitCompleted: widget.db.todaysHabitList[index][1],
                    onChanged: (value) => widget.checkBoxTapped(value, index),
                    settingsTapped: ((context) {
                      widget.openHabitSettings(index);
                    }),
                    deleteTapped: (context) => widget.deleteHabit(index),
                  );
                },
                itemCount: widget.db.todaysHabitList.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}