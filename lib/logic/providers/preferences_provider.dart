import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/prefs_service.dart';

final dailyNotificationProvider = FutureProvider<bool>(
  (ref) async => PrefsService.isDailyNotificationEnabled(),
);

final reminderTimeProvider = FutureProvider<TimeOfDay>(
  (ref) async => PrefsService.loadReminderTime(),
);
