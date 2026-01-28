import 'dart:convert';
import 'package:flutter/material.dart';
import 'goal.dart';

class Category {
  String id;
  String title;
  List<Goal> goals;
  bool deleted;
  int? iconCodePoint; // Store icon as codePoint

  Category({
    required this.id,
    required this.title,
    List<Goal>? goals,
    this.deleted = false,
    this.iconCodePoint,
  }) : goals = goals ?? [];

  // Helper to get IconData from codePoint
  IconData? get icon => iconCodePoint != null 
      ? IconData(iconCodePoint!, fontFamily: 'MaterialIcons') 
      : null;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'goals': goals.map((g) => g.toMap()).toList(),
        'deleted': deleted,
        'iconCodePoint': iconCodePoint,
      };

  factory Category.fromMap(Map<String, dynamic> m) => Category(
        id: m['id'],
        title: m['title'],
        goals: (m['goals'] as List<dynamic>? ?? []).map((e) => Goal.fromMap(Map<String, dynamic>.from(e))).toList(),
        deleted: m['deleted'] ?? false,
        iconCodePoint: m['iconCodePoint'] as int?,
      );

  String toJson() => json.encode(toMap());
  factory Category.fromJson(String source) => Category.fromMap(json.decode(source));
}