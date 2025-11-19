import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'prefs_service.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  if (kDebugMode) {
    debugPrint('[NotificationService] Background notification tapped: ${response.payload}');
  }
  if (response.payload == 'daily_reminder') {
    NotificationService._rescheduleFromLastTime();
  }
}

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
    tz.setLocalLocation(tz.local);

    // Create Android notification channel explicitly (helps with consistency)
    if (Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
        showBadge: true,
      );
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (kDebugMode) debugPrint('[NotificationService] Notification tapped: ${response.payload}');
        if (response.payload == 'daily_reminder') {
          _rescheduleFromLastTime();
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    await _requestRuntimePermissions();
    _initialized = true;
    if (kDebugMode) debugPrint('[NotificationService] Initialized');
  }

  static Future<void> _requestRuntimePermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (kDebugMode) debugPrint('[NotificationService] Current permission status: $status');
      if (!status.isGranted) {
        final r = await Permission.notification.request();
        if (kDebugMode) debugPrint('[NotificationService] Permission request result: $r');
        if (!r.isGranted) {
          if (kDebugMode) debugPrint('[NotificationService] Permission denied, notifications may not work');
          // Optionally, show a dialog to user
        }
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
    if (!enabled) {
      if (kDebugMode) debugPrint('[NotificationService] Disabled, skipping schedule');
      return;
    }
    final time = await PrefsService.loadReminderTime();
    await scheduleDailyReminder(hour: time.hour, minute: time.minute);
  }

  static Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    await initialize();
    await _plugin.cancel(_dailyId);

    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (next.isBefore(now)) next = next.add(const Duration(days: 1));

    if (kDebugMode) {
      debugPrint('[NotificationService] Scheduling daily reminder at $next (local tz)');
    }

    await PrefsService.saveReminderTime(TimeOfDay(hour: hour, minute: minute));

    await _plugin.zonedSchedule(
      _dailyId,
      'YegnaBudget',
      "Don't forget to add your expenses today!",
      next,
      _silentDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_reminder',
    );

    if (kDebugMode) debugPrint('[NotificationService] Reminder scheduled for $next');
  }

  static Future<void> _rescheduleFromLastTime() async {
    final time = await PrefsService.loadReminderTime();
    await scheduleDailyReminder(hour: time.hour, minute: time.minute);
  }

  static Future<void> cancelDailyReminder() async {
    await initialize();
    await _plugin.cancel(_dailyId);
    if (kDebugMode) debugPrint('[NotificationService] Reminder canceled');
  }

  // Fallback: call this from app start to show in-app hint if missed
  static Future<bool> shouldShowInAppReminder() async {
    final enabled = await PrefsService.isDailyNotificationEnabled();
    if (!enabled) return false;
    final time = await PrefsService.loadReminderTime();
    final now = DateTime.now();
    if (now.hour > time.hour || (now.hour == time.hour && now.minute >= time.minute)) {
      // Could check last expense date here
      return true;
    }
    return false;
  }

  // Test method: Show a notification immediately (for debugging)
  static Future<void> showTestNotification() async {
    await initialize();
    await _plugin.show(
      9999, // Unique ID for test
      'YegnaBudget Test',
      'This is a test notification to check if notifications work.',
      _silentDetails(),
      payload: 'test',
    );
    if (kDebugMode) debugPrint('[NotificationService] Test notification shown');
  }

  // Check if notifications are enabled and permissions granted
  static Future<bool> areNotificationsEnabled() async {
    await initialize();
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      return status.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.notification.status;
      return status.isGranted;
    }
    return false;
  }
}