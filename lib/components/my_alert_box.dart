import 'package:flutter/material.dart';

class MyAlertBox extends StatelessWidget {

  final controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const MyAlertBox({super.key, required this.controller, required this.onSave, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Habit", style: TextStyle(color: Colors.white),),
      backgroundColor: Colors.grey[900],
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
        MaterialButton(
          onPressed: onSave,
          color: Colors.black,
          child: const Text("Save", style: TextStyle(color: Colors.white)),
        ),
        MaterialButton(
          onPressed: onCancel,
          color: Colors.black,
          child: const Text("Cancel", style: TextStyle(color: Colors.white)),
        )
      ],
    );
  }
}
