import 'flagship.dart';
import 'ritual_reminder.dart';

class RitualReminderService {
  RitualReminderService._();

  static final RitualReminderService instance = RitualReminderService._();

  bool get isSupported => false;

  Future<void> initialize() async {}

  Future<RitualReminderPermissionResult> requestPermission() async =>
      RitualReminderPermissionResult.unsupported;

  Future<bool> scheduleDaily({
    required RitualReminderSettings settings,
    required MysticLanguage language,
  }) async => false;

  Future<void> cancel() async {}
}
