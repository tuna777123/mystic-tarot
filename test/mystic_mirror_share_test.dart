import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/mystic_mirror_share.dart';

void main() {
  test(
    'all launch-language Mirror shares are generic and public-link based',
    () {
      const languages = <MysticLanguage>[
        MysticLanguage.english,
        MysticLanguage.turkish,
        MysticLanguage.spanish,
        MysticLanguage.french,
        MysticLanguage.portugueseBrazil,
      ];

      for (final language in languages) {
        final text = mysticMirrorShareText(language);
        expect(text, contains(mysticPublicUrl));
        expect(text.toLowerCase(), contains('mystic'));
        expect(text.length, lessThan(420));
      }
    },
  );

  test('share helper has no API for private reading content', () {
    final text = mysticMirrorShareText(MysticLanguage.english).toLowerCase();
    expect(text, isNot(contains('question:')));
    expect(text, isNot(contains('note:')));
    expect(text, isNot(contains('card:')));
    expect(text, isNot(contains('emotion:')));
    expect(text, isNot(contains('outcome:')));
  });
}
