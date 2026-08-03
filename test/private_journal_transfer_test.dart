import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/journal_transfer.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/mystic_mirror.dart';
import 'package:mystic_tarot/src/oracle_conversation.dart';
import 'package:mystic_tarot/src/private_journal_transfer.dart';
import 'package:mystic_tarot/src/reading_journal_store.dart';
import 'package:mystic_tarot/src/tarot_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

ReadingRecord _record(String question, DateTime createdAt, {int card = 0}) =>
    ReadingRecord(
      kind: ReadingKind.daily,
      question: question,
      cards: <DrawnCard>[DrawnCard(tarotDeck[card], false)],
      createdAt: createdAt,
      emotion: EmotionalState.curious,
      alignedAction: 'Take one grounded step.',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('restore merges complete history without replacing local readings',
      () async {
    final preferences = await SharedPreferences.getInstance();
    final current = _record('Keep local', DateTime.utc(2026, 8, 3, 8));
    final imported = _record(
      'Bring from old device',
      DateTime.utc(2026, 8, 4, 8),
      card: 1,
    );
    await ReadingJournalStore(preferences: preferences)
        .save(<ReadingRecord>[current]);

    final reflection = MysticMirrorReflection(
      recordId: readingJournalRecordId(imported),
      outcome: MysticMirrorOutcome.shifted,
      emotion: EmotionalState.calm,
      note: 'The imported reflection.',
      completedAt: DateTime.utc(2026, 8, 5, 8),
    );
    final oracle = OracleConversationTurn.create(
      record: imported,
      question: 'What changed?',
      answer: 'The imported Oracle answer.',
      createdAt: DateTime.utc(2026, 8, 4, 9),
    );
    final code = JournalTransferCodec.encode(
      records: <ReadingRecord>[imported],
      reflections: <MysticMirrorReflection>[reflection],
      oracleTurns: <OracleConversationTurn>[oracle],
    );
    final service = PrivateJournalTransferService(preferences: preferences);

    final preview = await service.preview(
      code: code,
      currentRecords: <ReadingRecord>[current],
    );
    expect(preview.addedReadings, 1);
    expect(preview.changedReflections, 1);
    expect(preview.addedOracleTurns, 1);

    final result = await service.commit(
      code: code,
      currentRecords: <ReadingRecord>[current],
    );

    expect(result.mergedRecords.map((item) => item.question),
        <String>['Bring from old device', 'Keep local']);
    expect(
      (await ReadingJournalStore(preferences: preferences).load())
          .records
          .map((item) => item.question),
      <String>['Bring from old device', 'Keep local'],
    );
    expect(
      (await MysticMirrorStore(preferences: preferences).load())
          .values
          .single
          .note,
      'The imported reflection.',
    );
    expect(
      (await OracleConversationStore(preferences: preferences).loadAll())
          .single
          .answer,
      'The imported Oracle answer.',
    );
    expect(
      preferences.getStringList('discovered_cards'),
      containsAll(<String>[
        current.cards.first.card.name,
        imported.cards.first.card.name,
      ]),
    );
  });

  test('duplicate imports do not create duplicate readings or turns', () async {
    final preferences = await SharedPreferences.getInstance();
    final record = _record('Same reading', DateTime.utc(2026, 8, 4, 8));
    final turn = OracleConversationTurn.create(
      record: record,
      question: 'Same question',
      answer: 'Same answer',
      createdAt: DateTime.utc(2026, 8, 4, 9),
    );
    await ReadingJournalStore(preferences: preferences)
        .save(<ReadingRecord>[record]);
    await OracleConversationStore(preferences: preferences).saveTurn(turn);
    final code = JournalTransferCodec.encode(
      records: <ReadingRecord>[record],
      oracleTurns: <OracleConversationTurn>[turn],
    );
    final service = PrivateJournalTransferService(preferences: preferences);

    final preview = await service.preview(
      code: code,
      currentRecords: <ReadingRecord>[record],
    );

    expect(preview.totalChanges, 0);
    expect(preview.mergedRecords, hasLength(1));
    expect(preview.mergedOracleTurns, hasLength(1));
  });

  test('invalid transfer leaves the current snapshot untouched', () async {
    final preferences = await SharedPreferences.getInstance();
    final current = _record('Untouched', DateTime.utc(2026, 8, 4, 8));
    await ReadingJournalStore(preferences: preferences)
        .save(<ReadingRecord>[current]);
    final before =
        preferences.getString(ReadingJournalStore.primaryKey);
    final service = PrivateJournalTransferService(preferences: preferences);

    await expectLater(
      service.commit(
        code: 'not-a-transfer',
        currentRecords: <ReadingRecord>[current],
      ),
      throwsFormatException,
    );

    expect(preferences.getString(ReadingJournalStore.primaryKey), before);
  });
}
