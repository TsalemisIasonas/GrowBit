import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:habit_tracker/constants/colors.dart';
import 'package:habit_tracker/data/habit_database.dart';
import 'package:habit_tracker/constants/category_data.dart';

class MyRadarChart extends StatelessWidget {
  final HabitDatabase db;

  const MyRadarChart({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    final Map<HabitCategory, int> completionData = db.getCategoryCompletionData();

    // final int maxCount = completionData.values.isNotEmpty
    //     ? completionData.values.reduce((a, b) => a > b ? a : b)
    //     : 1;

    return Center(
      child: SizedBox(
        width: 300,
        height: 300,
        child: RadarChart(
          RadarChartData(
            
            // Data configuration
            dataSets: [
              RadarDataSet(
                fillColor: darkGreenColor.withOpacity(0.9),
                borderColor: darkGreenColor,
                borderWidth: 2,
                entryRadius: 0.0,
                dataEntries: completionData.entries
                    .map((e) => RadarEntry(value: e.value.toDouble()))
                    .toList(),
              ),
            ],

            // Shape customization
            radarShape: RadarShape.polygon,

            // Correct getTitle signature with angle
            getTitle: (index, angle) {
              final category = HabitCategory.values[index];
              final data = categoryData[category];
              return RadarChartTitle(
                positionPercentageOffset: 0.2,
                angle: 0.0,
                text: data?['name'] ?? 'Unknown',
                // textStyle: TextStyle(
                //   fontSize: 14,
                //   fontWeight: FontWeight.bold,
                //   color: data?['color'] ?? Colors.black,
                // ),
              );
            },
            titlePositionPercentageOffset: 0.15,

            // Tick and grid styling
            tickCount: 2,//maxCount > 0 ? maxCount : 2,
            ticksTextStyle: const TextStyle(
              fontSize: 15,
              color: Colors.transparent,
            ),
            tickBorderData: BorderSide(color: Colors.black, width: 2.0),
            gridBorderData: BorderSide(color: darkGreenColor),

            // Background styling
            radarBackgroundColor: mintColor,

            // Touch interactions
            radarTouchData: RadarTouchData(
              enabled: true,
              touchCallback: (event, response) {
                // Optional: handle touch events
              },
            ),
          ),
          // Animation settings
          swapAnimationDuration: Duration(milliseconds: 800),
          swapAnimationCurve: Curves.easeInOut,
          
        ),
      ),
    );
  }
}
