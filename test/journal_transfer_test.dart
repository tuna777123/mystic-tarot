import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/journal_transfer.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/mystic_mirror.dart';
import 'package:mystic_tarot/src/oracle_conversation.dart';
import 'package:mystic_tarot/src/reading_journal_store.dart';
import 'package:mystic_tarot/src/tarot_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

ReadingRecord _record(String question, DateTime createdAt) => ReadingRecord(
      kind: ReadingKind.daily,
      question: question,
      cards: <DrawnCard>[DrawnCard(tarotDeck.first, false)],
      createdAt: createdAt,
      emotion: EmotionalState.curious,
      alignedAction: 'Take one grounded step.',
    );

MysticMirrorReflection _reflection(
  ReadingRecord record,
  String note,
  DateTime completedAt,
) =>
    MysticMirrorReflection(
      recordId: readingJournalRecordId(record),
      outcome: MysticMirrorOutcome.shifted,
      emotion: EmotionalState.grounded,
      note: note,
      completedAt: completedAt,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('private transfer round-trips readings, Mirror, and Oracle history', () {
    final record = _record(
      'What deserves my attention?',
      DateTime.utc(2026, 8, 4, 8),
    );
    final reflection = _reflection(
      record,
      'The next step became clearer.',
      DateTime.utc(2026, 8, 5, 8),
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
    expect(restored.reflections.values.single.note,
        'The next step became clearer.');
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
    expect(
      () => JournalTransferCodec.encode(records: const <ReadingRecord>[]),
      throwsStateError,
    );
  });

  test('orphaned private items are ignored without losing valid readings', () {
    final record = _record('Signal', DateTime.utc(2026, 8, 4, 8));
    final envelope = <String, Object>{
      'schemaVersion': JournalTransferCodec.schemaVersion,
      'product': 'Mystic Tarot',
      'kind': 'private-journal-transfer',
      'journal': ReadingJournalCodec.encode(<ReadingRecord>[record]),
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

  test('service merges history and preserves the pre-import snapshot', () async {
    final preferences = await SharedPreferences.getInstance();
    final existing = _record('Existing', DateTime.utc(2026, 8, 2, 8));
    final incoming = _record('Incoming', DateTime.utc(2026, 8, 4, 8));
    final existingReflection = _reflection(
      existing,
      'Existing mirror',
      DateTime.utc(2026, 8, 3, 8),
    );
    final incomingReflection = _reflection(
      incoming,
      'Incoming mirror',
      DateTime.utc(2026, 8, 5, 8),
    );
    final incomingTurn = OracleConversationTurn.create(
      record: incoming,
      question: 'What continues?',
      answer: 'Continue with one observable step.',
      createdAt: DateTime.utc(2026, 8, 4, 9),
    );

    await ReadingJournalStore(preferences: preferences).save(<ReadingRecord>[
      existing,
    ]);
    await MysticMirrorStore(preferences: preferences).save(existingReflection);

    final code = JournalTransferCodec.encode(
      records: <ReadingRecord>[incoming],
      reflections: <MysticMirrorReflection>[incomingReflection],
      oracleTurns: <OracleConversationTurn>[incomingTurn],
    );
    final result = await JournalTransferService(preferences: preferences)
        .importCode(code);

    expect(result.addedReadings, 1);
    expect(result.restoredMirrors, 1);
    expect(result.addedOracleTurns, 1);
    expect(result.records.map((item) => item.question),
        <String>['Incoming', 'Existing']);

    final backup = ReadingJournalCodec.decode(
      preferences.getString(ReadingJournalStore.backupKey)!,
    );
    expect(backup.records.single.question, 'Existing');
    expect((await ReadingJournalStore(preferences: preferences).load()).records,
        hasLength(2));
    expect(await MysticMirrorStore(preferences: preferences).load(), hasLength(2));
    expect(await OracleConversationStore(preferences: preferences).loadAll(),
        hasLength(1));
  });

  test('a transfer never replaces a newer local Mirror reflection', () async {
    final preferences = await SharedPreferences.getInstance();
    final record = _record('Same reading', DateTime.utc(2026, 8, 4, 8));
    final local = _reflection(
      record,
      'Newer local truth',
      DateTime.utc(2026, 8, 6, 8),
    );
    final olderIncoming = _reflection(
      record,
      'Older imported note',
      DateTime.utc(2026, 8, 5, 8),
    );
    await ReadingJournalStore(preferences: preferences).save(<ReadingRecord>[
      record,
    ]);
    await MysticMirrorStore(preferences: preferences).save(local);

    final code = JournalTransferCodec.encode(
      records: <ReadingRecord>[record],
      reflections: <MysticMirrorReflection>[olderIncoming],
    );
    final result = await JournalTransferService(preferences: preferences)
        .importCode(code);
    final restored = await MysticMirrorStore(preferences: preferences).load();

    expect(result.addedReadings, 0);
    expect(result.restoredMirrors, 0);
    expect(restored.values.single.note, 'Newer local truth');
  });
}
