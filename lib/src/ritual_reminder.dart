import 'package:shared_preferences/shared_preferences.dart';

import 'flagship.dart';

const ritualReminderNotificationId = 1307;

class RitualReminderSettings {
  const RitualReminderSettings({
    required this.enabled,
    required this.hour,
    required this.minute,
    required this.promptCompleted,
    required this.languageCode,
  });

  const RitualReminderSettings.defaults()
    : enabled = false,
      hour = 20,
      minute = 0,
      promptCompleted = false,
      languageCode = 'en';

  final bool enabled;
  final int hour;
  final int minute;
  final bool promptCompleted;
  final String languageCode;

  RitualReminderSettings copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    bool? promptCompleted,
    String? languageCode,
  }) => RitualReminderSettings(
    enabled: enabled ?? this.enabled,
    hour: _safeHour(hour ?? this.hour),
    minute: _safeMinute(minute ?? this.minute),
    promptCompleted: promptCompleted ?? this.promptCompleted,
    languageCode: languageCode ?? this.languageCode,
  );

  String get formattedTime =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  static int _safeHour(int value) => value.clamp(0, 23).toInt();
  static int _safeMinute(int value) => value.clamp(0, 59).toInt();
}

class RitualReminderStore {
  static const _enabledKey = 'ritual_reminder_enabled';
  static const _hourKey = 'ritual_reminder_hour';
  static const _minuteKey = 'ritual_reminder_minute';
  static const _promptCompletedKey = 'ritual_reminder_prompt_completed';
  static const _languageCodeKey = 'ritual_reminder_language_code';

  Future<RitualReminderSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return RitualReminderSettings(
      enabled: prefs.getBool(_enabledKey) ?? false,
      hour: (prefs.getInt(_hourKey) ?? 20).clamp(0, 23).toInt(),
      minute: (prefs.getInt(_minuteKey) ?? 0).clamp(0, 59).toInt(),
      promptCompleted: prefs.getBool(_promptCompletedKey) ?? false,
      languageCode: prefs.getString(_languageCodeKey) ?? 'en',
    );
  }

  Future<void> save(RitualReminderSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setBool(_enabledKey, settings.enabled),
      prefs.setInt(_hourKey, settings.hour),
      prefs.setInt(_minuteKey, settings.minute),
      prefs.setBool(_promptCompletedKey, settings.promptCompleted),
      prefs.setString(_languageCodeKey, settings.languageCode),
    ]);
  }
}

enum RitualReminderPermissionResult { granted, denied, unsupported, failed }

class RitualReminderCopy {
  const RitualReminderCopy({
    required this.title,
    required this.body,
    required this.channelName,
    required this.channelDescription,
  });

  final String title;
  final String body;
  final String channelName;
  final String channelDescription;

  static RitualReminderCopy forLanguage(
    MysticLanguage language,
  ) => switch (language) {
    MysticLanguage.turkish => const RitualReminderCopy(
      title: 'Günlük ritüelin seni bekliyor',
      body: 'Bir kart aç, bugünün duygusunu kaydet ve örüntünü büyüt.',
      channelName: 'Günlük Mystic ritüeli',
      channelDescription: 'Seçtiğin saatte nazik günlük tarot hatırlatıcıları.',
    ),
    MysticLanguage.spanish => const RitualReminderCopy(
      title: 'Tu ritual diario te espera',
      body:
          'Revela una carta, registra cómo te sientes y deja crecer tu patrón.',
      channelName: 'Ritual diario Mystic',
      channelDescription: 'Recordatorios suaves de tarot a la hora que elijas.',
    ),
    MysticLanguage.french => const RitualReminderCopy(
      title: 'Votre rituel quotidien vous attend',
      body:
          'Révélez une carte, notez votre émotion et laissez votre schéma grandir.',
      channelName: 'Rituel quotidien Mystic',
      channelDescription: 'Rappels de tarot discrets à l’heure choisie.',
    ),
    MysticLanguage.portugueseBrazil => const RitualReminderCopy(
      title: 'Seu ritual diário está esperando',
      body: 'Revele uma carta, registre sua emoção e deixe seu padrão crescer.',
      channelName: 'Ritual diário Mystic',
      channelDescription:
          'Lembretes suaves de tarô no horário que você escolher.',
    ),
    _ => const RitualReminderCopy(
      title: 'Your daily ritual is waiting',
      body: 'Reveal one card, record how you feel, and let your pattern grow.',
      channelName: 'Daily Mystic ritual',
      channelDescription: 'Gentle tarot reminders at the time you choose.',
    ),
  };
}

MysticLanguage ritualReminderLanguageFromCode(String code) {
  switch (code.toLowerCase()) {
    case 'tr':
      return MysticLanguage.turkish;
    case 'es':
      return MysticLanguage.spanish;
    case 'fr':
      return MysticLanguage.french;
    case 'pt-br':
    case 'pt_br':
    case 'pt':
      return MysticLanguage.portugueseBrazil;
    default:
      return MysticLanguage.english;
  }
}

DateTime nextRitualReminderTime({
  required DateTime now,
  required int hour,
  required int minute,
}) {
  var next = DateTime(now.year, now.month, now.day, hour, minute);
  if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
  return next;
}

TimeOfDaySuggestion suggestedRitualTime(DateTime now) {
  if (now.hour < 12) return const TimeOfDaySuggestion(hour: 20, minute: 0);
  if (now.hour < 18) return const TimeOfDaySuggestion(hour: 20, minute: 30);
  return const TimeOfDaySuggestion(hour: 21, minute: 0);
}

class TimeOfDaySuggestion {
  const TimeOfDaySuggestion({required this.hour, required this.minute});

  final int hour;
  final int minute;
}
