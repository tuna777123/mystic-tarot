import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/flagship.dart';

void main() {
  test('Living Fate ships the complete Major Arcana cycle', () {
    expect(arcanaChapters, hasLength(22));

    for (final chapter in arcanaChapters) {
      expect(chapter.focusEn.trim(), isNotEmpty);
      expect(chapter.focusTr.trim(), isNotEmpty);
      expect(chapter.ritualEn.trim(), isNotEmpty);
      expect(chapter.ritualTr.trim(), isNotEmpty);
      expect(chapter.promptEn.trim(), isNotEmpty);
      expect(chapter.promptTr.trim(), isNotEmpty);
    }
  });

  test('flagship copy is localized in English and Turkish', () {
    expect(
      mysticText(MysticLanguage.english, 'Living Fate', 'Yaşayan Kader'),
      'Living Fate',
    );
    expect(
      mysticText(MysticLanguage.turkish, 'Living Fate', 'Yaşayan Kader'),
      'Yaşayan Kader',
    );
  });
}
