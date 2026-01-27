import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final categoryStats = _calculateCategoryStats(app);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.home), onPressed: () {})]
      ),
      body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Habit Completions by Category',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.tealAccent,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      height: 400,
                      child: RadarChart(
                        RadarChartData(
                          radarShape: RadarShape.polygon,
                          radarBorderData: const BorderSide(
                            color: Colors.tealAccent,
                            width: 2,
                          ),
                          gridBorderData: const BorderSide(
                            color: Colors.white24,
                            width: 1,
                          ),
                          tickBorderData: const BorderSide(
                            color: Colors.white12,
                          ),
                          tickCount: 5,
                          ticksTextStyle: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                          radarBackgroundColor: Colors.transparent,
                          dataSets: [
                            RadarDataSet(
                              fillColor: const Color(0xFF64FFDA).withOpacity(0.3),
                              borderColor: const Color(0xFF64FFDA),
                              borderWidth: 2,
                              entryRadius: 3,
                              dataEntries: categoryStats
                                  .map((stat) => RadarEntry(value: stat['value']!.toDouble()))
                                  .toList(),
                            ),
                          ],
                          getTitle: (index, angle) {
                            if (index >= categoryStats.length) {
                              return const RadarChartTitle(text: '');
                            }
                            return RadarChartTitle(
                              text: categoryStats[index]['name']!,
                              angle: angle,
                            );
                          },
                          titleTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          titlePositionPercentageOffset: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildCategoryBreakdown(categoryStats),
                  ],
                ),
              ),
            ),
    );
  }

  List<Map<String, dynamic>> _calculateCategoryStats(AppProvider app) {
    final List<Map<String, dynamic>> stats = [];

    // Include ALL active categories, even with 0 completions
    for (final category in app.activeCategories) {
      int totalCompletions = 0;
      
      for (final goal in category.goals) {
        for (final habit in goal.habits) {
          // Count all completion dates
          for (final activities in habit.activitiesByDate.values) {
            totalCompletions += activities.length;
          }
          // Also count if lastCompletedDate exists
          if (habit.lastCompletedDate.isNotEmpty) {
            totalCompletions += 1;
          }
        }
      }
      
      // Add category even if completions are 0
      stats.add({'name': category.title, 'value': totalCompletions});
    }

    // Radar chart needs at least 3 entries
    // If we have fewer than 3 categories, add dummy entries
    while (stats.length < 3) {
      stats.add({'name': 'No Category ${stats.length + 1}', 'value': 0});
    }

    return stats;
  }

  Widget _buildCategoryBreakdown(List<Map<String, dynamic>> stats) {
    // Filter out dummy entries for the breakdown display
    final realStats = stats.where((s) => !s['name'].toString().startsWith('No Category')).toList();
    
    if (realStats.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'No categories yet. Create a category to start tracking!',
          style: TextStyle(color: Colors.white70, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.tealAccent,
            ),
          ),
          const SizedBox(height: 16),
          ...realStats.map((stat) {
            final total = realStats.fold<int>(0, (sum, s) => sum + (s['value'] as int));
            final percentage = total > 0 
                ? ((stat['value'] as int) / total * 100).toStringAsFixed(1)
                : '0.0';
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      stat['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    '${stat['value']} completions ($percentage%)',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
