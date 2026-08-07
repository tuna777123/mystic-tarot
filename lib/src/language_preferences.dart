import 'package:shared_preferences/shared_preferences.dart';

import 'app_language.dart';

class LanguagePreferences {
  const LanguagePreferences._();

  static const storageKey = 'app_language';
  static const legacyStorageKey = 'language';

  static AppLanguage _parse(String? value) {
    if (value == null) return AppLanguage.english;
    final normalized = value.trim().toLowerCase();
    for (final language in AppLanguage.launchValues) {
      if (language.name.toLowerCase() == normalized ||
          language.localeTag.toLowerCase() == normalized) {
        return language;
      }
    }
    return AppLanguage.english;
  }

  static Future<AppLanguage> load() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getString(storageKey);
    if (current != null) {
      final resolved = _parse(current);
      if (resolved.localeTag.toLowerCase() != current.trim().toLowerCase()) {
        await prefs.setString(storageKey, resolved.localeTag);
      }
      return resolved;
    }

    final migrated = _parse(prefs.getString(legacyStorageKey));
    await prefs.setString(storageKey, migrated.localeTag);
    return migrated;
  }

  static Future<void> save(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    final safeLanguage = language.isLaunchReady
        ? language
        : AppLanguage.english;
    await prefs.setString(storageKey, safeLanguage.localeTag);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }
}
