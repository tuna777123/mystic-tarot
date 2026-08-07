import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'flagship.dart';
import 'ritual_reminder.dart';

class RitualReminderService {
  RitualReminderService._();

  static final RitualReminderService instance = RitualReminderService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get isSupported => Platform.isAndroid || Platform.isIOS;

  Future<void> initialize() async {
    if (_initialized || !isSupported) return;
    try {
      tz.initializeTimeZones();
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
      );
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  Future<RitualReminderPermissionResult> requestPermission() async {
    if (!isSupported) return RitualReminderPermissionResult.unsupported;
    await initialize();
    if (!_initialized) return RitualReminderPermissionResult.failed;
    try {
      if (Platform.isAndroid) {
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
        return granted == true
            ? RitualReminderPermissionResult.granted
            : RitualReminderPermissionResult.denied;
      }
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: false, sound: true);
      return granted == true
          ? RitualReminderPermissionResult.granted
          : RitualReminderPermissionResult.denied;
    } catch (_) {
      return RitualReminderPermissionResult.failed;
    }
  }

  Future<bool> scheduleDaily({
    required RitualReminderSettings settings,
    required MysticLanguage language,
  }) async {
    if (!isSupported || !settings.enabled) return false;
    await initialize();
    if (!_initialized) return false;
    final copy = RitualReminderCopy.forLanguage(language);
    final scheduled = _nextOccurrence(settings.hour, settings.minute);
    try {
      await _plugin.cancel(ritualReminderNotificationId);
      await _plugin.zonedSchedule(
        ritualReminderNotificationId,
        copy.title,
        copy.body,
        scheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'mystic_daily_ritual',
            copy.channelName,
            channelDescription: copy.channelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            category: AndroidNotificationCategory.reminder,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'daily_ritual',
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> cancel() async {
    if (!isSupported) return;
    await initialize();
    if (!_initialized) return;
    try {
      await _plugin.cancel(ritualReminderNotificationId);
    } catch (_) {
      // A disabled reminder must never block the rest of the app.
    }
  }

  tz.TZDateTime _nextOccurrence(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    return next;
  }
}
