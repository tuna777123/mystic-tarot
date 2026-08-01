import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/app_language.dart';
import 'package:mystic_tarot/src/language_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to English', () async {
    expect(await LanguagePreferences.load(), AppLanguage.english);
  });

  test('persists every launch-ready language', () async {
    for (final language in AppLanguage.launchValues) {
      await LanguagePreferences.save(language);
      expect(await LanguagePreferences.load(), language);
    }
  });

  test('migrates legacy Turkish setting', () async {
    SharedPreferences.setMockInitialValues({'language': 'turkish'});
    expect(await LanguagePreferences.load(), AppLanguage.turkish);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(LanguagePreferences.storageKey), 'tr');
  });

  test('migrates incomplete German and Italian selections to English', () async {
    for (final value in <String>['de', 'german', 'it', 'italian']) {
      SharedPreferences.setMockInitialValues({
        LanguagePreferences.storageKey: value,
      });
      expect(await LanguagePreferences.load(), AppLanguage.english);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(LanguagePreferences.storageKey), 'en');
    }
  });

  test('refuses to persist an incomplete language programmatically', () async {
    await LanguagePreferences.save(AppLanguage.german);
    expect(await LanguagePreferences.load(), AppLanguage.english);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(LanguagePreferences.storageKey), 'en');
  });

  test('falls back to English for invalid persisted values', () async {
    SharedPreferences.setMockInitialValues({
      LanguagePreferences.storageKey: 'xx',
    });
    expect(await LanguagePreferences.load(), AppLanguage.english);
  });
}
