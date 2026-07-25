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

  test('persists all supported languages', () async {
    for (final language in AppLanguage.values) {
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

  test('falls back to English for invalid persisted values', () async {
    SharedPreferences.setMockInitialValues({LanguagePreferences.storageKey: 'xx'});
    expect(await LanguagePreferences.load(), AppLanguage.english);
  });
}
