import 'package:flutter/material.dart';

class MyStatsPage extends StatelessWidget {
  const MyStatsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
            padding: EdgeInsets.only(left: 15.0),
            child: Text(
              "Stats",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 25.0, top: 15.0),
            child: Text(
              "Overall Completion",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 50),
          // Center(child: ProgressGraph(db: db)),
      ],
    );
  }
} 