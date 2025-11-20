import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/habit_tile.dart';
import '../models/goal.dart';
import '../models/habit.dart';
import 'package:uuid/uuid.dart';

class CategoryScreen extends StatefulWidget {
  static const routeName = '/category';
  final String categoryId;
  const CategoryScreen({super.key, required this.categoryId});
  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _uuid = const Uuid();

  Future<void> _showAddGoalDialog(BuildContext context, String categoryId) async {
    final controller = TextEditingController();
    int selectedPriority = 2;
    await showDialog(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
              builder: (ctx, setState) => AlertDialog(
              title: const Text('Add Goal'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: controller, decoration: const InputDecoration(hintText: 'Goal title')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Priority:'),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: selectedPriority,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Low')),
                          DropdownMenuItem(value: 2, child: Text('Medium')),
                          DropdownMenuItem(value: 3, child: Text('High')),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => selectedPriority = v);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      final v = controller.text.trim();
                      if (v.isNotEmpty) {
                        context.read<AppProvider>().addGoal(categoryId, v, priority: selectedPriority);
                        Navigator.pop(dialogContext);
                      }
                    },
                    child: const Text('Add'))
              ],
            )));
  }

  Future<void> _showEditGoalDialog(BuildContext context, String categoryId, Goal goal) async {
    final controller = TextEditingController(text: goal.title);
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Edit Goal'),
              content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Goal title')),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      final v = controller.text.trim();
                      if (v.isNotEmpty) {
                        context.read<AppProvider>().editGoal(categoryId, goal.id, v);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save'))
              ],
            ));
  }

  Future<void> _showAddHabitDialog(BuildContext context, String categoryId, {String? preselectedGoalId}) async {
    final controller = TextEditingController();
    final app = context.read<AppProvider>();
    // prepare list of goals in this category
    final category = app.categories.firstWhere((c) => c.id == categoryId);
    String? chosenGoalId = preselectedGoalId ?? (category.goals.isNotEmpty ? category.goals.first.id : null);
    // default schedule values for new habit
    TimeOfDay selectedTime = TimeOfDay.now();
    String unit = 'daily';
    int interval = 1;
    final Map<int, String> weekdayLabels = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };
    final Set<int> selectedWeekdays = {};
    bool remind = false;

    await showDialog(
        context: context,
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: const Text('Add Habit'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: controller, decoration: const InputDecoration(hintText: 'Habit name')),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Time:'),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () async {
                              final t = await showTimePicker(context: context, initialTime: selectedTime);
                              if (t != null) {
                                setState(() => selectedTime = t);
                              }
                            },
                            child: Text(selectedTime.format(context)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: unit,
                        items: const [
                          DropdownMenuItem(value: 'daily', child: Text('Every day')),
                          DropdownMenuItem(value: 'weekly', child: Text('Every week')),
                          DropdownMenuItem(value: 'monthly', child: Text('Every month')),
                          DropdownMenuItem(value: 'custom', child: Text('Custom')),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => unit = v);
                        },
                      ),
                      const SizedBox(height: 8),
                      if (unit == 'weekly' || unit == 'monthly' || unit == 'custom') ...[
                        Row(
                          children: [
                            const Text('Every'),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 56,
                              child: TextField(
                                decoration: const InputDecoration(isDense: true),
                                keyboardType: TextInputType.number,
                                controller: TextEditingController(text: interval.toString()),
                                onChanged: (v) {
                                  final parsed = int.tryParse(v) ?? 1;
                                  setState(() => interval = parsed.clamp(1, 365));
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(unit == 'weekly'
                                ? 'week(s)'
                                : unit == 'monthly'
                                    ? 'month(s)'
                                    : 'period(s)'),
                          ],
                        ),
                      ],
                      if (unit == 'weekly' || unit == 'custom') ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          children: weekdayLabels.entries.map((e) {
                            final selected = selectedWeekdays.contains(e.key);
                            return FilterChip(
                              label: Text(e.value),
                              selected: selected,
                              onSelected: (val) {
                                setState(() {
                                  if (val) {
                                    selectedWeekdays.add(e.key);
                                  } else {
                                    selectedWeekdays.remove(e.key);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Send reminder at this time'),
                        value: remind,
                        onChanged: (val) {
                          setState(() => remind = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      // If there are goals, let user pick one. If none, inform a "General" goal will be created.
                      if (category.goals.isNotEmpty)
                        DropdownButtonFormField<String>(
                          value: chosenGoalId,
                          items: category.goals.map((g) => DropdownMenuItem(value: g.id, child: Text(g.title))).toList(),
                          onChanged: (v) => setState(() => chosenGoalId = v),
                          decoration: const InputDecoration(labelText: 'Attach to goal'),
                        )
                      else
                        const Text(
                          'No goals in this category. A "General" goal will be created and the habit will be added there.',
                          style: TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  TextButton(
                      onPressed: () {
                        final name = controller.text.trim();
                        if (name.isEmpty) return;
                        // If no goal selected and category has no goals, create a default goal
                        if (chosenGoalId == null) {
                          final newGoal = Goal(id: _uuid.v4(), title: 'General');
                          context.read<AppProvider>().addGoal(categoryId, newGoal.title);
                          // retrieve the newly created goal id
                          final g = context.read<AppProvider>().categories.firstWhere((c) => c.id == categoryId).goals.last;
                          chosenGoalId = g.id;
                        }
                        final days = (unit == 'weekly' || unit == 'custom') ? selectedWeekdays.toList() : null;
                        final habit = Habit(
                          id: _uuid.v4(),
                          name: name,
                          frequencyUnit: unit,
                          frequencyInterval: interval,
                          frequencyWeekdays: days,
                          timeOfDay: '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                          remind: remind,
                        );
                        context.read<AppProvider>().addHabit(categoryId, chosenGoalId!, habit);
                        if (remind) {
                          context.read<AppProvider>().scheduleReminder(
                                habit.id,
                                selectedTime,
                                frequency: unit == 'custom' ? 'weekly' : unit,
                                weekdays: days,
                              );
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Add'))
                ],
              );
            }));
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final category = app.categories.firstWhere((c) => c.id == widget.categoryId);
    final sortedGoals = [...category.goals]..sort((a, b) => b.priority.compareTo(a.priority));

    return Scaffold(
      appBar: AppBar(
        title: Text(category.title),
        backgroundColor: Colors.transparent,
        actions: [
          // Top-level Add Habit for the category — automatically attaches to the category (chooses a goal or creates General)
          IconButton(
            tooltip: 'Add habit to this category',
            onPressed: () => _showAddHabitDialog(context, category.id),
            icon: const Icon(Icons.add_circle_outline),
          ),
          IconButton(
            tooltip: 'Add Goal',
            onPressed: () => _showAddGoalDialog(context, category.id),
            icon: const Icon(Icons.add_box),
          ),
        ],
      ),
      drawer: const Drawer(
        child: SafeArea(
          child: HomeDrawerPlaceholder(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Goals list
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color.fromARGB(255, 58, 55, 55), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Goals', style: TextStyle(fontSize: 18, color: Colors.tealAccent)),
                      ElevatedButton.icon(
                        onPressed: () => _showAddGoalDialog(context, category.id),
                        icon: const Icon(Icons.add, color: Colors.black),
                        label: const Text('New Goal', style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent),
                      )
                    ]),
                    const SizedBox(height: 8),
                    Expanded(
                      child: sortedGoals.isEmpty
                          ? const Center(child: Text('No goals yet. Add one.', style: TextStyle(color: Colors.white70)))
                          : ListView.builder(
                              itemCount: sortedGoals.length,
                              itemBuilder: (context, i) {
                                final goal = sortedGoals[i];
                                final Color priorityColor;
                                switch (goal.priority) {
                                  case 3:
                                    priorityColor = Colors.redAccent;
                                    break;
                                  case 1:
                                    priorityColor = Colors.greenAccent;
                                    break;
                                  default:
                                    priorityColor = Colors.amberAccent;
                                }
                                return Card(
                                  color: Colors.white10,
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(color: priorityColor, width: 4),
                                      ),
                                    ),
                                    child: ExpansionTile(
                                    tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    title: Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('${goal.habits.length} habit(s)'),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (v) {
                                        if (v == 'edit') _showEditGoalDialog(context, category.id, goal);
                                        if (v == 'delete') {
                                          showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                    title: const Text('Delete Goal?'),
                                                    content: Text('Delete "${goal.title}" and its habits?'),
                                                    actions: [
                                                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                                      TextButton(
                                                          onPressed: () {
                                                            context.read<AppProvider>().deleteGoal(category.id, goal.id);
                                                            Navigator.pop(context);
                                                          },
                                                          child: const Text('Delete'))
                                                    ],
                                                  ));
                                        }
                                      },
                                      itemBuilder: (_) => const [
                                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                                      ],
                                    ),
                                    children: [
                                      if (goal.habits.isEmpty)
                                        const ListTile(title: Text('No habits yet. Add one below.', style: TextStyle(color: Colors.white60))),
                                      ...goal.habits.map((h) => Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: HabitTile(
                                              categoryId: category.id,
                                              goalId: goal.id,
                                              goalPriority: goal.priority,
                                              habit: h,
                                            ),
                                          )),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                                        child: Row(
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: () => _showAddHabitDialog(context, category.id, preselectedGoalId: goal.id),
                                              icon: const Icon(Icons.add, color: Colors.black),
                                              label: const Text('Add Habit', style: TextStyle(color: Colors.black)),
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ));
                              },
                            ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.popUntil(context, ModalRoute.withName('/'));
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.home, size: 40),
      ),
      bottomNavigationBar: const ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomAppBar(
          height: 70,
          color: Colors.white,
          shape: const CircularNotchedRectangle(),
          notchMargin: 6.0,
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                SizedBox(width: 32),
                SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Minimal placeholder used in the Category drawer since the full drawer is implemented in HomeScreen.
/// You can replace this with the real drawer widget if you prefer.
class HomeDrawerPlaceholder extends StatelessWidget {
  const HomeDrawerPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Column(
      children: [
        const DrawerHeader(child: Text('Categories', style: TextStyle(fontSize: 20, color: Colors.tealAccent))),
        Expanded(
          child: ListView.builder(
            itemCount: app.categories.length,
            itemBuilder: (context, i) {
              final c = app.categories[i];
              return ListTile(
                title: Text(c.title),
                subtitle: Text('${c.goals.length} goal(s)'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/category', arguments: {'id': c.id});
                },
              );
            },
          ),
        ),
      ],
    );
  }
}