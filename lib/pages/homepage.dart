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

// Handle a checkbox tap
void checkBoxTapped(bool? value, int index) {
  // Use setState to trigger a UI rebuild
  setState(() {
    // FIX: Change the type of this variable to List<List<dynamic>>
    List<List<dynamic>> newTodaysHabitList = List.from(db.todaysHabitList);

    // Update the specific item in the new list
    newTodaysHabitList[index][1] = value;

    // Assign the new list back to the database object
    db.todaysHabitList = newTodaysHabitList;
  });

  // Now, update the persistent database
  db.updateDatabase();
}
  
  final _newHabitNameController = TextEditingController();

// Inside _HomePageState
void createNewHabit() {
  showDialog(
    context: context,
    builder: (context) {
      return MyAlertBox(
        controller: _newHabitNameController,
        // FIX: The onSave callback now accepts the selectedCategory string
        onSave: (habitName, selectedCategory) {
          saveNewHabit(habitName, selectedCategory);
        },
        onCancel: cancelDialogBox,
      );
    },
  );
}

// FIX: Update the saveNewHabit function to accept the selectedCategory
void saveNewHabit(String habitName, String selectedCategory) {
  Navigator.of(context).pop();
  setState(() {
    // FIX: Add the selectedCategory to the new habit list
    db.todaysHabitList.add([habitName, false, selectedCategory]);
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
    builder: (context) {
      return MyAlertBox(
        controller: _newHabitNameController,
        // FIX: Pass the existing habit's name and category to the dialog
        initialHabitName: db.todaysHabitList[index][0],
        initialCategory: db.todaysHabitList[index][2],
        // FIX: The onSave callback now calls the new saveExistingHabit function
        onSave: (habitName, selectedCategory) {
          saveExistingHabit(index, habitName, selectedCategory);
        },
        onCancel: cancelDialogBox,
      );
    },
  );
}

// FIX: The method now accepts the new habit name AND the new category
void saveExistingHabit(int index, String newHabitName, String newCategory) {
  Navigator.of(context).pop();
  setState(() {
    // FIX: Update both the name (index 0) and the category (index 2)
    db.todaysHabitList[index][0] = newHabitName;
    db.todaysHabitList[index][2] = newCategory;
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
      MyStatsPage(db: db),
    ];
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        shadowColor: Colors.black,
        actions: [IconButton(onPressed: createNewHabit, icon: const Icon(Icons.add), color: Colors.blue,)],
        title: const Row(
          children: [
            Icon(Icons.check_rounded, color: Color.fromARGB(255, 79, 243, 84)),
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
        selectedItemColor: Colors.blue,
        unselectedItemColor: const Color.fromARGB(255, 22, 57, 88)
      ),
    );
  }
}