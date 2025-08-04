import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/habit_database.dart';


class ProgressGraph extends StatelessWidget {

  final HabitDatabase db;

  const ProgressGraph({super.key, required this.db});

    
  @override
  Widget build(BuildContext context) {
    int completed = db.todaysHabitList.where((task) => task[1] == true).length;
    int remaining = db.todaysHabitList.length - completed;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SizedBox(
          width: 55,
          height: 55,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text('${completed.toString()} / ${db.todaysHabitList.length.toString()}', 
              style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w700)),
              PieChart(
                PieChartData(
                  startDegreeOffset: 150,
                  sectionsSpace: 0,
                  centerSpaceRadius: 50,
                  sections: [
                    PieChartSectionData(
                      color: Colors.blue,
                      value: completed.toDouble(),
                      showTitle: false,
                      radius: 10,
                    ),
                    PieChartSectionData(
                      color: Colors.grey.shade800,
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