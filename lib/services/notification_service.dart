import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'prefs_service.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _channelId = 'yegna_daily_silent_v1';
  static const _channelName = 'Daily Reminder (Silent)';
  static const _channelDesc = 'Daily budgeting reminder without sound';
  static const _dailyId = 1001;

  static Future<void> initialize() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    // Fallback to local zone (no external plugin)
    tz.setLocalLocation(tz.local);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(initSettings);

    await _requestRuntimePermissions();
    _initialized = true;
  }

  static Future<void> _requestRuntimePermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isDenied || status.isRestricted) {
        await Permission.notification.request();
      }
    }
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: false);
  }

  static NotificationDetails _silentDetails() {
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.low,
      priority: Priority.low,
      playSound: false,
      enableVibration: false,
      showWhen: true,
      category: AndroidNotificationCategory.reminder,
    );
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
      interruptionLevel: InterruptionLevel.passive,
    );
    return const NotificationDetails(android: android, iOS: ios);
  }

  static Future<void> scheduleDailyReminderIfEnabled() async {
    await initialize();
    final enabled = await PrefsService.isDailyNotificationEnabled();
    if (!enabled) return;
    final time = await PrefsService.loadReminderTime();
    await scheduleDailyReminder(hour: time.hour, minute: time.minute);
  }

  static Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    await initialize();
    await _plugin.cancel(_dailyId);

    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (next.isBefore(now)) next = next.add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      _dailyId,
      'YegnaBudget',
      "Don't forget to add your expenses today!",
      next,
      _silentDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_reminder',
    );
  }

  static Future<void> cancelDailyReminder() async {
    await initialize();
    await _plugin.cancel(_dailyId);
  }
}