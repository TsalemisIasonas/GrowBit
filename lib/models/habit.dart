import 'dart:convert';

class Habit {
  String id;
  String name;
  int priority; // 1..3 (1=low,3=high)
  int streak; // current streak in days
  String lastCompletedDate; // ISO yyyy-MM-dd (UTC)
  Map<String, List<String>> activitiesByDate; // dateString -> list of notes (time or comment)
  bool suggestedIncrease; // whether suggestion has been shown
  // Logical schedule configuration (used both for streaks and reminders)
  String frequencyUnit; // 'daily', 'weekly', 'monthly'
  int frequencyInterval; // e.g. every 1 week, every 2 weeks
  List<int>? frequencyWeekdays; // for weekly/custom patterns (1=Mon..7=Sun)
  String? timeOfDay; // "HH:mm" in local time
  bool remind; // whether to show a notification at that time

  Habit({
    required this.id,
    required this.name,
    this.priority = 2,
    this.streak = 0,
    this.lastCompletedDate = '',
    Map<String, List<String>>? activitiesByDate,
    this.suggestedIncrease = false,
    this.frequencyUnit = 'daily',
    this.frequencyInterval = 1,
    this.frequencyWeekdays,
    this.timeOfDay,
    this.remind = false,
  }) : activitiesByDate = activitiesByDate ?? {};

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'priority': priority,
        'streak': streak,
        'lastCompletedDate': lastCompletedDate,
        'activitiesByDate': activitiesByDate,
        'suggestedIncrease': suggestedIncrease,
        'frequencyUnit': frequencyUnit,
        'frequencyInterval': frequencyInterval,
        'frequencyWeekdays': frequencyWeekdays,
        'timeOfDay': timeOfDay,
        'remind': remind,
      };

  factory Habit.fromMap(Map<String, dynamic> m) => Habit(
        id: m['id'],
        name: m['name'],
        priority: m['priority'] ?? 2,
        streak: m['streak'] ?? 0,
        lastCompletedDate: m['lastCompletedDate'] ?? '',
        activitiesByDate: (m['activitiesByDate'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, List<String>.from(v))) ?? {},
        suggestedIncrease: m['suggestedIncrease'] ?? false,
        frequencyUnit: m['frequencyUnit'] ?? 'daily',
        frequencyInterval: m['frequencyInterval'] ?? 1,
        frequencyWeekdays: (m['frequencyWeekdays'] as List<dynamic>?)?.map((e) => e as int).toList(),
        timeOfDay: m['timeOfDay'],
        remind: m['remind'] ?? false,
      );

  String toJson() => json.encode(toMap());
  factory Habit.fromJson(String s) => Habit.fromMap(json.decode(s));
}