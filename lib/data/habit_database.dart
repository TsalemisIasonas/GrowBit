import 'package:habit_tracker/datetime/date_time.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_tracker/constants/category_data.dart';

// reference our box
final _myBox = Hive.box("Growbit_Database");

class HabitDatabase {
  List<List<dynamic>> todaysHabitList = [];
  Map<DateTime, int> heatMapDataSet = {};

  // create initial default data
  void createDefaultData() {
    todaysHabitList = [
      ["Run", false, "health"],
      ["Read", false, "mindfulness"],
    ];
    _myBox.put("START_DATE", startDateFormatted());
    // FIX: Save the default list to the database
    _myBox.put("CURRENT_HABIT_LIST", todaysHabitList);
  }

  // load data if it already exists
  void loadData() {
    if (_myBox.get(todaysDateFormatted()) == null) {
      todaysHabitList = _myBox.get("CURRENT_HABIT_LIST")?.cast<List<dynamic>>() ?? [];
      for (int i = 0; i < todaysHabitList.length; i++) {
        todaysHabitList[i][1] = false;
      }
    } else {
      todaysHabitList = _myBox.get(todaysDateFormatted())?.cast<List<dynamic>>() ?? [];
    }
  }

  // update database
  void updateDatabase() {
    _myBox.put(todaysDateFormatted(), todaysHabitList);
    _myBox.put("CURRENT_HABIT_LIST", todaysHabitList);
    calculateHabitPercentages();
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

    _myBox.put("PERCENTAGE_SUMMARY_${todaysDateFormatted()}", percent);
  }

  void loadHeatMap() {
    final startDateString = _myBox.get("START_DATE");
    if (startDateString == null) return;

    DateTime startDate = createDateTimeObject(startDateString);

    int daysInBetween = DateTime.now().difference(startDate).inDays;

    for (int i = 0; i < daysInBetween + 1; i++) {
      String yyyymmdd = convertDateTimeToString(
        startDate.add(Duration(days: i)),
      );

      double strengthAsPercent = double.parse(
        _myBox.get("PERCENTAGE_SUMMARY_$yyyymmdd") ?? "0.0",
      );

      int year = startDate.add(Duration(days: i)).year;
      int month = startDate.add(Duration(days: i)).month;
      int day = startDate.add(Duration(days: i)).day;

      final percentForEachDay = <DateTime, int>{
        DateTime(year, month, day): (10 * strengthAsPercent).toInt(),
      };

      heatMapDataSet.addEntries(percentForEachDay.entries);
    }
  }

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

  String getOverallCompletion() {
    double overallCompletion = getOverallCompletionPercentage() * 100;
    return "${overallCompletion.toStringAsFixed(0)}%";
  }
  
  Map<HabitCategory, int> getCategoryCompletionData() {
    final Map<HabitCategory, int> categoryCounts = {
      for (var category in HabitCategory.values) category: 0,
    };
    
    final List<List<dynamic>> currentHabitList = _myBox.get("CURRENT_HABIT_LIST")?.cast<List<dynamic>>() ?? [];

    for (final habit in currentHabitList) {
      HabitCategory category;
      if (habit.length > 2) {
        final String categoryString = habit[2];
        category = HabitCategory.values.firstWhere(
          (e) => e.toString().split('.').last == categoryString,
          orElse: () => HabitCategory.other,
        );
      } else {
        category = HabitCategory.other;
      }
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }
    return categoryCounts;
  }
}