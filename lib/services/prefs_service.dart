import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const String _welcomeKey = 'welcome_seen';
  static const String _userNameKey = 'user_name';
  static const String _dailyNotificationKey = 'daily_notification_enabled';
  static const String _onboardingV2Key = 'onboarding_v2_seen';
  static const String _notificationHourKey = 'daily_notification_hour';
  static const String _notificationMinuteKey = 'daily_notification_minute';

  static Future<void> saveWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomeKey, true);
    await prefs.setBool(_onboardingV2Key, true);
  }

  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final legacySeen = prefs.getBool(_welcomeKey) ?? false;
    final onboardingV2Seen = prefs.getBool(_onboardingV2Key) ?? false;
    // Show onboarding if this new version hasn't been seen yet.
    return !onboardingV2Seen || !legacySeen;
  }

  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  static Future<String?> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<void> resetWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_welcomeKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_dailyNotificationKey);
    await prefs.remove(_onboardingV2Key);
    await prefs.remove(_notificationHourKey);
    await prefs.remove(_notificationMinuteKey);
  }

  static Future<bool> isDailyNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dailyNotificationKey) ?? true;
  }

  static Future<void> setDailyNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyNotificationKey, enabled);
  }

  static Future<TimeOfDay> loadReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_notificationHourKey) ?? 20;
    final minute = prefs.getInt(_notificationMinuteKey) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static Future<void> saveReminderTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_notificationHourKey, time.hour);
    await prefs.setInt(_notificationMinuteKey, time.minute);
  }
}
