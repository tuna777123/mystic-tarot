import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/journal_transfer.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/mystic_mirror.dart';
import 'package:mystic_tarot/src/oracle_conversation.dart';
import 'package:mystic_tarot/src/reading_journal_store.dart';
import 'package:mystic_tarot/src/tarot_data.dart';

ReadingRecord _record(String question, DateTime createdAt) => ReadingRecord(
      kind: ReadingKind.daily,
      question: question,
      cards: <DrawnCard>[DrawnCard(tarotDeck.first, false)],
      createdAt: createdAt,
      emotion: EmotionalState.curious,
      alignedAction: 'Take one grounded step.',
    );

void main() {
  test('private transfer round-trips readings, Mirror, and Oracle history', () {
    final record = _record(
      'What deserves my attention?',
      DateTime.utc(2026, 8, 4, 8),
    );
    final recordId = readingJournalRecordId(record);
    final reflection = MysticMirrorReflection(
      recordId: recordId,
      outcome: MysticMirrorOutcome.shifted,
      emotion: EmotionalState.grounded,
      note: 'The next step became clearer.',
      completedAt: DateTime.utc(2026, 8, 5, 8),
    );
    final turn = OracleConversationTurn.create(
      record: record,
      question: 'Which card matters most?',
      answer: 'The first card carries the central invitation.',
      createdAt: DateTime.utc(2026, 8, 4, 9),
    );

    final code = JournalTransferCodec.encode(
      records: <ReadingRecord>[record],
      reflections: <MysticMirrorReflection>[reflection],
      oracleTurns: <OracleConversationTurn>[turn],
    );
    final restored = JournalTransferCodec.decode(code);

    expect(code, startsWith('${JournalTransferCodec.marker}\n'));
    expect(restored.records.single.question, 'What deserves my attention?');
    expect(
      restored.reflections.values.single.note,
      'The next step became clearer.',
    );
    expect(restored.oracleTurns.single.question, 'Which card matters most?');
    expect(restored.rejectedItems, 0);
  });

  test('plain text, foreign markers, and empty journals are rejected', () {
    expect(
      () => JournalTransferCodec.decode('ordinary journal text'),
      throwsFormatException,
    );
    expect(
      () => JournalTransferCodec.decode('MYSTIC-TAROT-JOURNAL-V2\nabc'),
      throwsFormatException,
    );
    final empty = JournalTransferCodec.encode(records: const <ReadingRecord>[]);
    expect(() => JournalTransferCodec.decode(empty), throwsFormatException);
  });

  test('orphaned private items are ignored without losing valid readings', () {
    final record = _record('Signal', DateTime.utc(2026, 8, 4, 8));
    final envelope = <String, Object>{
      'schemaVersion': JournalTransferCodec.schemaVersion,
      'product': 'Mystic Tarot',
      'kind': 'private-journal-transfer',
      'journal': jsonEncode(<String, Object>{
        'schemaVersion': 1,
        'records': <Object>[
          <String, Object>{
            'kind': record.kind.name,
            'question': record.question,
            'cards': <Object>[
              <String, Object>{
                'name': record.cards.first.card.name,
                'reversed': false,
              },
            ],
            'createdAt': record.createdAt.toUtc().toIso8601String(),
            'emotion': record.emotion.name,
            'action': record.alignedAction,
          },
        ],
      }),
      'mirror': <String>[
        MysticMirrorReflection(
          recordId: 'missing-reading',
          outcome: MysticMirrorOutcome.unchanged,
          emotion: EmotionalState.curious,
          note: 'Orphan',
          completedAt: DateTime.utc(2026, 8, 5),
        ).encode(),
      ],
      'oracle': <String>[],
    };
    final code =
        '${JournalTransferCodec.marker}\n${base64Url.encode(utf8.encode(jsonEncode(envelope)))}';

    final result = JournalTransferCodec.decode(code);

    expect(result.records, hasLength(1));
    expect(result.reflections, isEmpty);
    expect(result.rejectedItems, 1);
  });
}
