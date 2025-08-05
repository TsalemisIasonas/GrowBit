import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:habit_tracker/data/habit_database.dart';
import 'package:habit_tracker/constants/category_data.dart';

class MyRadarChart extends StatelessWidget {
  final HabitDatabase db;

  const MyRadarChart({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    final Map<HabitCategory, int> completionData = db.getCategoryCompletionData();

    final int maxCount = completionData.values.isNotEmpty
        ? completionData.values.reduce((a, b) => a > b ? a : b)
        : 1;

    return Center(
      child: SizedBox(
        width: 150,
        height: 150,
        child: RadarChart(
          RadarChartData(
            dataSets: [
              RadarDataSet(
                fillColor: Colors.blue.withOpacity(0.5),
                borderColor: Colors.blue,
                borderWidth: 2,
                dataEntries: completionData.entries.map((entry) {
                  return RadarEntry(value: entry.value.toDouble());
                }).toList(),
              ),
            ],
            // Simplified Titles configuration
            // titlesData: FlTitlesData(
            //   radarTitleContent: (angle, entry) {
            //     final category = HabitCategory.values[entry.index];
            //     return SideTitleWidget(
            //       axisSide: AxisSide.top,
            //       space: 12,
            //       child: Text(
            //         categoryData[category]!['name'],
            //         style: TextStyle(
            //           color: categoryData[category]!['color'],
            //           fontWeight: FontWeight.bold,
            //           fontSize: 14,
            //         ),
            //       ),
            //     );
            //   },
            // ),
            radarShape: RadarShape.polygon,
            tickCount: maxCount > 0 ? maxCount : 1,
          ),
        ),
      ),
    );
  }
}