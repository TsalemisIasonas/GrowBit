import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:async';

// Add this import near top of file to support tz use
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
  }

  Future<void> showSuggestionNotification({required String title, required String body}) async {
    const android = AndroidNotificationDetails('suggestions', 'Suggestions', importance: Importance.high);
    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);
    await _plugin.show(DateTime.now().millisecondsSinceEpoch ~/ 1000, title, body, details);
  }

  Future<void> scheduleReminder(
    String habitId,
    TimeOfDay time, {
    required String frequency, // 'daily', 'weekly', 'monthly', 'custom'
    List<int>? weekdays, // for 'custom' weekly patterns, 1=Mon..7=Sun
  }) async {
    await _ensureTz();

    final now = DateTime.now();
    final baseToday = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    tz.TZDateTime nextInstance(DateTime from) {
      return tz.TZDateTime.from(from, tz.local);
    }

    tz.TZDateTime first;

    if (frequency == 'daily') {
      var scheduled = baseToday;
      if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
      first = nextInstance(scheduled);
      await _plugin.zonedSchedule(
        habitId.hashCode,
        'Habit Reminder',
        'Time for your habit',
        first,
        const NotificationDetails(
          android: AndroidNotificationDetails('reminders', 'Reminders', importance: Importance.defaultImportance),
          iOS: DarwinNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      return;
    }

    if (frequency == 'weekly') {
      // Every week on the same weekday as "now" at the chosen time
      final targetWeekday = now.weekday; // 1=Mon..7=Sun
      var scheduled = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      while (scheduled.weekday != targetWeekday || scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      first = nextInstance(scheduled);
      await _plugin.zonedSchedule(
        habitId.hashCode,
        'Habit Reminder',
        'Time for your habit',
        first,
        const NotificationDetails(
          android: AndroidNotificationDetails('reminders', 'Reminders', importance: Importance.defaultImportance),
          iOS: DarwinNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
      return;
    }

    if (frequency == 'monthly') {
      var scheduled = baseToday;
      if (scheduled.isBefore(now)) {
        scheduled = DateTime(now.year, now.month + 1, baseToday.day, time.hour, time.minute);
      }
      first = nextInstance(scheduled);
      await _plugin.zonedSchedule(
        habitId.hashCode,
        'Habit Reminder',
        'Time for your habit',
        first,
        const NotificationDetails(
          android: AndroidNotificationDetails('reminders', 'Reminders', importance: Importance.defaultImportance),
          iOS: DarwinNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        // No built-in monthly component; this fires once. In a real app, you'd reschedule on each fire.
      );
      return;
    }

    if (frequency == 'custom' && weekdays != null && weekdays.isNotEmpty) {
      // For simplicity, schedule the next upcoming selected weekday at the chosen time.
      var scheduled = baseToday;
      while (!weekdays.contains(scheduled.weekday) || scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      first = nextInstance(scheduled);
      await _plugin.zonedSchedule(
        habitId.hashCode,
        'Habit Reminder',
        'Time for your habit',
        first,
        const NotificationDetails(
          android: AndroidNotificationDetails('reminders', 'Reminders', importance: Importance.defaultImportance),
          iOS: DarwinNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        // No direct multi-weekdays; as with monthly, you'd normally manage repeats yourself.
      );
      return;
    }
  }
}


extension on NotificationService {
  Future<void> _ensureTz() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
  }

  Future<void> _zonedInit() async {
    await _ensureTz();
  }
}

// Ensure timezone is initialized in init
extension InitWithTz on NotificationService {
  Future<void> _initWithTz() async {
    tzdata.initializeTimeZones();
  }
}