import 'package:flutter/material.dart';

// Enum for your defined categories
enum HabitCategory {
  health,
  mindfulness,
  productivity,
  creative,
  test,
  other,
}

// Map to store category-specific data
final Map<HabitCategory, Map<String, dynamic>> categoryData = {
  HabitCategory.health: {
    'name': 'Health',
    'icon': Icons.favorite,
    'color': Colors.red,
  },
  HabitCategory.mindfulness: {
    'name': 'Mindfulness',
    'icon': Icons.self_improvement,
    'color': Colors.green,
  },
  HabitCategory.productivity: {
    'name': 'Productivity',
    'icon': Icons.work,
    'color': Colors.blue,
  },
  HabitCategory.creative: {
    'name': 'Creative',
    'icon': Icons.brush,
    'color': Colors.purple,
  },
  HabitCategory.other: {
    'name': 'Other',
    'icon': Icons.category,
    'color': Colors.grey,
  },
  HabitCategory.test: {
    'name': 'Other',
    'icon': Icons.category,
    'color': Colors.grey,
  },
};