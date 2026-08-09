import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mystic_tarot/src/business_metrics.dart';
import 'package:mystic_tarot/src/local_growth_ledger.dart';
import 'package:mystic_tarot/src/mirror_growth_tracker.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/mystic_mirror.dart';
import 'package:mystic_tarot/src/tarot_data.dart';

ReadingRecord _record(
  DateTime createdAt, {
  ReadingKind kind = ReadingKind.daily,
}) {
  final card = tarotDeck.first;
  return ReadingRecord(
    kind: kind,
    question: 'private question never exported',
    cards: <DrawnCard>[DrawnCard(card, false)],
    createdAt: createdAt,
    emotion: EmotionalState.curious,
    alignedAction: 'private action never exported',
  );
}

MysticMirrorReflection _reflection(
  ReadingRecord record,
  DateTime completedAt,
) => MysticMirrorReflection(
  recordId: mysticMirrorRecordId(record),
  outcome: MysticMirrorOutcome.shifted,
  emotion: EmotionalState.grounded,
  note: 'private note never exported',
  completedAt: completedAt.toUtc(),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('classifies mature windows once with exact 72-hour outcome', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final observedAt = DateTime(2026, 8, 10, 12);
    final ledger = MysticLocalGrowthLedger(
      preferences: preferences,
      now: () => observedAt,
    );
    final tracker = MysticMirrorGrowthTracker(ledger: ledger);

    final completed = _record(DateTime(2026, 8, 1, 9));
    final missed = _record(DateTime(2026, 8, 2, 9), kind: ReadingKind.love);
    final immature = _record(DateTime(2026, 8, 9, 9));
    final reflections = <String, MysticMirrorReflection>{
      mysticMirrorRecordId(completed): _reflection(
        completed,
        completed.createdAt.add(const Duration(hours: 30)),
      ),
      mysticMirrorRecordId(missed): _reflection(
        missed,
        missed.createdAt.add(const Duration(hours: 90)),
      ),
    };

    await tracker.sync(
      records: <ReadingRecord>[completed, missed, immature],
      reflections: reflections,
      languageCode: 'en',
      now: observedAt,
    );
    await tracker.sync(
      records: <ReadingRecord>[completed, missed, immature],
      reflections: reflections,
      languageCode: 'en',
      now: observedAt,
    );

    final evidence = await ledger.snapshot();
    expect(
      evidence.eventCounts[MysticBusinessEvent.mirrorWindowMatured.name],
      2,
    );
    expect(
      evidence
          .dimensionCounts['mirrorWindowMatured|growth_stage|completed_within_72h'],
      1,
    );
    expect(
      evidence
          .dimensionCounts['mirrorWindowMatured|growth_stage|not_completed_within_72h'],
      1,
    );
    expect(
      evidence.dimensionCounts['mirrorWindowMatured|reading_kind|daily'],
      1,
    );
    expect(
      evidence.dimensionCounts['mirrorWindowMatured|reading_kind|love'],
      1,
    );

    final exported = await ledger.exportJson();
    expect(exported, isNot(contains(mysticMirrorRecordId(completed))));
    expect(exported, isNot(contains(mysticMirrorRecordId(missed))));
    expect(exported, isNot(contains('private question')));
    expect(exported, isNot(contains('private note')));
    expect(exported, isNot(contains('private action')));
  });

  test('a completion exactly at 72 hours counts inside the window', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final createdAt = DateTime(2026, 8, 1, 9);
    final record = _record(createdAt);
    final ledger = MysticLocalGrowthLedger(
      preferences: preferences,
      now: () => createdAt.add(const Duration(days: 4)),
    );
    final tracker = MysticMirrorGrowthTracker(ledger: ledger);

    await tracker.sync(
      records: <ReadingRecord>[record],
      reflections: <String, MysticMirrorReflection>{
        mysticMirrorRecordId(record): _reflection(
          record,
          createdAt.add(const Duration(hours: 72)),
        ),
      },
      languageCode: 'tr',
      now: createdAt.add(const Duration(days: 4)),
    );

    final evidence = await ledger.snapshot();
    expect(
      evidence
          .dimensionCounts['mirrorWindowMatured|growth_stage|completed_within_72h'],
      1,
    );
  });
}
