import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart'; // For kDebugMode

// Timezone imports
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize the service
  /// Call this in main() before runApp()
  Future<void> init() async {
    // 1. Initialize Timezones safely
    await _configureLocalTimeZone();

    // 2. Setup Android Settings
    // Ensure '@mipmap/ic_launcher' exists in android/app/src/main/res/mipmap-*/
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. Setup iOS Settings
    final ios = DarwinInitializationSettings(
      requestAlertPermission: false, // We request these later
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        if (kDebugMode) {
          print('Notification Tapped: ${details.payload}');
        }
      },
    );

    // 4. Request Permissions (Critical for Android 13+ & iOS)
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final androidImplementation =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // Request Notification Permission (Android 13+)
      await androidImplementation?.requestNotificationsPermission();

      // Request Exact Alarm Permission (Android 12+)
      // Note: This is separate from showing notifications
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  /// Configures the timezone.
  /// Includes a fallback to UTC if the local name is incompatible with the TZ package.
  Future<void> _configureLocalTimeZone() async {
    tzdata.initializeTimeZones();
    try {
      // Note: DateTime.now().timeZoneName is sometimes incompatible (e.g. "EST").
      // Ideally, use the 'flutter_timezone' package for accurate IANA IDs.
      final String timeZoneName = DateTime.now().timeZoneName;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      if (kDebugMode) {
        print('Could not find location for timezone: $e. Defaulting to UTC.');
      }
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  Future<void> showSuggestionNotification(
      {required String title, required String body}) async {
    const android = AndroidNotificationDetails(
      'suggestions',
      'Suggestions',
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);

    await _plugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000, title, body, details);
  }

  Future<void> scheduleReminder(
    String habitId,
    TimeOfDay time, {
    required String frequency, // 'daily', 'weekly', 'monthly', 'custom'
    List<int>? weekdays, // 1=Mon..7=Sun
    String? habitName,
    String? goalTitle,
  }) async {
    // Safety check for permissions before scheduling
    if (Platform.isAndroid) {
      final androidImplementation =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final bool? granted =
          await androidImplementation?.requestExactAlarmsPermission();
      if (granted == false) {
        print('Exact alarms permission denied. Cannot schedule.');
        return;
      }
    }

    final now = DateTime.now();
    // Create a generic date for today with the specific time
    final baseToday =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);

    tz.TZDateTime nextInstance(DateTime from) {
      return tz.TZDateTime.from(from, tz.local);
    }

    tz.TZDateTime? scheduledDate;

    // --- FREQUENCY LOGIC ---

    if (frequency == 'daily') {
      var target = baseToday;
      if (target.isBefore(now)) target = target.add(const Duration(days: 1));
      scheduledDate = nextInstance(target);
    } else if (frequency == 'weekly') {
      var target = baseToday;
      // If today is past the time, or if today is not the target day (logic below handles next week)
      // Note: This simplistic logic assumes we just want "next instance of this time"
      // If you strictly want "Same day of week":
      while (target.isBefore(now)) {
        target = target.add(const Duration(days: 7));
      }
      scheduledDate = nextInstance(target);
    } else if (frequency == 'monthly') {
      var target = baseToday;
      if (target.isBefore(now)) {
        target = DateTime(
            now.year, now.month + 1, baseToday.day, time.hour, time.minute);
      }
      scheduledDate = nextInstance(target);
    } else if (frequency == 'custom' &&
        weekdays != null &&
        weekdays.isNotEmpty) {
      var target = baseToday;
      // Find the next matching weekday
      while (!weekdays.contains(target.weekday) || target.isBefore(now)) {
        target = target.add(const Duration(days: 1));
      }
      scheduledDate = nextInstance(target);
    }

    if (scheduledDate != null) {
      final notificationTitle = habitName ?? 'Habit Reminder';
      final notificationBody = goalTitle ?? 'Time for your habit';
      
      await _plugin.zonedSchedule(
        habitId.hashCode,
        notificationTitle,
        notificationBody,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders',
            'Reminders',
            channelDescription: 'Notifications for habit reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: frequency == 'daily'
            ? DateTimeComponents.time
            : frequency == 'weekly'
                ? DateTimeComponents.dayOfWeekAndTime
                : DateTimeComponents
                    .time, // Monthly/Custom usually require manual rescheduling
      );
      if (kDebugMode) {
        print('Scheduled notification for: $scheduledDate');
      }
    }
  }
}
