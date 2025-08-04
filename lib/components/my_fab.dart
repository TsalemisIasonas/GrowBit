import 'package:flutter/material.dart';

class MyFloatingActionButton extends StatelessWidget {
   final Function()? onPressed;

  const MyFloatingActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.blue,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, size: 30)
      
    );
  }
}