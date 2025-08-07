import 'package:flutter/material.dart';
import 'package:habit_tracker/pages/homepage.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // initialize hive
  await Hive.initFlutter();

  //open a box
  await Hive.openBox("GrowBit_Database");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 78, 171,
              247), 
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
