import 'package:habit_tracker/datetime/date_time.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_tracker/constants/category_data.dart'; // Import your new categories file

// reference our box
final _myBox = Hive.box("Habit_Database");

class HabitDatabase {
  List<List<dynamic>> todaysHabitList = []; // Updated type for clarity
  Map<DateTime, int> heatMapDataSet = {};

  // create initial default data
  void createDefaultData() {
    todaysHabitList = [
      // Habits now include a category string
      ["Run", false, "health"],
      ["Read", false, "mindfulness"],
    ];
    _myBox.put("START_DATE", startDateFormatted());
  }

  // load data if it already exists
  void loadData() {
    // if it's a new day, get habit list from database
    if (_myBox.get(todaysDateFormatted()) == null) {
      todaysHabitList = _myBox.get("CURRENT_HABIT_LIST")?.cast<List<dynamic>>() ?? [];
      // set all habit completed to false since it's a new day
      for (int i = 0; i < todaysHabitList.length; i++) {
        todaysHabitList[i][1] = false;
      }
    }
    // if it's not a new day, load todays list
    else {
      todaysHabitList = _myBox.get(todaysDateFormatted())?.cast<List<dynamic>>() ?? [];
    }
  }

  // update database
  void updateDatabase() {
    // update todays entry
    _myBox.put(todaysDateFormatted(), todaysHabitList);

    // update universal habit list in case it changed (new habit, edit habit, delete habit)
    _myBox.put("CURRENT_HABIT_LIST", todaysHabitList);

    // calculate habit complete percentages for each day
    calculateHabitPercentages();

    // load heat map
    loadHeatMap();
  }

  void calculateHabitPercentages() {
    int countCompleted = 0;
    for (int i = 0; i < todaysHabitList.length; i++) {
      if (todaysHabitList[i][1] == true) {
        countCompleted++;
      }
    }

    String percent = todaysHabitList.isEmpty
        ? '0.0'
        : (countCompleted / todaysHabitList.length).toStringAsFixed(1);

    // key: "PERCENTAGE_SUMMARY_yyyymmdd"
    // value: string of 1dp number between 0.0-1.0 inclusive
    _myBox.put("PERCENTAGE_SUMMARY_${todaysDateFormatted()}", percent);
  }

  void loadHeatMap() {
    DateTime startDate = createDateTimeObject(_myBox.get("START_DATE"));

    // count the number of days to load
    int daysInBetween = DateTime.now().difference(startDate).inDays;

    // go from start date to today and add each percentage to the dataset
    // "PERCENTAGE_SUMMARY_yyyymmdd" will be the key in the database
    for (int i = 0; i < daysInBetween + 1; i++) {
      String yyyymmdd = convertDateTimeToString(
        startDate.add(Duration(days: i)),
      );

      double strengthAsPercent = double.parse(
        _myBox.get("PERCENTAGE_SUMMARY_$yyyymmdd") ?? "0.0",
      );

      // year
      int year = startDate.add(Duration(days: i)).year;
      // month
      int month = startDate.add(Duration(days: i)).month;
      // day
      int day = startDate.add(Duration(days: i)).day;

      final percentForEachDay = <DateTime, int>{
        DateTime(year, month, day): (10 * strengthAsPercent).toInt(),
      };

      heatMapDataSet.addEntries(percentForEachDay.entries);
    }
  }

  // Calculate the overall completion percentage and return it as a double
  double getOverallCompletionPercentage() {
    double totalPercentage = 0.0;
    int dayCount = 0;

    for (final key in _myBox.keys) {
      if (key.startsWith("PERCENTAGE_SUMMARY_")) {
        String? percentString = _myBox.get(key);
        if (percentString != null) {
          totalPercentage += double.tryParse(percentString) ?? 0.0;
          dayCount++;
        }
      }
    }
    if (dayCount == 0) {
      return 0.0;
    }
    return totalPercentage / dayCount;
  }

  // display the value as a string for UI text
  String getOverallCompletion() {
    double overallCompletion = getOverallCompletionPercentage() * 100;
    return "${overallCompletion.toStringAsFixed(0)}%";
  }
  
  // Calculate category completion counts for the radar chart
  Map<HabitCategory, int> getCategoryCompletionData() {
    final Map<HabitCategory, int> categoryCounts = {
      for (var category in HabitCategory.values) category: 0,
    };

    // Get the universal habit list from the database
    final List<List<dynamic>> currentHabitList = _myBox.get("CURRENT_HABIT_LIST")?.cast<List<dynamic>>() ?? [];

    for (final habit in currentHabitList) {
      final String categoryString = habit[2];
      final HabitCategory category = HabitCategory.values.firstWhere(
        (e) => e.toString().split('.').last == categoryString,
        orElse: () => HabitCategory.other,
      );
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }
    return categoryCounts;
  }
}