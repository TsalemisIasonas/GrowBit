import 'dart:convert';
import 'goal.dart';

class Category {
  String id;
  String title;
  List<Goal> goals;

  Category({
    required this.id,
    required this.title,
    List<Goal>? goals,
  }) : goals = goals ?? [];

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'goals': goals.map((g) => g.toMap()).toList(),
      };

  factory Category.fromMap(Map<String, dynamic> m) => Category(
        id: m['id'],
        title: m['title'],
        goals: (m['goals'] as List<dynamic>? ?? []).map((e) => Goal.fromMap(Map<String, dynamic>.from(e))).toList(),
      );

  String toJson() => json.encode(toMap());
  factory Category.fromJson(String source) => Category.fromMap(json.decode(source));
}