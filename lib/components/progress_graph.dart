import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:habit_tracker/constants/colors.dart';
import '../data/habit_database.dart';

class ProgressGraph extends StatefulWidget {
  final HabitDatabase db;
  const ProgressGraph({super.key, required this.db});

  @override
  State<ProgressGraph> createState() => _ProgressGraphState();
}

class _ProgressGraphState extends State<ProgressGraph> {
  // Store these values in the state to prevent unnecessary rebuilds
  late int completed;
  late int remaining;
  late List<PieChartSectionData> sections;

  @override
  void initState() {
    super.initState();
    _calculateValues();
    sections = _buildSections();
  }

  // This method is called whenever the parent widget rebuilds with a new `db` object
  @override
  void didUpdateWidget(covariant ProgressGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update the state if the underlying data has changed
    final newCompleted = widget.db.todaysHabitList.where((task) => task[1] == true).length;
    final newRemaining = widget.db.todaysHabitList.length - newCompleted;
    if (newCompleted != completed || newRemaining != remaining) {
      _calculateValues();
      setState(() {
        sections = _buildSections();
      });
    }
  }
  
  // A helper method to calculate completed and remaining
  void _calculateValues() {
    completed = widget.db.todaysHabitList.where((task) => task[1] == true).length;
    remaining = widget.db.todaysHabitList.length - completed;
  }
  
  // A helper method to build the sections list
  List<PieChartSectionData> _buildSections() {
    return [
      PieChartSectionData(
        //key: const ValueKey('completed'),
        color: darkGreenColor,
        value: completed.toDouble(),
        showTitle: false,
        radius: 15,
      ),
      PieChartSectionData(
        //key: const ValueKey('remaining'),
        color: //const Color.fromARGB(255, 203, 224, 246), 
               mintColor ,
        value: remaining.toDouble(),
        showTitle: false,
        radius: 15,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SizedBox(
        width: 55,
        height: 55,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${completed.toString()} / ${widget.db.todaysHabitList.length.toString()}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            PieChart(
              swapAnimationDuration: const Duration(milliseconds: 150),
              swapAnimationCurve: Curves.easeIn,
              PieChartData(
                startDegreeOffset: 150,
                sectionsSpace: 0,
                centerSpaceRadius: 100,
                sections: sections, // Use the state-managed sections
              ),
            ),
          ],
        ),
      ),
    );
  }
}