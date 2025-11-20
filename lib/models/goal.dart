import 'dart:convert';
import 'habit.dart';

class Goal {
  String id;
  String title;
  List<Habit> habits;
  String createdAt;
  int priority; // 1..3 (1=low,3=high)

  Goal({
    required this.id,
    required this.title,
    List<Habit>? habits,
    String? createdAt,
    this.priority = 2,
  })  : habits = habits ?? [],
        createdAt = createdAt ?? DateTime.now().toUtc().toIso8601String();

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'habits': habits.map((h) => h.toMap()).toList(),
        'createdAt': createdAt,
      'priority': priority,
      };

  factory Goal.fromMap(Map<String, dynamic> m) => Goal(
        id: m['id'],
        title: m['title'],
        habits: (m['habits'] as List<dynamic>? ?? []).map((e) => Habit.fromMap(Map<String, dynamic>.from(e))).toList(),
      createdAt: m['createdAt'],
      priority: m['priority'] ?? 2,
      );

  String toJson() => json.encode(toMap());
  factory Goal.fromJson(String s) => Goal.fromMap(json.decode(s));
}