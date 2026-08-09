import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mystic_tarot/src/business_metrics.dart';
import 'package:mystic_tarot/src/local_growth_ledger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('stores aggregate-only retention and Mirror evidence', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    var now = DateTime(2026, 8, 1, 9);
    final ledger = MysticLocalGrowthLedger(
      preferences: preferences,
      now: () => now,
    );

    await ledger.record(
      MysticBusinessEvent.appOpened,
      const <String, String>{'platform': 'android', 'source': 'launch'},
    );
    await ledger.record(
      MysticBusinessEvent.onboardingCompleted,
      const <String, String>{'language': 'en', 'source': 'onboarding'},
    );
    await ledger.record(
      MysticBusinessEvent.readingCompleted,
      const <String, String>{'source': 'journal_store'},
    );

    now = DateTime(2026, 8, 2, 10);
    await ledger.record(
      MysticBusinessEvent.appOpened,
      const <String, String>{'platform': 'android', 'source': 'launch'},
    );
    await ledger.record(
      MysticBusinessEvent.mirrorDueSeen,
      const <String, String>{'language': 'en', 'source': 'mirror_due_state'},
    );

    now = DateTime(2026, 8, 3, 12);
    await ledger.record(
      MysticBusinessEvent.mirrorCompleted,
      const <String, String>{
        'language': 'en',
        'growth_stage': 'within_72h',
        'source': 'living_journal',
      },
    );

    now = DateTime(2026, 8, 8, 8);
    await ledger.record(
      MysticBusinessEvent.appOpened,
      const <String, String>{'platform': 'android', 'source': 'launch'},
    );

    now = DateTime(2026, 8, 31, 8);
    await ledger.record(
      MysticBusinessEvent.appOpened,
      const <String, String>{'platform': 'android', 'source': 'launch'},
    );

    final snapshot = await ledger.snapshot();
    expect(snapshot.firstOpenDay, '2026-08-01');
    expect(snapshot.firstReadingDayOffset, 0);
    expect(snapshot.firstMirrorDueDayOffset, 1);
    expect(snapshot.firstMirrorCompletedDayOffset, 2);
    expect(snapshot.firstMirrorCompletedWithinThreeCalendarDays, isTrue);
    expect(snapshot.reachedD1, isTrue);
    expect(snapshot.reachedD7, isTrue);
    expect(snapshot.reachedD30, isTrue);
    expect(snapshot.eventCounts[MysticBusinessEvent.appOpened.name], 4);
    expect(snapshot.eventCounts[MysticBusinessEvent.readingCompleted.name], 1);
    expect(
      snapshot.dimensionCounts[
        'mirrorCompleted|growth_stage|within_72h'
      ],
      1,
    );

    final exported = await ledger.exportJson();
    for (final forbidden in <String>[
      'question',
      'journal text',
      'card name',
      'user name',
      'intention',
      'emotion',
      'outcome',
    ]) {
      expect(exported.toLowerCase(), isNot(contains(forbidden)));
    }
  });

  test('serializes concurrent event writes without losing counts', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final ledger = MysticLocalGrowthLedger(
      preferences: preferences,
      now: () => DateTime(2026, 8, 9, 14),
    );

    await Future.wait(
      List<Future<void>>.generate(
        25,
        (_) => ledger.record(
          MysticBusinessEvent.readingCompleted,
          const <String, String>{'source': 'journal_store'},
        ),
      ),
    );

    final snapshot = await ledger.snapshot();
    expect(snapshot.eventCounts[MysticBusinessEvent.readingCompleted.name], 25);
    expect(
      snapshot.dailyEventCounts['2026-08-09']?[
        MysticBusinessEvent.readingCompleted.name
      ],
      25,
    );
  });

  test('recovers fail-closed from malformed persisted evidence', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      MysticLocalGrowthLedger.storageKey: '{not-json',
    });
    final preferences = await SharedPreferences.getInstance();
    final ledger = MysticLocalGrowthLedger(
      preferences: preferences,
      now: () => DateTime(2026, 8, 9),
    );

    await ledger.record(
      MysticBusinessEvent.appOpened,
      const <String, String>{'platform': 'ios', 'source': 'launch'},
    );

    final snapshot = await ledger.snapshot();
    expect(snapshot.firstOpenDay, '2026-08-09');
    expect(snapshot.eventCounts[MysticBusinessEvent.appOpened.name], 1);
  });

  test('business boundary rejects private or unknown dimensions before storage', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final ledger = MysticLocalGrowthLedger(preferences: preferences);

    expect(
      () => ledger.record(
        MysticBusinessEvent.readingCompleted,
        const <String, String>{'question': 'private question'},
      ),
      throwsArgumentError,
    );
    expect(
      () => ledger.record(
        MysticBusinessEvent.readingCompleted,
        const <String, String>{'device_id': 'abc'},
      ),
      throwsArgumentError,
    );

    final snapshot = await ledger.snapshot();
    expect(snapshot.eventCounts, isEmpty);
  });
}
