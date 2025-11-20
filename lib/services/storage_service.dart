import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';

class StorageService {
  static const _key = 'goals_app_data';

  Future<void> saveAll(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final list = categories.map((c) => c.toMap()).toList();
    prefs.setString(_key, json.encode(list));
  }

  Future<List<Category>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_key);
    if (s == null || s.isEmpty) return [];
    final List<dynamic> list = json.decode(s);
    return list.map((m) => Category.fromMap(Map<String, dynamic>.from(m))).toList();
  }
}