import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class HeatmapWidget extends StatelessWidget {
  final String categoryId;
  final Habit habit;
  final int days;
  const HeatmapWidget({super.key, required this.categoryId, required this.habit, this.days = 90});

  Color _colorForCount(int c) {
    if (c == 0) return const Color(0xFF1B2330);
    if (c == 1) return const Color(0xFF31A354).withOpacity(0.4);
    if (c == 2) return const Color(0xFF31A354).withOpacity(0.5);
    if (c == 3) return const Color(0xFF31A354).withOpacity(0.6);
    if (c == 4) return const Color(0xFF31A354).withOpacity(0.7);
    if (c == 5) return const Color(0xFF31A354).withOpacity(0.8);
    if (c == 6) return const Color(0xFF31A354).withOpacity(0.9);
    return const Color(0xFF1E9248);
  }

  @override
  Widget build(BuildContext context) {
    final map = context.read<AppProvider>().habitActivityMap(categoryId, habit.id, days: days);
    final dates = List<String>.from(map.keys);
    dates.sort(); // oldest ... newest
    // Show as grid with 7 columns per week (like GitHub)
    final rows = (dates.length / 7).ceil();
    return LayoutBuilder(builder: (context, constraints) {
      final cellSize = (constraints.maxWidth - 16) / 14; // allow scrolling; modest size
      return SingleChildScrollView(
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: dates.map((d) {
            final count = map[d] ?? 0;
            return GestureDetector(
              onTap: () {
                final activities = habit.activitiesByDate[d] ?? [];
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) {
                    final date = DateTime.parse(d);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 36,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            Text(
                              DateFormat.yMMMMEEEEd().format(date),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            if (activities.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Text('No entries for this day.'),
                              )
                            else
                              Flexible(
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: activities.length,
                                  separatorBuilder: (_, __) => const Divider(height: 1),
                                  itemBuilder: (_, index) {
                                    final a = activities[index];
                                    return ListTile(
                                      dense: true,
                                      title: Text(a),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                width: cellSize,
                height: cellSize,
                decoration: BoxDecoration(color: _colorForCount(count), borderRadius: BorderRadius.circular(4)),
                child: count > 0
                    ? Center(
                        child: Text('$count', style: const TextStyle(fontSize: 10, color: Colors.white70)),
                      )
                    : const SizedBox.shrink(),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}