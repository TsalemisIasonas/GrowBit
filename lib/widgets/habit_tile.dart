import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/app_provider.dart';

class HabitTile extends StatelessWidget {
  final String categoryId;
  final String goalId;
  final int goalPriority;
  final Habit habit;
  const HabitTile({super.key, required this.categoryId, required this.goalId, required this.goalPriority, required this.habit});

  bool _isCompletedToday(Habit h) {
    final today = DateTime.now().toUtc();
    final key = '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return h.activitiesByDate.containsKey(key) && h.activitiesByDate[key]!.isNotEmpty || h.lastCompletedDate == key;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppProvider>();
    final completed = _isCompletedToday(habit);
    final Color priorityColor = () {
      switch (goalPriority) {
        case 3:
          return Colors.redAccent;
        case 1:
          return Colors.greenAccent;
        default:
          return Colors.amberAccent;
      }
    }();
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
      leading: Icon(Icons.circle, color: priorityColor, size: 12),
      title: Text(habit.name),
      subtitle: Text('Streak: ${habit.streak}'),
      trailing: Wrap(spacing: 8, children: [
        IconButton(
          icon: Icon(completed ? Icons.check_circle : Icons.radio_button_unchecked, color: completed ? Colors.greenAccent : Colors.white54),
          onPressed: () async {
            await app.recordHabitCompletion(categoryId, goalId, habit.id, note: 'Completed at ${TimeOfDay.now().format(context)}');
            if (habit.suggestedIncrease) {
              int chosen = habit.priority.clamp(1, 3);
              showDialog(
                  context: context,
                  builder: (_) => StatefulBuilder(builder: (ctx, setState) {
                        return AlertDialog(
                          title: const Text('Adjust difficulty'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Your habit "${habit.name}" has a ${habit.streak}-day streak.'),
                              const SizedBox(height: 8),
                              const Text('Choose a new priority (1-3):'),
                              const SizedBox(height: 8),
                              DropdownButton<int>(
                                value: chosen,
                                items: const [
                                  DropdownMenuItem(value: 1, child: Text('1 (Low)')),
                                  DropdownMenuItem(value: 2, child: Text('2 (Medium)')),
                                  DropdownMenuItem(value: 3, child: Text('3 (High)')),
                                ],
                                onChanged: (v) {
                                  if (v == null) return;
                                  setState(() => chosen = v);
                                },
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Later')),
                            TextButton(
                                onPressed: () {
                                  app.editHabit(categoryId, goalId, habit.id, priority: chosen);
                                  habit.suggestedIncrease = false;
                                  app.persist();
                                  Navigator.pop(ctx);
                                },
                                child: const Text('Save'))
                          ],
                        );
                      }));
            }
          },
        ),
        PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'delete') {
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: const Text('Delete Habit?'),
                        content: Text('Delete "${habit.name}"?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          TextButton(
                              onPressed: () {
                                app.deleteHabit(categoryId, goalId, habit.id);
                                Navigator.pop(context);
                              },
                              child: const Text('Delete'))
                        ],
                      ));
            } else if (v == 'rename') {
              final c = TextEditingController(text: habit.name);
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: const Text('Rename Habit'),
                        content: TextField(controller: c),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          TextButton(
                              onPressed: () {
                                final v = c.text.trim();
                                if (v.isNotEmpty) app.editHabit(categoryId, goalId, habit.id, name: v);
                                Navigator.pop(context);
                              },
                              child: const Text('Save'))
                        ],
                      ));
            } else if (v == 'remind') {
              _showScheduleDialog(context, app);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'rename', child: Text('Rename')),
            PopupMenuItem(value: 'remind', child: Text('Schedule / reminder')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ]),
    );
  }

  void _showScheduleDialog(BuildContext context, AppProvider app) {
    // Start with existing values if present
    TimeOfDay selectedTime;
    if (habit.timeOfDay != null && habit.timeOfDay!.contains(':')) {
      final parts = habit.timeOfDay!.split(':');
      final h = int.tryParse(parts[0]) ?? 9;
      final m = int.tryParse(parts[1]) ?? 0;
      selectedTime = TimeOfDay(hour: h, minute: m);
    } else {
      selectedTime = TimeOfDay.now();
    }

    String unit = habit.frequencyUnit; // 'daily' | 'weekly' | 'monthly' | 'custom'
    int interval = habit.frequencyInterval; // for weekly/monthly/custom
    final Map<int, String> weekdayLabels = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };
    final Set<int> selectedWeekdays = {...?habit.frequencyWeekdays};
    bool remind = habit.remind;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('When do you do this?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('Time:'),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        final t = await showTimePicker(context: ctx, initialTime: selectedTime);
                        if (t != null) {
                          setState(() => selectedTime = t);
                        }
                      },
                      child: Text(selectedTime.format(ctx)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // High-level pattern choice
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
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final days = (unit == 'weekly' || unit == 'custom')
                      ? selectedWeekdays.toList()
                      : null;

                  habit.frequencyUnit = unit;
                  habit.frequencyInterval = interval;
                  habit.frequencyWeekdays = days;
                  habit.timeOfDay = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                  habit.remind = remind;
                  app.persist();

                  if (remind) {
                    app.scheduleReminder(habit.id, selectedTime,
                        frequency: unit == 'custom' ? 'weekly' : unit,
                        weekdays: days);
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }
}