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
      backgroundColor: Colors.blue[100],
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.2,
        child: Column(
          children: [
            TextField(
              controller: widget.controller,
              decoration: const InputDecoration(
                hintText: "Enter a new habit",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              iconEnabledColor: Colors.blue,
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
        TextButton(
          onPressed: widget.onCancel,
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.red),
          ),
        ),
        TextButton(
          onPressed: () {
            widget.onSave(widget.controller.text, _selectedCategory!);
          },
          child: const Text(
            "Save",
            style: TextStyle(color: Colors.green),
          ),
        ),
        
      ],
    );
  }
}