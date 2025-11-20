import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../models/goal.dart';
import '../models/habit.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final _uuid = const Uuid();

  List<Category> categories = [];

  Future<void> load() async {
    final saved = await _storage.loadAll();
    if (saved.isNotEmpty) {
      categories = saved;
    } else {
      // Seed demo data with new structure
      categories = [
        Category(id: 'cat_health', title: 'Health', goals: [
          Goal(id: 'g1', title: 'Improve my physical condition', habits: [
            Habit(id: 'h1', name: 'Run 20 minutes'),
            Habit(id: 'h2', name: 'Stretching'),
          ]),
        ]),
        Category(id: 'cat_productivity', title: 'Productivity', goals: [
          Goal(id: 'g2', title: 'Ship features weekly', habits: [
            Habit(id: 'h3', name: 'Plan day'),
            Habit(id: 'h4', name: 'Deep work 90m'),
          ]),
        ]),
      ];
      await persist();
    }
    notifyListeners();
  }

  Future<void> persist() async {
    await _storage.saveAll(categories);
  }

  // Category CRUD
  void addCategory(String title) {
    final c = Category(id: _uuid.v4(), title: title);
    categories.add(c);
    persist();
    notifyListeners();
  }

  void editCategory(String categoryId, String newTitle) {
    final c = categories.firstWhere((e) => e.id == categoryId);
    c.title = newTitle;
    persist();
    notifyListeners();
  }

  void deleteCategory(String categoryId) {
    categories.removeWhere((c) => c.id == categoryId);
    persist();
    notifyListeners();
  }

  // Goal CRUD
  void addGoal(String categoryId, String title, {int priority = 2}) {
    final c = categories.firstWhere((e) => e.id == categoryId);
    c.goals.add(Goal(id: _uuid.v4(), title: title, priority: priority));
    persist();
    notifyListeners();
  }

  void editGoal(String categoryId, String goalId, String newTitle) {
    final g = categories
        .firstWhere((c) => c.id == categoryId)
        .goals
        .firstWhere((g) => g.id == goalId);
    g.title = newTitle;
    persist();
    notifyListeners();
  }

  void deleteGoal(String categoryId, String goalId) {
    final c = categories.firstWhere((c) => c.id == categoryId);
    c.goals.removeWhere((g) => g.id == goalId);
    persist();
    notifyListeners();
  }

  // Habit CRUD (nested under goal)
  void addHabit(String categoryId, String goalId, Habit habit) {
    final g = categories.firstWhere((c) => c.id == categoryId).goals.firstWhere((g) => g.id == goalId);
    g.habits.add(habit);
    persist();
    notifyListeners();
  }

  void editHabit(String categoryId, String goalId, String habitId, {String? name, int? priority}) {
    final h = categories
        .firstWhere((c) => c.id == categoryId)
        .goals
        .firstWhere((g) => g.id == goalId)
        .habits
        .firstWhere((h) => h.id == habitId);
    if (name != null) h.name = name;
    if (priority != null) h.priority = priority;
    persist();
    notifyListeners();
  }

  void deleteHabit(String categoryId, String goalId, String habitId) {
    final g = categories.firstWhere((c) => c.id == categoryId).goals.firstWhere((g) => g.id == goalId);
    g.habits.removeWhere((h) => h.id == habitId);
    persist();
    notifyListeners();
  }

  // Convenience: add a habit to a category (automatically use first goal or create a "General" goal)
  // This implements the behavior you asked: creating a habit from the category screen will add it to that category.
  Future<void> addHabitToCategory(String categoryId, Habit habit, {String defaultGoalTitle = 'General'}) async {
    final c = categories.firstWhere((cat) => cat.id == categoryId);
    if (c.goals.isEmpty) {
      // create a default goal and add the habit
      final newGoal = Goal(id: _uuid.v4(), title: defaultGoalTitle, habits: [habit]);
      c.goals.add(newGoal);
    } else {
      // add to first goal by default
      c.goals.first.habits.add(habit);
    }
    await persist();
    notifyListeners();
  }

  // Record completion for a habit, respecting its logical frequency
  Future<void> recordHabitCompletion(String categoryId, String goalId, String habitId, {String note = ''}) async {
    final h = categories
        .firstWhere((c) => c.id == categoryId)
        .goals
        .firstWhere((g) => g.id == goalId)
        .habits
        .firstWhere((x) => x.id == habitId);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());

    if (h.lastCompletedDate == today) {
      if (note.isNotEmpty) {
        h.activitiesByDate.putIfAbsent(today, () => []).add(note);
      }
    } else {
      // Streak logic based on habit schedule (frequencyUnit & interval)
      final now = DateTime.now().toUtc();
      DateTime? last;
      if (h.lastCompletedDate.isNotEmpty) {
        last = DateFormat('yyyy-MM-dd').parseUtc(h.lastCompletedDate);
      }

      bool continuesStreak = false;
      if (last == null) {
        continuesStreak = false;
      } else {
        final diffDays = now.difference(last).inDays;
        if (h.frequencyUnit == 'daily') {
          continuesStreak = diffDays == h.frequencyInterval;
        } else if (h.frequencyUnit == 'weekly') {
          continuesStreak = diffDays == 7 * h.frequencyInterval;
        } else if (h.frequencyUnit == 'monthly') {
          // very approximate: next month on the same day
          continuesStreak = (now.year == last.year && now.month == last.month + h.frequencyInterval && now.day == last.day);
        }
      }

      if (continuesStreak) {
        h.streak += 1;
      } else {
        h.streak = 1;
      }
      h.lastCompletedDate = today;
      h.activitiesByDate.putIfAbsent(today, () => []);
      if (note.isNotEmpty) h.activitiesByDate[today]!.add(note);

      // Suggest increasing difficulty when user has been very consistent (e.g. 90% over last 10 periods)
      if (!h.suggestedIncrease && _isHighConsistency(h)) {
        h.suggestedIncrease = true;
        await NotificationService().showSuggestionNotification(
          title: 'Time to up the challenge?',
          body: 'Your habit "${h.name}" has been done ${h.streak} days. Consider increasing difficulty.',
        );
      }
    }
    await persist();
    notifyListeners();
  }

  // Simple consistency check: if in the last 10 expected periods, user completed at least 9.
  bool _isHighConsistency(Habit h) {
    final now = DateTime.now().toUtc();
    int periods = 10;
    int completed = 0;

    for (int i = 0; i < periods; i++) {
      DateTime expected;
      if (h.frequencyUnit == 'daily') {
        expected = now.subtract(Duration(days: h.frequencyInterval * i));
      } else if (h.frequencyUnit == 'weekly') {
        expected = now.subtract(Duration(days: 7 * h.frequencyInterval * i));
      } else {
        expected = DateTime(now.year, now.month - h.frequencyInterval * i, now.day);
      }
      final key = DateFormat('yyyy-MM-dd').format(expected);
      if (h.activitiesByDate.containsKey(key) && h.activitiesByDate[key]!.isNotEmpty) {
        completed++;
      }
    }

    if (periods == 0) return false;
    final ratio = completed / periods;
    return ratio >= 0.9;
  }

  // Aggregated map over all habits for heatmaps / home
  Map<String, int> aggregatedActivityMap({int days = 90}) {
    final Map<String, int> map = {};
    for (int i = 0; i < days; i++) {
      final date = DateTime.now().toUtc().subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      map[key] = 0;
    }
    for (final c in categories) {
      for (final g in c.goals) {
        for (final h in g.habits) {
          h.activitiesByDate.forEach((k, v) {
            if (map.containsKey(k)) map[k] = map[k]! + v.length;
          });
        }
      }
    }
    return map;
  }

  // Per-habit activity map for heatmaps
  Map<String, int> habitActivityMap(String categoryId, String habitId,
      {int days = 90}) {
    final Map<String, int> map = {};

    for (int i = 0; i < days; i++) {
      final date = DateTime.now().toUtc().subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      map[key] = 0;
    }

    for (final c in categories) {
      if (c.id != categoryId) continue;
      for (final g in c.goals) {
        for (final h in g.habits) {
          if (h.id != habitId) continue;
          h.activitiesByDate.forEach((k, v) {
            if (map.containsKey(k)) {
              map[k] = v.length;
            }
          });
        }
      }
    }

    return map;
  }

  // Most recently completed habits (limit)
  List<Map<String, dynamic>> recentCompletions({int limit = 8}) {
    final List<Map<String, dynamic>> list = [];
    for (final c in categories) {
      for (final g in c.goals) {
        for (final h in g.habits) {
          if (h.lastCompletedDate.isNotEmpty) {
            list.add({
              'categoryId': c.id,
              'categoryTitle': c.title,
              'goalId': g.id,
              'goalTitle': g.title,
              'habitId': h.id,
              'habitName': h.name,
              'lastCompletedDate': h.lastCompletedDate,
            });
          }
        }
      }
    }
    list.sort((a, b) => b['lastCompletedDate'].compareTo(a['lastCompletedDate']));
    return list.take(limit).toList();
  }

  // helper to find a habit object by ids
  Habit findHabit(String categoryId, String goalId, String habitId) {
    return categories
        .firstWhere((c) => c.id == categoryId)
        .goals
        .firstWhere((g) => g.id == goalId)
        .habits
        .firstWhere((h) => h.id == habitId);
  }

  // Schedule a daily reminder notification for a habit at a given time
  Future<void> scheduleReminder(
    String habitId,
    TimeOfDay time, {
    required String frequency,
    List<int>? weekdays,
  }) async {
    await NotificationService().scheduleReminder(habitId, time, frequency: frequency, weekdays: weekdays);
  }
}