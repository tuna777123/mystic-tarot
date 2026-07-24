import 'package:shared_preferences/shared_preferences.dart';

import 'app_language.dart';

class LanguagePreferences {
  const LanguagePreferences._();

  static const storageKey = 'app_language';
  static const legacyStorageKey = 'language';

  static Future<AppLanguage> load() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getString(storageKey);
    if (current != null) return AppLanguageParsing.fromStorage(current);

    final legacy = prefs.getString(legacyStorageKey);
    final migrated = AppLanguageParsing.fromStorage(legacy);
    await prefs.setString(storageKey, migrated.storageValue);
    return migrated;
  }

  static Future<void> save(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, language.storageValue);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }
}
