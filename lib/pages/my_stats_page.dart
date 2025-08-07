import 'package:flutter/material.dart';
import 'package:habit_tracker/components/my_radar_chart.dart';
import 'package:habit_tracker/components/overall_graph.dart';
import 'package:habit_tracker/data/habit_database.dart';

class MyStatsPage extends StatelessWidget {
  const MyStatsPage({super.key, required this.db});
  final HabitDatabase db;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20.0),
          child: Text(
            "Stats",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 30.0, top: 25.0),
          child: Text(
            "Overall Completion",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 50),
        Center(
          child: OverallGraph(db: db),
        ),
        const SizedBox(height: 50),
        const Divider(
          height: 1,
          thickness: 1,
          color: Colors.black45,
          indent: 25.0,
          endIndent: 25.0,
        ),
        const Padding(
          padding: EdgeInsets.only(left: 30.0, top: 15.0),
          child: Text(
            "Activity by Category",
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Center(child: MyRadarChart(db: db))
      ],
    );
  }
}
