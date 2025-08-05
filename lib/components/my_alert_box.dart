import 'package:flutter/material.dart';
import 'package:habit_tracker/constants/category_data.dart';

class MyAlertBox extends StatefulWidget {
  final VoidCallback onCancel;
  final Function(String habitName, String selectedCategory) onSave;
  final TextEditingController controller;
  // FIX: Add optional initial values for editing
  final String? initialHabitName;
  final String? initialCategory;

  const MyAlertBox({
    super.key,
    required this.controller,
    required this.onCancel,
    required this.onSave,
    this.initialHabitName,
    this.initialCategory,
  });

  @override
  State<MyAlertBox> createState() => _MyAlertBoxState();
}

class _MyAlertBoxState extends State<MyAlertBox> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // FIX: Pre-populate the text field and selected category if initial values are provided
    widget.controller.text = widget.initialHabitName ?? "";
    _selectedCategory = widget.initialCategory ?? HabitCategory.other.toString().split('.').last;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: SizedBox(
        height: 120,
        child: Column(
          children: [
            TextField(
              controller: widget.controller,
              decoration: const InputDecoration(
                hintText: "Enter a new habit",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: HabitCategory.values.map((category) {
                return DropdownMenuItem<String>(
                  value: category.toString().split('.').last,
                  child: Text(categoryData[category]!['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        MaterialButton(
          onPressed: () {
            widget.onSave(widget.controller.text, _selectedCategory!);
          },
          color: Colors.blue,
          child: const Text(
            "Save",
            style: TextStyle(color: Colors.white),
          ),
        ),
        MaterialButton(
          onPressed: widget.onCancel,
          color: Colors.red,
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}