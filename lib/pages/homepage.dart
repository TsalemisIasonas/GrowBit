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
  final _myBox = Hive.box("GrowBit_Database");
  int _selectedIndex = 0;

  @override
  void initState() {
    // Check if this is the very first time running the app
    if (_myBox.get("CURRENT_HABIT_LIST") == null) {
      // This is the first time ever, create default data
      db.createDefaultData();
    }
    // Load the data, which will now find the default list
    db.loadData();
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
      IconData habitIconData = db.getIconForCategory(selectedCategory);
      db.todaysHabitList.add([habitName, false, selectedCategory, habitIconData]);
    });
    _newHabitNameController.clear();
    db.updateDatabase();
  }

  void cancelDialogBox() {
    _newHabitNameController.clear();
    Navigator.of(context).pop();
  }

// Inside _HomePageState
// Make sure to replace your existing openHabitSettings method with this one
  void openHabitSettings(int index) {
    // Get the current habit to pre-populate the dialog
    final currentHabit = db.todaysHabitList[index];

    _newHabitNameController.text = currentHabit[0];

    showDialog(
      context: context,
      builder: (context) {
        return MyAlertBox(
          controller: _newHabitNameController,
          initialHabitName: currentHabit[0],
          // FIX: Check if the habit has a category (length > 2) before passing it
          initialCategory: currentHabit.length > 2 ? currentHabit[2] : 'other',
          onSave: (habitName, selectedCategory) {
            saveExistingHabit(index, habitName, selectedCategory);
          },
          onCancel: cancelDialogBox,
        );
      },
    );
  }

// And replace your existing saveExistingHabit method with this one
  void saveExistingHabit(int index, String newHabitName, String newCategory) {
  Navigator.of(context).pop();

  // Get the new icon based on the category the user selected
  final IconData newIconData = db.getIconForCategory(newCategory);

  setState(() {
    // 1. Update the name
    db.todaysHabitList[index][0] = newHabitName;

    // 2. Check if the list already has a category and icon field
    if (db.todaysHabitList[index].length >= 4) {
      db.todaysHabitList[index][2] = newCategory; // Update category at index 2
      db.todaysHabitList[index][3] = newIconData; // Update icon at index 3
    } else if (db.todaysHabitList[index].length == 3) {
      // If it has a category but no icon, update category and add icon
      db.todaysHabitList[index][2] = newCategory;
      db.todaysHabitList[index].add(newIconData);
    } else {
      // If it's a very old habit (length < 3), add both category and icon
      db.todaysHabitList[index].add(newCategory);
      db.todaysHabitList[index].add(newIconData);
    }
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
        actions: [
          _selectedIndex == 0
              ? IconButton(
                  onPressed: createNewHabit,
                  icon: const Icon(
                    Icons.add,
                    size: 35,
                  ),
                  color: darkGreenColor)
              : const SizedBox.shrink()
        ],
        title: Row(
          children: [
            Icon(Icons.check_rounded, color: darkGreenColor, size: 35),
            const SizedBox(width: 5),
            const Text(
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // Height of the line
          child: Container(
            height: 0.2,
            color: Colors.black, // Color of the line
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 239, 230, 230),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.show_chart), label: 'Progress'),
            BottomNavigationBarItem(
                icon: Icon(Icons.pie_chart), label: 'Stats'),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: darkGreenColor,
          unselectedItemColor: const Color.fromARGB(255, 30, 34, 38)),
    );
  }
}
