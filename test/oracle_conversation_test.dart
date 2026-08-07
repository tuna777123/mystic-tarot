import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/oracle_conversation.dart';
import 'package:mystic_tarot/src/tarot_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

ReadingRecord _record(
  DateTime createdAt, {
  ReadingKind kind = ReadingKind.daily,
}) {
  return ReadingRecord(
    kind: kind,
    question: 'What should I notice?',
    cards: [DrawnCard(tarotDeck.first, false)],
    createdAt: createdAt,
    emotion: EmotionalState.curious,
    alignedAction: 'Take one honest step.',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('turn codec round-trips a private grounded exchange', () {
    final record = _record(DateTime.utc(2026, 8, 2, 12));
    final turn = OracleConversationTurn.create(
      record: record,
      question: 'What am I not seeing?',
      answer: 'Separate what you know from what you fear.',
      createdAt: DateTime.utc(2026, 8, 2, 12, 5),
    );

    final decoded = OracleConversationTurn.tryDecode(turn.encode());

    expect(decoded, isNotNull);
    expect(decoded!.turnId, turn.turnId);
    expect(decoded.recordId, oracleConversationRecordId(record));
    expect(decoded.question, 'What am I not seeing?');
    expect(decoded.answer, 'Separate what you know from what you fear.');
  });

  test('store keeps multiple turns linked to the correct reading', () async {
    final firstRecord = _record(DateTime.utc(2026, 8, 1, 9));
    final secondRecord = _record(
      DateTime.utc(2026, 8, 2, 9),
      kind: ReadingKind.love,
    );
    final store = OracleConversationStore();
    await store.saveTurn(
      OracleConversationTurn.create(
        record: firstRecord,
        question: 'First?',
        answer: 'First answer.',
        createdAt: DateTime.utc(2026, 8, 1, 9, 5),
      ),
    );
    await store.saveTurn(
      OracleConversationTurn.create(
        record: firstRecord,
        question: 'Second?',
        answer: 'Second answer.',
        createdAt: DateTime.utc(2026, 8, 1, 9, 10),
      ),
    );
    await store.saveTurn(
      OracleConversationTurn.create(
        record: secondRecord,
        question: 'Another reading?',
        answer: 'Another answer.',
        createdAt: DateTime.utc(2026, 8, 2, 9, 5),
      ),
    );

    final firstTurns = await store.loadForRecord(firstRecord);
    final grouped = await store.loadGrouped();

    expect(firstTurns.map((turn) => turn.question), ['First?', 'Second?']);
    expect(grouped[oracleConversationRecordId(firstRecord)], hasLength(2));
    expect(grouped[oracleConversationRecordId(secondRecord)], hasLength(1));
  });

  test('partial corruption recovers missing turns from the backup', () async {
    final record = _record(DateTime.utc(2026, 8, 2, 10));
    final first = OracleConversationTurn.create(
      record: record,
      question: 'One?',
      answer: 'One.',
      createdAt: DateTime.utc(2026, 8, 2, 10, 1),
    );
    final second = OracleConversationTurn.create(
      record: record,
      question: 'Two?',
      answer: 'Two.',
      createdAt: DateTime.utc(2026, 8, 2, 10, 2),
    );
    SharedPreferences.setMockInitialValues(<String, Object>{
      OracleConversationStore.storageKey: <String>[first.encode(), 'broken'],
      OracleConversationStore.backupKey: <String>[
        first.encode(),
        second.encode(),
      ],
    });

    final turns = await OracleConversationStore().loadForRecord(record);

    expect(turns, hasLength(2));
    expect(turns.last.question, 'Two?');
  });

  test(
    'saving preserves the previous valid primary snapshot as backup',
    () async {
      final record = _record(DateTime.utc(2026, 8, 2, 11));
      final first = OracleConversationTurn.create(
        record: record,
        question: 'Before?',
        answer: 'Before.',
        createdAt: DateTime.utc(2026, 8, 2, 11, 1),
      );
      SharedPreferences.setMockInitialValues(<String, Object>{
        OracleConversationStore.storageKey: <String>[first.encode()],
      });
      final store = OracleConversationStore();
      await store.saveTurn(
        OracleConversationTurn.create(
          record: record,
          question: 'After?',
          answer: 'After.',
          createdAt: DateTime.utc(2026, 8, 2, 11, 2),
        ),
      );
      final preferences = await SharedPreferences.getInstance();

      expect(preferences.getStringList(OracleConversationStore.backupKey), [
        first.encode(),
      ]);
      expect(await store.loadForRecord(record), hasLength(2));
    },
  );

  test('clear removes primary and backup Oracle memory', () async {
    final record = _record(DateTime.utc(2026, 8, 2, 13));
    final store = OracleConversationStore();
    await store.saveTurn(
      OracleConversationTurn.create(
        record: record,
        question: 'Keep?',
        answer: 'Not after deletion.',
      ),
    );

    await store.clear();

    expect(await store.loadAll(), isEmpty);
    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.containsKey(OracleConversationStore.storageKey),
      isFalse,
    );
    expect(preferences.containsKey(OracleConversationStore.backupKey), isFalse);
  });
}
