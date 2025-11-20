import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/aggregate_heatmap.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final controller = TextEditingController();
    await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Add Category'),
            content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Category name')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  final v = controller.text.trim();
                  if (v.isNotEmpty) {
                    context.read<AppProvider>().addCategory(v);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final todayHabits = _habitsDueToday(app);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Categories',
                        style: TextStyle(fontSize: 20, color: Colors.tealAccent)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: app.categories.length,
                  itemBuilder: (context, i) {
                    final c = app.categories[i];
                    return ListTile(
                      title: Text(c.title),
                      subtitle: Text('${c.goals.length} goal(s)'),
                      onTap: () {
                        Navigator.pop(context); // close drawer
                        Navigator.pushNamed(context, '/category',
                            arguments: {'id': c.id});
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddCategoryDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('New Category'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 300,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 83, 82, 82),
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Activity Heatmap (all habits)',
                    style: TextStyle(
                        fontSize: 18, color: Colors.tealAccent),
                  ),
                  SizedBox(height: 8),
                  Expanded(child: AggregateHeatmap(days: 90)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today\'s habits',
                    style: TextStyle(color: Colors.tealAccent, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  if (todayHabits.isEmpty)
                    const Text(
                      'No habits scheduled for today.',
                      style: TextStyle(color: Colors.white70),
                    )
                  else
                    Column(
                      children: todayHabits.map((r) {
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(r['habitName']),
                          subtitle: Text('${r['goalTitle']} · ${r['categoryTitle']}'),
                          trailing: Wrap(
                            spacing: 4,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle_outline, color: Colors.tealAccent),
                                onPressed: () async {
                                  await app.recordHabitCompletion(
                                    r['categoryId'] as String,
                                    r['goalId'] as String,
                                    r['habitId'] as String,
                                    note: 'Completed from dashboard',
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.white70),
                                onPressed: () {
                                  _showEditHabitDialog(
                                    context,
                                    app,
                                    r['categoryId'] as String,
                                    r['goalId'] as String,
                                    r['habitId'] as String,
                                    r['habitName'] as String,
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditHabitDialog(
    BuildContext context,
    AppProvider app,
    String categoryId,
    String goalId,
    String habitId,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Habit'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final v = controller.text.trim();
              if (v.isNotEmpty) {
                app.editHabit(categoryId, goalId, habitId, name: v);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _habitsDueToday(AppProvider app) {
    final List<Map<String, dynamic>> list = [];
    final now = DateTime.now();
    final todayKey = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    for (final c in app.categories) {
      for (final g in c.goals) {
        for (final h in g.habits) {
          bool due = false;
          if (h.frequencyUnit == 'daily') {
            due = true;
          } else if (h.frequencyUnit == 'weekly') {
            // due on the same weekday as lastCompletedDate or if never completed, any day
            if (h.lastCompletedDate.isEmpty) {
              due = true;
            } else {
              try {
                final last = DateTime.parse(h.lastCompletedDate);
                due = now.weekday == last.weekday;
              } catch (_) {
                due = true;
              }
            }
          } else if (h.frequencyUnit == 'monthly') {
            if (h.lastCompletedDate.isEmpty) {
              due = true;
            } else {
              try {
                final last = DateTime.parse(h.lastCompletedDate);
                due = now.day == last.day;
              } catch (_) {
                due = true;
              }
            }
          }

          if (!due) continue;

          final completedToday = h.activitiesByDate[ todayKey ]?.isNotEmpty == true || h.lastCompletedDate == todayKey;
          if (!completedToday) {
            list.add({
              'categoryId': c.id,
              'categoryTitle': c.title,
              'goalId': g.id,
              'goalTitle': g.title,
              'habitId': h.id,
              'habitName': h.name,
            });
          }
        }
      }
    }
    return list;
  }
}