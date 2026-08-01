import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/app_language.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/language_bridge.dart';

void main() {
  test('every app language keeps its exact legacy rendering language', () {
    for (final language in AppLanguage.values) {
      expect(language.legacyLanguage.appLanguage, language);
    }
  });

  test('selection state preserves Brazilian Portuguese exactly', () {
    const initial = LanguageSelectionState(AppLanguage.english);
    final selected = initial.select(AppLanguage.portugueseBrazil);

    expect(selected.appLanguage, AppLanguage.portugueseBrazil);
    expect(selected.storageValue, 'pt_BR');
    expect(selected.legacyLanguage, MysticLanguage.portugueseBrazil);
  });
}
