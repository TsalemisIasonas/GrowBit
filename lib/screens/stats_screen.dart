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
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/')),
          ),
        ],
      ),
      body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Focus & Effort by Category',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.tealAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Based on completion rate, priority, and recent activity',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
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
    final now = DateTime.now();
    final lookbackDays = 30; // Focus on last 30 days

    // Include ALL active categories, even with 0 completions
    for (final category in app.activeCategories) {
      double categoryScore = 0;
      
      for (final goal in category.goals) {
        for (final habit in goal.habits) {
          // Calculate score for this habit based on:
          // 1. Recent completion rate (last 30 days)
          // 2. Priority as difficulty multiplier
          // 3. Frequency expectation
          
          final habitScore = _calculateHabitScore(habit, now, lookbackDays);
          categoryScore += habitScore;
        }
      }
      
      // Add category even if score is 0
      stats.add({'name': category.title, 'value': categoryScore.round()});
    }

    // Radar chart needs at least 3 entries
    while (stats.length < 3) {
      stats.add({'name': 'No Category ${stats.length + 1}', 'value': 0});
    }

    return stats;
  }

  double _calculateHabitScore(dynamic habit, DateTime now, int lookbackDays) {
    // Base points per completion based on priority (difficulty)
    final priorityMultiplier = {
      1: 10.0,  // Low priority = 10 points
      2: 20.0,  // Medium priority = 20 points
      3: 30.0,  // High priority = 30 points
    };
    
    final basePoints = priorityMultiplier[habit.priority] ?? 20.0;
    
    // Calculate how many times the habit should have been done in lookback period
    final expectedCompletions = _calculateExpectedCompletions(habit, lookbackDays);
    
    // Count actual completions in the last 30 days
    int actualCompletions = 0;
    final cutoffDate = now.subtract(Duration(days: lookbackDays));
    
    for (final dateStr in habit.activitiesByDate.keys) {
      try {
        final date = DateTime.parse(dateStr);
        if (date.isAfter(cutoffDate) || date.isAtSameMomentAs(cutoffDate)) {
          // Count the number of activities on this date
          final activities = habit.activitiesByDate[dateStr];
          if (activities != null) {
            actualCompletions += (activities as List).length;
          }
        }
      } catch (_) {}
    }
    
    // Check if we need to count the lastCompletedDate separately
    // (only if it's not already in activitiesByDate)
    if (habit.lastCompletedDate.isNotEmpty && !habit.activitiesByDate.containsKey(habit.lastCompletedDate)) {
      try {
        final lastDate = DateTime.parse(habit.lastCompletedDate);
        if (lastDate.isAfter(cutoffDate) || lastDate.isAtSameMomentAs(cutoffDate)) {
          actualCompletions += 1;
        }
      } catch (_) {}
    }
    
    // Calculate completion rate (0.0 to 1.0+, can exceed 1.0 if overachieving)
    final completionRate = expectedCompletions > 0 
        ? (actualCompletions / expectedCompletions).clamp(0.0, 1.5)
        : 0.0;
    
    // Apply recency decay: more recent completions matter more
    final recencyBonus = _calculateRecencyBonus(habit, now);
    
    // Final score = base points × completion rate × (1 + recency bonus)
    return basePoints * completionRate * (1.0 + recencyBonus);
  }

  double _calculateExpectedCompletions(dynamic habit, int lookbackDays) {
    // Calculate how many times this habit should be done in the lookback period
    final interval = habit.frequencyInterval > 0 ? habit.frequencyInterval : 1;
    
    switch (habit.frequencyUnit) {
      case 'daily':
        // Every N days: lookback / interval
        return lookbackDays / interval.toDouble();
      case 'weekly':
        // Every N weeks: (lookback / 7) / interval
        return (lookbackDays / 7.0) / interval;
      case 'monthly':
        // Every N months: (lookback / 30) / interval
        return (lookbackDays / 30.0) / interval;
      case 'custom':
        // Custom frequency with weekdays
        if (habit.frequencyWeekdays != null && habit.frequencyWeekdays.isNotEmpty) {
          // Number of times per week based on selected weekdays
          final timesPerWeek = habit.frequencyWeekdays.length;
          return (lookbackDays / 7.0) * timesPerWeek;
        }
        return lookbackDays / interval.toDouble();
      default:
        return lookbackDays / interval.toDouble();
    }
  }

  double _calculateRecencyBonus(dynamic habit, DateTime now) {
    // Give bonus points if the habit was completed recently
    if (habit.lastCompletedDate.isEmpty) return 0.0;
    
    try {
      final lastDate = DateTime.parse(habit.lastCompletedDate);
      final daysSinceCompletion = now.difference(lastDate).inDays;
      
      // Exponential decay: 0.5 bonus if today, 0.25 if 7 days ago, etc.
      if (daysSinceCompletion <= 30) {
        return 0.5 * (1.0 - (daysSinceCompletion / 30.0));
      }
    } catch (_) {}
    
    return 0.0;
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
            final total = realStats.fold<double>(0.0, (sum, s) => sum + (s['value'] as num).toDouble());
            final percentage = total > 0 
                ? (((stat['value'] as num).toDouble() / total) * 100).toStringAsFixed(1)
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
                    '${(stat['value'] as num).toStringAsFixed(0)} pts ($percentage%)',
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
