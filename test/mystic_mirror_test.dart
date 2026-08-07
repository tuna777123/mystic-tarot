import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/mystic_living_journal_feature.dart';
import 'package:mystic_tarot/src/mystic_mirror.dart';
import 'package:shared_preferences/shared_preferences.dart';

const testCard = TarotCardData(
  name: 'The Star',
  number: 'XVII',
  symbol: '✦',
  light: 'Hope',
  shadow: 'Doubt',
  advice: 'Take one visible step.',
);

ReadingRecord testRecord(DateTime createdAt) => ReadingRecord(
  kind: ReadingKind.daily,
  question: 'What deserves my attention?',
  cards: const <DrawnCard>[DrawnCard(testCard, false)],
  createdAt: createdAt,
  emotion: EmotionalState.uncertain,
  alignedAction: 'Take one small reversible step.',
);

MysticMirrorReflection reflection({
  required String id,
  required DateTime completedAt,
  String note = '',
  MysticMirrorOutcome outcome = MysticMirrorOutcome.shifted,
}) => MysticMirrorReflection(
  recordId: id,
  outcome: outcome,
  emotion: EmotionalState.grounded,
  note: note,
  completedAt: completedAt,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('record id is stable across local timezone representations', () {
    final utc = DateTime.utc(2026, 8, 1, 12);
    final localRepresentation = utc.toLocal();

    expect(
      mysticMirrorRecordId(testRecord(utc)),
      mysticMirrorRecordId(testRecord(localRepresentation)),
    );
  });

  test('mirror becomes due at exactly twenty-four hours', () {
    final createdAt = DateTime.utc(2026, 8, 1, 12);
    final record = testRecord(createdAt);

    expect(
      mysticMirrorIsDue(
        record,
        createdAt.add(const Duration(hours: 23, minutes: 59)),
      ),
      isFalse,
    );
    expect(
      mysticMirrorIsDue(record, createdAt.add(const Duration(hours: 24))),
      isTrue,
    );
    expect(
      mysticMirrorIsDue(
        record,
        createdAt.add(const Duration(hours: 48)),
        completedRecordIds: <String>{mysticMirrorRecordId(record)},
      ),
      isFalse,
    );
  });

  test('reflection codec round-trips and limits oversized notes', () {
    final item = reflection(
      id: 'record-1',
      outcome: MysticMirrorOutcome.partlyShifted,
      note: 'x' * 700,
      completedAt: DateTime.utc(2026, 8, 2, 12),
    );

    final decoded = MysticMirrorReflection.tryDecode(item.encode());

    expect(decoded, isNotNull);
    expect(decoded!.recordId, 'record-1');
    expect(decoded.outcome, MysticMirrorOutcome.partlyShifted);
    expect(decoded.emotion, EmotionalState.grounded);
    expect(decoded.note.length, 500);
    expect(decoded.completedAt, DateTime.utc(2026, 8, 2, 12));
  });

  test('store skips corrupt values and keeps the newest duplicate', () async {
    final older = reflection(
      id: 'same-record',
      outcome: MysticMirrorOutcome.unchanged,
      note: 'Older',
      completedAt: DateTime.utc(2026, 8, 2, 10),
    );
    final newer = reflection(
      id: 'same-record',
      note: 'Newer',
      completedAt: DateTime.utc(2026, 8, 2, 11),
    );
    SharedPreferences.setMockInitialValues(<String, Object>{
      MysticMirrorStore.storageKey: <String>[
        older.encode(),
        '{broken json',
        newer.encode(),
      ],
    });

    final loaded = await MysticMirrorStore().load();

    expect(loaded, hasLength(1));
    expect(loaded['same-record']!.note, 'Newer');
    expect(loaded['same-record']!.outcome, MysticMirrorOutcome.shifted);
  });

  test('saving one reflection preserves existing reflections', () async {
    final store = MysticMirrorStore();
    final first = reflection(
      id: 'first',
      outcome: MysticMirrorOutcome.unclear,
      completedAt: DateTime.utc(2026, 8, 2, 9),
    );
    final second = reflection(
      id: 'second',
      note: 'A real change.',
      completedAt: DateTime.utc(2026, 8, 2, 10),
    );

    await store.save(first);
    await store.save(second);
    final loaded = await store.load();

    expect(loaded.keys, containsAll(<String>['first', 'second']));
    expect(loaded['second']!.note, 'A real change.');
  });

  test(
    'saving a new snapshot preserves the previous primary as backup',
    () async {
      final store = MysticMirrorStore();
      final first = reflection(
        id: 'first',
        note: 'First snapshot',
        completedAt: DateTime.utc(2026, 8, 2, 9),
      );
      final second = reflection(
        id: 'second',
        note: 'Second snapshot',
        completedAt: DateTime.utc(2026, 8, 2, 10),
      );

      await store.save(first);
      await store.save(second);
      final preferences = await SharedPreferences.getInstance();
      final backup = preferences.getStringList(MysticMirrorStore.backupKey)!;

      expect(backup, hasLength(1));
      expect(
        MysticMirrorReflection.tryDecode(backup.single)!.recordId,
        'first',
      );
    },
  );

  test(
    'store recovers from backup when primary contains no valid records',
    () async {
      final recovered = reflection(
        id: 'recovered',
        note: 'Last known good',
        completedAt: DateTime.utc(2026, 8, 2, 8),
      );
      SharedPreferences.setMockInitialValues(<String, Object>{
        MysticMirrorStore.storageKey: <String>['{broken'],
        MysticMirrorStore.backupKey: <String>[recovered.encode()],
      });

      final loaded = await MysticMirrorStore().load();

      expect(loaded, hasLength(1));
      expect(loaded['recovered']!.note, 'Last known good');
    },
  );

  test(
    'partial primary corruption restores missing backup reflections',
    () async {
      final primary = reflection(
        id: 'primary',
        note: 'Still valid',
        completedAt: DateTime.utc(2026, 8, 3, 10),
      );
      final backup = reflection(
        id: 'backup',
        note: 'Recovered from backup',
        completedAt: DateTime.utc(2026, 8, 2, 10),
      );
      SharedPreferences.setMockInitialValues(<String, Object>{
        MysticMirrorStore.storageKey: <String>[primary.encode(), '{broken'],
        MysticMirrorStore.backupKey: <String>[backup.encode()],
      });

      final loaded = await MysticMirrorStore().load();

      expect(loaded.keys, containsAll(<String>['primary', 'backup']));
      expect(loaded['backup']!.note, 'Recovered from backup');
    },
  );

  test(
    'newer primary reflection wins over an older backup duplicate',
    () async {
      final primary = reflection(
        id: 'same',
        note: 'New primary',
        completedAt: DateTime.utc(2026, 8, 3, 10),
      );
      final backup = reflection(
        id: 'same',
        note: 'Old backup',
        completedAt: DateTime.utc(2026, 8, 2, 10),
      );
      SharedPreferences.setMockInitialValues(<String, Object>{
        MysticMirrorStore.storageKey: <String>[primary.encode(), '{broken'],
        MysticMirrorStore.backupKey: <String>[backup.encode()],
      });

      final loaded = await MysticMirrorStore().load();

      expect(loaded, hasLength(1));
      expect(loaded['same']!.note, 'New primary');
    },
  );

  test('saving after corrupt primary never overwrites a good backup', () async {
    final backup = reflection(
      id: 'backup',
      note: 'Keep me',
      completedAt: DateTime.utc(2026, 8, 2, 10),
    );
    SharedPreferences.setMockInitialValues(<String, Object>{
      MysticMirrorStore.storageKey: <String>['{broken'],
      MysticMirrorStore.backupKey: <String>[backup.encode()],
    });

    await MysticMirrorStore().save(
      reflection(
        id: 'new',
        note: 'New reflection',
        completedAt: DateTime.utc(2026, 8, 3, 10),
      ),
    );
    final preferences = await SharedPreferences.getInstance();
    final backupItems = preferences.getStringList(MysticMirrorStore.backupKey)!;

    expect(backupItems, hasLength(1));
    expect(
      MysticMirrorReflection.tryDecode(backupItems.single)!.note,
      'Keep me',
    );
  });

  test('clear removes both primary and backup snapshots', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      MysticMirrorStore.storageKey: <String>['primary'],
      MysticMirrorStore.backupKey: <String>['backup'],
    });

    await MysticMirrorStore().clear();
    final preferences = await SharedPreferences.getInstance();

    expect(preferences.containsKey(MysticMirrorStore.storageKey), isFalse);
    expect(preferences.containsKey(MysticMirrorStore.backupKey), isFalse);
  });

  testWidgets('due Mirror prompt is localized in all five launch languages', (
    tester,
  ) async {
    final oldRecord = testRecord(
      DateTime.now().subtract(const Duration(days: 2)),
    );
    const expectations = <MysticLanguage, String>{
      MysticLanguage.english: 'Twenty-four hours passed.',
      MysticLanguage.turkish: 'Yirmi dört saat geçti.',
      MysticLanguage.spanish: 'Pasaron veinticuatro horas.',
      MysticLanguage.french: 'Vingt-quatre heures ont passé.',
      MysticLanguage.portugueseBrazil: 'Vinte e quatro horas se passaram.',
    };

    for (final entry in expectations.entries) {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: MysticLivingJournalFeature(
            records: <ReadingRecord>[oldRecord],
            language: entry.key,
            onPremium: () {},
            onOpenOracle: (_) async {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.textContaining(entry.value), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
