import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/constants/colors.dart';
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
          width: 60,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(db.getOverallCompletion(), 
              style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500)),
              PieChart(
                PieChartData(
                  startDegreeOffset: -90,
                  sectionsSpace: 0,
                  centerSpaceRadius: 60,
                  sections: [
                    PieChartSectionData(
                      color: darkGreenColor,
                      value: completed.toDouble(),
                      showTitle: false,
                      radius: 10,
                    ),
                    PieChartSectionData(
                      color: mintColor,
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