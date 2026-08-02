import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/reading_journal_store.dart';
import 'package:mystic_tarot/src/tarot_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

ReadingRecord recordAt(DateTime createdAt, {String question = 'Question'}) =>
    ReadingRecord(
      kind: ReadingKind.daily,
      question: question,
      cards: <DrawnCard>[DrawnCard(tarotDeck.first, false)],
      createdAt: createdAt,
      emotion: EmotionalState.curious,
      alignedAction: 'Take one small step.',
    );

Map<String, dynamic> damagedPayload({
  required ReadingRecord validRecord,
  int damagedItems = 1,
}) {
  final payload = jsonDecode(
    ReadingJournalCodec.encode(<ReadingRecord>[validRecord]),
  ) as Map<String, dynamic>;
  final records = payload['records'] as List<dynamic>;
  for (var index = 0; index < damagedItems; index++) {
    records.add(<String, Object>{'kind': 'daily', 'cards': 'broken'});
  }
  return payload;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('codec round-trips the complete journal without a fifty-record cap', () {
    final records = List<ReadingRecord>.generate(
      125,
      (index) => recordAt(
        DateTime.utc(2026, 8, 2).subtract(Duration(hours: index)),
        question: 'Question $index',
      ),
    );

    final report = ReadingJournalCodec.decode(
      ReadingJournalCodec.encode(records),
    );

    expect(report.records, hasLength(125));
    expect(report.rejectedItems, 0);
    expect(report.records.first.question, 'Question 0');
    expect(report.records.last.question, 'Question 124');
  });

  test('codec rejects one damaged record without losing valid history', () {
    final report = ReadingJournalCodec.decode(
      jsonEncode(
        damagedPayload(
          validRecord: recordAt(DateTime.utc(2026, 8, 2, 12)),
        ),
      ),
    );

    expect(report.records, hasLength(1));
    expect(report.rejectedItems, 1);
  });

  test('store preserves the previous snapshot before replacing primary data',
      () async {
    final store = ReadingJournalStore();
    final first = <ReadingRecord>[
      recordAt(DateTime.utc(2026, 8, 1, 10), question: 'First'),
    ];
    final second = <ReadingRecord>[
      recordAt(DateTime.utc(2026, 8, 2, 10), question: 'Second'),
    ];

    await store.save(first);
    await store.save(second);
    final preferences = await SharedPreferences.getInstance();
    final backup = ReadingJournalCodec.decode(
      preferences.getString(ReadingJournalStore.backupKey)!,
    );

    expect(backup.records.single.question, 'First');
    expect((await store.load()).records.single.question, 'Second');
  });

  test('store recovers from backup when primary payload is unreadable', () async {
    final older = ReadingJournalCodec.encode(<ReadingRecord>[
      recordAt(DateTime.utc(2026, 8, 1, 10), question: 'Recovered'),
    ]);
    SharedPreferences.setMockInitialValues(<String, Object>{
      ReadingJournalStore.primaryKey: '{not json',
      ReadingJournalStore.backupKey: older,
    });

    final result = await ReadingJournalStore().load();

    expect(result.recoveredFromBackup, isTrue);
    expect(result.records.single.question, 'Recovered');
  });

  test('store recovers from backup when every primary record is damaged',
      () async {
    final damaged = <String, Object>{
      'schemaVersion': ReadingJournalCodec.schemaVersion,
      'records': <Map<String, Object>>[
        <String, Object>{'kind': 'daily', 'cards': 'broken'},
      ],
    };
    final backup = ReadingJournalCodec.encode(<ReadingRecord>[
      recordAt(DateTime.utc(2026, 8, 1, 10), question: 'Recovered all'),
    ]);
    SharedPreferences.setMockInitialValues(<String, Object>{
      ReadingJournalStore.primaryKey: jsonEncode(damaged),
      ReadingJournalStore.backupKey: backup,
    });

    final result = await ReadingJournalStore().load();

    expect(result.recoveredFromBackup, isTrue);
    expect(result.records.single.question, 'Recovered all');
    expect(result.rejectedItems, 1);
  });

  test('partial primary corruption is repaired with missing backup history',
      () async {
    final newest = recordAt(
      DateTime.utc(2026, 8, 3, 10),
      question: 'Newest primary',
    );
    final older = recordAt(
      DateTime.utc(2026, 8, 1, 10),
      question: 'Older backup',
    );
    final primary = jsonEncode(
      damagedPayload(validRecord: newest, damagedItems: 1),
    );
    final backup = ReadingJournalCodec.encode(<ReadingRecord>[older]);
    SharedPreferences.setMockInitialValues(<String, Object>{
      ReadingJournalStore.primaryKey: primary,
      ReadingJournalStore.backupKey: backup,
    });

    final result = await ReadingJournalStore().load();

    expect(result.recoveredFromBackup, isTrue);
    expect(
      result.records.map((record) => record.question),
      <String>['Newest primary', 'Older backup'],
    );
    expect(result.rejectedItems, 1);
  });

  test('primary records win when the backup contains the same identity',
      () async {
    final createdAt = DateTime.utc(2026, 8, 2, 12);
    final primaryRecord = recordAt(createdAt, question: 'Primary version');
    final backupRecord = recordAt(createdAt, question: 'Backup version');
    final primary = jsonEncode(
      damagedPayload(validRecord: primaryRecord, damagedItems: 1),
    );
    final backup = ReadingJournalCodec.encode(<ReadingRecord>[backupRecord]);
    SharedPreferences.setMockInitialValues(<String, Object>{
      ReadingJournalStore.primaryKey: primary,
      ReadingJournalStore.backupKey: backup,
    });

    final result = await ReadingJournalStore().load();

    expect(result.records, hasLength(1));
    expect(result.records.single.question, 'Primary version');
  });

  test('legacy string-list records migrate while corrupt items are skipped',
      () async {
    final legacyRecord = jsonEncode(<String, Object>{
      'kind': ReadingKind.daily.name,
      'question': 'Legacy question',
      'cards': <Map<String, Object>>[
        <String, Object>{
          'name': tarotDeck.first.name,
          'reversed': false,
        },
      ],
      'createdAt': DateTime.utc(2026, 8, 1, 12).toIso8601String(),
      'emotion': EmotionalState.hopeful.name,
      'action': 'Legacy action',
    });
    SharedPreferences.setMockInitialValues(<String, Object>{
      ReadingJournalStore.legacyKey: <String>[legacyRecord, '{broken'],
    });

    final result = await ReadingJournalStore().load();

    expect(result.migratedFromLegacy, isTrue);
    expect(result.records.single.question, 'Legacy question');
    expect(result.rejectedItems, 1);
  });

  test('duplicate record identities are rejected deterministically', () {
    final record = recordAt(DateTime.utc(2026, 8, 2, 12));
    final payload = jsonDecode(
      ReadingJournalCodec.encode(<ReadingRecord>[record]),
    ) as Map<String, dynamic>;
    final records = payload['records'] as List<dynamic>;
    records.add(Map<String, dynamic>.from(records.first as Map));

    final report = ReadingJournalCodec.decode(jsonEncode(payload));

    expect(report.records, hasLength(1));
    expect(report.rejectedItems, 1);
  });
}
