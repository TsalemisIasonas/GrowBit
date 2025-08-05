import 'package:flutter/material.dart';
//import 'package:habit_tracker/components/my_fab.dart';
import 'package:habit_tracker/components/my_alert_box.dart';
import 'package:habit_tracker/data/habit_database.dart';
import 'package:habit_tracker/constants/colors.dart'; 
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
  
  int _selectedIndex = 0;


  @override
  void initState() {
    if (_myBox.get("CURRENT_HABIT_LIST") == null) {
      db.createDefaultData();
    } else {
      db.loadData();
    }
    db.updateDatabase();
    super.initState();
  }

void checkBoxTapped(bool? value, int index) {
  print("Checkbox tapped. Current value: ${db.todaysHabitList[index][1]}");

  setState(() {
    List<dynamic> newTodaysHabitList = List.from(db.todaysHabitList);
    newTodaysHabitList[index][1] = value;
    db.todaysHabitList = newTodaysHabitList;
  });

  print("Value after setState: ${db.todaysHabitList[index][1]}");
  db.updateDatabase();
}
  
  final _newHabitNameController = TextEditingController();

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

  void saveNewHabit() {
    Navigator.of(context).pop();
    setState(() {
      db.todaysHabitList.add([_newHabitNameController.text, false]);
    });
    _newHabitNameController.clear();
    db.updateDatabase();
  }

  void cancelDialogBox() {
    _newHabitNameController.clear();
    Navigator.of(context).pop();
  }

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

  void saveExistingHabit(int index) {
    Navigator.of(context).pop();
    setState(() {
      db.todaysHabitList[index][0] = _newHabitNameController.text;
    });
    _newHabitNameController.clear();
    db.updateDatabase();
  }

  void deleteHabit(int index) {
    setState(() {
      db.todaysHabitList.removeAt(index);
    });
    db.updateDatabase();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
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
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        shadowColor: Colors.black,
        actions: [IconButton(onPressed: createNewHabit, icon: const Icon(Icons.add), color: Colors.blue,)],
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