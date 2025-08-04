import 'package:flutter/material.dart';

class MyAlertBox extends StatelessWidget {

  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const MyAlertBox({super.key, required this.controller, required this.onSave, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Habit", style: TextStyle(color: Colors.white),),
      backgroundColor: Colors.grey[800],
      content: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Enter Habit Name",
          hintStyle: TextStyle(color: Colors.white54),
        ),
      ),
      actions: [
        TextButton(
          onPressed: onSave,
          child: const Text("Save", style: TextStyle(color: Colors.green)),
        ),
        TextButton(
          onPressed: onCancel,
          child: const Text("Cancel", style: TextStyle(color: Colors.red)),
        )
      ],
    );
  }
}
