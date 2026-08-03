import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/journal_transfer.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/tarot_data.dart';

ReadingRecord _record(String question) => ReadingRecord(
      kind: ReadingKind.daily,
      question: question,
      cards: <DrawnCard>[DrawnCard(tarotDeck.first, false)],
      createdAt: DateTime.utc(2026, 8, 4, 8),
      emotion: EmotionalState.curious,
      alignedAction: 'Take one grounded step.',
    );

void main() {
  test('private transfer code round-trips complete readings', () {
    final code = JournalTransferCodec.encode(<ReadingRecord>[
      _record('What deserves my attention?'),
    ]);

    final restored = JournalTransferCodec.decode(code);

    expect(code, startsWith('${JournalTransferCodec.marker}\n'));
    expect(restored.records, hasLength(1));
    expect(restored.records.single.question, 'What deserves my attention?');
    expect(restored.rejectedItems, 0);
  });

  test('plain text and foreign payloads are rejected', () {
    expect(
      () => JournalTransferCodec.decode('ordinary journal text'),
      throwsFormatException,
    );
    expect(
      () => JournalTransferCodec.decode('MYSTIC-TAROT-JOURNAL-V2\nabc'),
      throwsFormatException,
    );
  });

  test('transfer code tolerates surrounding whitespace', () {
    final code = JournalTransferCodec.encode(<ReadingRecord>[_record('Signal')]);
    final restored = JournalTransferCodec.decode('\n  $code  \n');
    expect(restored.records.single.question, 'Signal');
  });
}
