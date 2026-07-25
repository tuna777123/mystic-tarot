import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/flagship.dart';

void main() {
  test('application language model exposes all seven languages', () {
    expect(MysticLanguage.values.length, 7);
    expect(MysticLanguage.values.map((item) => item.label), containsAll(<String>[
      'English', 'Español', 'Français', 'Português (Brasil)',
      'Türkçe', 'Italiano', 'Deutsch',
    ]));
  });

  test('legacy copy falls back to English outside Turkish', () {
    for (final language in MysticLanguage.values.where((item) => item != MysticLanguage.turkish)) {
      expect(mysticText(language, 'Read', 'Oku'), 'Read');
    }
    expect(mysticText(MysticLanguage.turkish, 'Read', 'Oku'), 'Oku');
  });
}
