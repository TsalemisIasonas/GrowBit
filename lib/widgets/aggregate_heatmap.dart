import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'package:intl/intl.dart';

class AggregateHeatmap extends StatelessWidget {
  final int days;
  const AggregateHeatmap({super.key, this.days = 90});

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
    final map = context.watch<AppProvider>().aggregatedActivityMap(days: days);
    final dates = List<String>.from(map.keys);
    dates.sort(); // oldest ... newest
    return LayoutBuilder(builder: (context, constraints) {
      final cellSize = (constraints.maxWidth - 16) / 14;
      return SingleChildScrollView(
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: dates.map((d) {
            final count = map[d] ?? 0;
            return GestureDetector(
              onTap: () {
                final app = context.read<AppProvider>();
                // Collect sample activities across habits for that day
                final activities = <String>[];
                for (final c in app.categories) {
                  for (final g in c.goals) {
                    for (final h in g.habits) {
                      final list = h.activitiesByDate[d];
                      if (list != null && list.isNotEmpty) {
                        activities.addAll(list.map((e) => '${h.name}: $e'));
                      }
                    }
                  }
                }
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) {
                    final date = DateTime.parse(d);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.only(
                        top: 12,
                        left: 16,
                        right: 16,
                        bottom: 24,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.black,
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
                                padding:
                                    EdgeInsets.symmetric(vertical: 12.0),
                                child: Text('No entries for this day.'),
                              )
                            else
                              Flexible(
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: activities.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
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
                // No numeric count inside the square; color intensity alone indicates activity.
                child: const SizedBox.shrink(),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}