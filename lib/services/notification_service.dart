import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'prefs_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _dailyReminderId = 1001;
  static const String _channelId = 'daily_reminder_channel';
  static const String _channelName = 'Daily Budget Reminders';
  static const String _channelDescription =
      'Reminder to log your expenses every evening.';

  static bool _initialized = false;
  static tz.Location? _eatLocation;

  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);

    // Request runtime permissions where required (iOS prompts, Android handled via manifest).
    if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    tz_data.initializeTimeZones();
    _eatLocation = tz.getLocation('Africa/Addis_Ababa');

    _initialized = true;
  }

  static Future<void> scheduleDailyReminder({
    int hour = 20,
    int minute = 0,
  }) async {
    await initialize();
    final location = _eatLocation ?? tz.getLocation('Africa/Addis_Ababa');
    final scheduledDate = _nextReminderTime(location, hour, minute);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    await _plugin.zonedSchedule(
      _dailyReminderId,
      'YegnaBudget',
      'Don\'t forget to add your expenses today!',
      scheduledDate,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleDailyReminderIfEnabled() async {
    final prefs = await PrefsService.loadReminderTime();
    final enabled = await PrefsService.isDailyNotificationEnabled();
    if (enabled) {
      await scheduleDailyReminder(hour: prefs.hour, minute: prefs.minute);
    } else {
      await cancelDailyReminder();
    }
  }

  static Future<void> cancelDailyReminder() async {
    await initialize();
    await _plugin.cancel(_dailyReminderId);
  }

  static tz.TZDateTime _nextReminderTime(
    tz.Location location,
    int hour,
    int minute,
  ) {
    final now = tz.TZDateTime.now(location);
    var scheduled = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
