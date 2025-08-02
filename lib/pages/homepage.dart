import 'package:flutter/material.dart';
import 'package:habit_tracker/components/habit_tile.dart';
import 'package:habit_tracker/components/month_summary.dart';
import 'package:habit_tracker/components/my_fab.dart';
import 'package:habit_tracker/components/my_alert_box.dart';
import 'package:habit_tracker/data/habit_database.dart';
import 'package:habit_tracker/constants/colors.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HabitDatabase db = HabitDatabase();
  final _myBox = Hive.box("Habit_Database");

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
    setState(() {
      db.todaysHabitList[index][1] =
          value; // update the state of habitCompleted
    });
    db.updateDatabase();
  } // checkbox was tapped

  final _newHabitNameController = TextEditingController();
  void createNewHabit() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MyAlertBox(
            controller: _newHabitNameController,
            onSave: saveNewHabit,
            onCancel: cancelDialogBox);
      },
    );
  } // create a new habit

  void saveNewHabit() {
    setState(() {
      db.todaysHabitList.add([_newHabitNameController.text, false]);
    });
    _newHabitNameController.clear();
    Navigator.of(context).pop(); // close the dialog
    db.updateDatabase();
  }

  void cancelDialogBox() {
    _newHabitNameController.clear();
    Navigator.of(context).pop();
  }

  openHabitSettings(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return MyAlertBox(
            controller: _newHabitNameController,
            onSave: () => saveExistingHabit(index),
            onCancel: cancelDialogBox,
          );
        });
  }

  void saveExistingHabit(int index) {
    setState(() {
      db.todaysHabitList[index][0] = _newHabitNameController.text;
      _newHabitNameController.clear();
      Navigator.of(context).pop(); // close the dialog
    });
    db.updateDatabase();
  }

  void deleteHabit(int index) {
    setState(() {
      db.todaysHabitList.removeAt(index);
    });
    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: MyFloatingActionButton(onPressed: createNewHabit),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.2, 0.95],
          ),
        ),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.2,
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: const Border(
                  bottom: BorderSide(
                    color: Color.fromARGB(255, 86, 77, 77),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "GrowBit",
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                  const Center(
                    child: Text(
                      "Build your Habits",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w200,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            MonthlySummary(
                datasets: db.heatMapDataSet,
                startdate: _myBox.get("START_DATE")),
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  //physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return HabitTile(
                      habitName: db.todaysHabitList[index][0],
                      habitCompleted: db.todaysHabitList[index][1],
                      onChanged: (value) => checkBoxTapped(value, index),
                      settingsTapped: ((context) {
                        openHabitSettings(index);
                      }),
                      deleteTapped: (context) => deleteHabit(index),
                    );
                  },
                  itemCount: db.todaysHabitList.length),
            ),
          ],
        ),
      ),
    );
  }
}
