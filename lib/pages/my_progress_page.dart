import 'package:flutter/material.dart';
import 'package:habit_tracker/components/month_summary.dart';
import 'package:habit_tracker/data/habit_database.dart';
import 'package:hive/hive.dart';

class MyProgressPage extends StatelessWidget {
  final HabitDatabase db;
  final Box myBox;
  
  const MyProgressPage({super.key, required this.db, required this.myBox});
  @override
  Widget build(BuildContext context) {
    return MonthlySummary(
      datasets: db.heatMapDataSet,
      startdate: myBox.get("START_DATE"),
    );
  }
}