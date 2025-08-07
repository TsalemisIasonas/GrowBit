import 'package:flutter/material.dart';
import 'package:habit_tracker/components/habit_tile.dart';
import 'package:habit_tracker/components/progress_graph.dart';
//import 'package:habit_tracker/constants/colors.dart';
import 'package:habit_tracker/data/habit_database.dart';
import 'package:intl/intl.dart';

class HomepageBody extends StatelessWidget {
  final HabitDatabase db;
  final Function(bool?, int) checkBoxTapped;
  final Function(int) openHabitSettings;
  final Function(int) deleteHabit;

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
      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Text(
              "Home",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text(
              DateFormat('EEEE, MMMM d').format(DateTime.now()),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 25.0, top: 25.0),
            child: Text(
              "Daily Progress",
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 100),
          Center(child: ProgressGraph(db: db)),
          const SizedBox(height: 120),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(179, 255, 245, 245),
                  border: Border.all(color: Colors.black45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return HabitTile(
                      habitName: db.todaysHabitList[index][0],
                      habitCompleted: db.todaysHabitList[index][1],
                      // Functions are now passed directly without a 'widget.' reference.
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
          ),
        ],
      ),
    );
  }
}