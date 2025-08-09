import 'package:flutter/material.dart';

// Enum for your defined categories
enum HabitCategory {
  health,
  mindfulness,
  productivity,
  creative,
  other,
}

// Map to store category-specific data
final Map<HabitCategory, Map<String, dynamic>> categoryData = {
  HabitCategory.health: {
    'name': 'Health',
    'icon': Icons.favorite,
  },
  HabitCategory.mindfulness: {
    'name': 'Mindfulness',
    'icon': Icons.self_improvement,
  },
  HabitCategory.productivity: {
    'name': 'Productivity',
    'icon': Icons.work,
  },
  HabitCategory.creative: {
    'name': 'Creative',
    'icon': Icons.brush,
  },
  HabitCategory.other: {
    'name': 'Other',
    'icon': Icons.category,
  },
};