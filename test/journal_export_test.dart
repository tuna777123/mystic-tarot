import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/journal_export.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/mystic_mirror.dart';
import 'package:mystic_tarot/src/tarot_data.dart';

ReadingRecord record() => ReadingRecord(
      kind: ReadingKind.daily,
      question: 'What needs my attention?',
      cards: <DrawnCard>[DrawnCard(tarotDeck.first, true)],
      createdAt: DateTime.utc(2026, 8, 1, 12),
      emotion: EmotionalState.uncertain,
      alignedAction: 'Take one reversible step.',
    );

void main() {
  test('export includes the complete reading and matching Mirror evidence', () {
    final item = record();
    final mirror = MysticMirrorReflection(
      recordId: mysticMirrorRecordId(item),
      outcome: MysticMirrorOutcome.partlyShifted,
      emotion: EmotionalState.grounded,
      note: 'The conversation became clearer.',
      completedAt: DateTime.utc(2026, 8, 2, 12),
    );

    final export = buildMysticJournalExport(
      records: <ReadingRecord>[item],
      mirrors: <String, MysticMirrorReflection>{mirror.recordId: mirror},
      language: MysticLanguage.english,
    );

    expect(export, contains('What needs my attention?'));
    expect(export, contains('Take one reversible step.'));
    expect(export, contains('reversed'));
    expect(export, contains('Mystic Mirror — 24-hour reflection'));
    expect(export, contains('Partly changed'));
    expect(export, contains('The conversation became clearer.'));
    expect(export, isNot(contains(mirror.recordId)));
  });

  test('a reflection belonging to another record is never exported', () {
    final item = record();
    final unrelated = MysticMirrorReflection(
      recordId: 'another-record',
      outcome: MysticMirrorOutcome.shifted,
      emotion: EmotionalState.hopeful,
      note: 'Private unrelated note',
      completedAt: DateTime.utc(2026, 8, 2, 12),
    );

    final export = buildMysticJournalExport(
      records: <ReadingRecord>[item],
      mirrors: <String, MysticMirrorReflection>{
        unrelated.recordId: unrelated,
      },
      language: MysticLanguage.english,
    );

    expect(export, isNot(contains('Private unrelated note')));
  });

  test('empty export is localized in all five launch languages', () {
    const expected = <MysticLanguage, String>{
      MysticLanguage.english: 'No saved readings yet.',
      MysticLanguage.turkish: 'Henüz kayıtlı okuma yok.',
      MysticLanguage.spanish: 'Aún no hay lecturas guardadas.',
      MysticLanguage.french: 'Aucun tirage enregistré',
      MysticLanguage.portugueseBrazil: 'Ainda não há leituras salvas.',
    };

    for (final entry in expected.entries) {
      final export = buildMysticJournalExport(
        records: const <ReadingRecord>[],
        mirrors: const <String, MysticMirrorReflection>{},
        language: entry.key,
      );
      expect(export, contains(entry.value), reason: entry.key.name);
    }
  });

  test('Mirror outcome labels are localized in every launch language', () {
    const expected = <MysticLanguage, String>{
      MysticLanguage.english: 'Still unclear',
      MysticLanguage.turkish: 'Hâlâ belirsiz',
      MysticLanguage.spanish: 'Sigue sin estar claro',
      MysticLanguage.french: 'Toujours incertain',
      MysticLanguage.portugueseBrazil: 'Ainda não está claro',
    };

    for (final entry in expected.entries) {
      expect(
        localizedMysticMirrorOutcome(
          MysticMirrorOutcome.unclear,
          entry.key,
        ),
        entry.value,
      );
    }
  });

  test('export warns the user to review private content before sharing', () {
    final export = buildMysticJournalExport(
      records: <ReadingRecord>[record()],
      mirrors: const <String, MysticMirrorReflection>{},
      language: MysticLanguage.english,
    );

    expect(export, contains('Review before sharing.'));
  });
}
