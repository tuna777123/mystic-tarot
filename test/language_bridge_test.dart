import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/app_language.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/language_bridge.dart';

void main() {
  test('Turkish keeps Turkish legacy rendering', () {
    expect(AppLanguage.turkish.legacyLanguage, MysticLanguage.turkish);
  });

  test('new languages use English legacy rendering during migration', () {
    for (final language in <AppLanguage>[
      AppLanguage.spanish,
      AppLanguage.french,
      AppLanguage.portugueseBrazil,
      AppLanguage.italian,
      AppLanguage.german,
    ]) {
      expect(language.legacyLanguage, MysticLanguage.english);
    }
  });

  test('selection state preserves exact seven-language choice', () {
    const initial = LanguageSelectionState(AppLanguage.english);
    final selected = initial.select(AppLanguage.portugueseBrazil);

    expect(selected.appLanguage, AppLanguage.portugueseBrazil);
    expect(selected.storageValue, 'pt-BR');
    expect(selected.legacyLanguage, MysticLanguage.english);
  });
}
