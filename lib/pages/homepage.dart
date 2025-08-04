import 'package:flutter/material.dart';
import 'package:habit_tracker/components/my_fab.dart';
import 'package:habit_tracker/components/my_alert_box.dart';
import 'package:habit_tracker/data/habit_database.dart';
import 'package:habit_tracker/constants/colors.dart'; // Ensure this file exists and defines 'backgroundColor'
import 'package:habit_tracker/pages/homepage_body.dart';
import 'package:habit_tracker/pages/my_progress_page.dart';
import 'package:habit_tracker/pages/my_stats_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HabitDatabase db = HabitDatabase();
  final _myBox = Hive.box("Habit_Database");
  
  // FIX: This is now a state variable for the BottomNavigationBar.
  int _selectedIndex = 0;

  // FIX: The list of pages is now initialized at declaration.
  // This is the most reliable way to ensure it is always ready.
  late final List<Widget> _pages = [
    HomepageBody(
      db: db,
      checkBoxTapped: checkBoxTapped,
      openHabitSettings: openHabitSettings,
      deleteHabit: deleteHabit,
    ),
    MyProgressPage(
      db: db,
      myBox: _myBox,
    ),
    const MyStatsPage(),
  ];

  @override
  void initState() {
    // Check if it's the first time running the app
    if (_myBox.get("CURRENT_HABIT_LIST") == null) {
      db.createDefaultData();
    } else {
      db.loadData();
    }
    // Update the database to save any changes
    db.updateDatabase();
    super.initState();
  }

  // Handle a checkbox tap
  void checkBoxTapped(bool? value, int index) {
    setState(() {
      db.todaysHabitList[index][1] = value;
    });
    db.updateDatabase();
  }

  // Controller for the new habit text field
  final _newHabitNameController = TextEditingController();

  // Show a dialog box to create a new habit
  void createNewHabit() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MyAlertBox(
          controller: _newHabitNameController,
          onSave: saveNewHabit,
          onCancel: cancelDialogBox,
        );
      },
    );
  }

  // Save a new habit from the alert box
  void saveNewHabit() {
    // Navigate away from the dialog before updating state
    Navigator.of(context).pop();
    setState(() {
      db.todaysHabitList.add([_newHabitNameController.text, false]);
    });
    _newHabitNameController.clear();
    db.updateDatabase();
  }

  // Close the dialog box and clear the text field
  void cancelDialogBox() {
    _newHabitNameController.clear();
    Navigator.of(context).pop();
  }

  // Show a dialog to edit an existing habit
  void openHabitSettings(int index) {
    _newHabitNameController.text = db.todaysHabitList[index][0];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MyAlertBox(
          controller: _newHabitNameController,
          onSave: () => saveExistingHabit(index),
          onCancel: cancelDialogBox,
        );
      },
    );
  }

  // Save the updated habit name
  void saveExistingHabit(int index) {
    Navigator.of(context).pop();
    setState(() {
      db.todaysHabitList[index][0] = _newHabitNameController.text;
    });
    _newHabitNameController.clear();
    db.updateDatabase();
  }

  // Delete a habit from the list
  void deleteHabit(int index) {
    setState(() {
      db.todaysHabitList.removeAt(index);
    });
    db.updateDatabase();
  }

  // The method to handle the BottomNavigationBar tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Assuming 'backgroundColor' is defined in 'constants/colors.dart'.
    // If not, you can define it here, e.g., final backgroundColor = Colors.grey[200];
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: MyFloatingActionButton(onPressed: createNewHabit),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Row(
          children: [
            Icon(Icons.check_rounded, color: Colors.green),
            SizedBox(width: 10),
            Text(
              "GrowBit",
              style: TextStyle(
                fontSize: 25,
                color: Colors.black,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Stats'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}