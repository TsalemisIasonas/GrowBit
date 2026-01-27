import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dashboard_screen.dart';
import 'stats_screen.dart';
import '../providers/app_provider.dart';
import '../models/habit.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    StatsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _showAddHabitDialog(BuildContext context) async {
    final app = context.read<AppProvider>();
    final categories = app.activeCategories;

    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a category first')),
      );
      return;
    }

    String? selectedCategoryId = categories.first.id;
    final nameController = TextEditingController();
    String frequency = 'daily';
    TimeOfDay? reminderTime;
    bool enableReminder = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Habit'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Habit name',
                    hintText: 'e.g., Morning run',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories.map((c) {
                    return DropdownMenuItem(value: c.id, child: Text(c.title));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedCategoryId = val;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: frequency,
                  decoration: const InputDecoration(labelText: 'Frequency'),
                  items: const [
                    DropdownMenuItem(value: 'daily', child: Text('Daily')),
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      frequency = val!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Enable Reminder'),
                  value: enableReminder,
                  onChanged: (val) {
                    setState(() {
                      enableReminder = val;
                    });
                  },
                ),
                if (enableReminder) ...[
                  const SizedBox(height: 8),
                  ListTile(
                    title: Text(
                      reminderTime == null
                          ? 'Select time'
                          : 'Reminder at ${reminderTime!.format(context)}',
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: reminderTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          reminderTime = time;
                        });
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty || selectedCategoryId == null) {
                  return;
                }

                final habit = Habit(
                  id: const Uuid().v4(),
                  name: name,
                  frequencyUnit: frequency,
                  remind: enableReminder,
                  timeOfDay: enableReminder && reminderTime != null
                      ? '${reminderTime!.hour.toString().padLeft(2, '0')}:${reminderTime!.minute.toString().padLeft(2, '0')}'
                      : null,
                );

                await app.addHabitToCategory(selectedCategoryId!, habit);
                Navigator.pop(context);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added habit: $name')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitDialog(context),
        backgroundColor: const Color(0xFF64FFDA),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF1A1E27),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: _selectedIndex == 0 ? const Color(0xFF64FFDA) : Colors.white54,
              ),
              onPressed: () => _onItemTapped(0),
            ),
            const SizedBox(width: 48), // Space for FAB
            IconButton(
              icon: Icon(
                Icons.bar_chart,
                color: _selectedIndex == 1 ? const Color(0xFF64FFDA) : Colors.white54,
              ),
              onPressed: () => _onItemTapped(1),
            ),
          ],
        ),
      ),
    );
  }
}
