import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/flagship.dart';

void main() {
  test('application language model exposes all seven languages', () {
    expect(MysticLanguage.values.length, 7);
    expect(MysticLanguage.values.map((item) => item.label), containsAll(<String>[
      'English',
      'Español',
      'Français',
      'Português (Brasil)',
      'Türkçe',
      'Italiano',
      'Deutsch',
    ]));
  });

  test('core launch languages render their own navigation copy', () {
    expect(mysticText(MysticLanguage.english, 'Read', 'Oku'), 'Read');
    expect(mysticText(MysticLanguage.turkish, 'Read', 'Oku'), 'Oku');
    expect(mysticText(MysticLanguage.spanish, 'Read', 'Oku'), 'Leer');
    expect(
      mysticText(MysticLanguage.portugueseBrazil, 'Read', 'Oku'),
      'Ler',
    );
  });

  test('languages not yet launched continue to fall back safely', () {
    for (final language in <MysticLanguage>[
      MysticLanguage.french,
      MysticLanguage.italian,
      MysticLanguage.german,
    ]) {
      expect(mysticText(language, 'Read', 'Oku'), 'Read');
    }
  });
}
