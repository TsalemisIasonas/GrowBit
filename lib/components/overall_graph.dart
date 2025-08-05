import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/data/habit_database.dart';

class OverallGraph extends StatelessWidget {
  final HabitDatabase db;
  const OverallGraph({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    int completed = db.todaysHabitList.where((task) => task[1] == true).length;
    int remaining = db.todaysHabitList.length - completed;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SizedBox(
          width: 30,
          height: 30,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(db.getOverallCompletion(), 
              style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
              PieChart(
                PieChartData(
                  startDegreeOffset: -90,
                  sectionsSpace: 0,
                  centerSpaceRadius: 35,
                  sections: [
                    PieChartSectionData(
                      color: Colors.blue,
                      value: completed.toDouble(),
                      showTitle: false,
                      radius: 10,
                    ),
                    PieChartSectionData(
                      color: Color.fromARGB(255,203, 224, 246),
                      value: remaining.toDouble(),
                      showTitle: false,
                      radius: 10,
                    ),
                  ],
                ),
              ),
              
            ],
          ),
        ),
    );
  }
}