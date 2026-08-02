import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/daily_state.dart';

void main() {
  test('same day keeps daily buckets and an active streak', () {
    final now = DateTime(2026, 8, 2, 18, 30);
    final refresh = evaluateMysticDailyRefresh(
      now: now,
      activeDay: '2026-08-02',
      deepReadingsDay: '2026-08-02',
      dailyQuestClaimedDay: '2026-08-02',
      lastActiveDay: '2026-08-02',
      streak: 6,
    );

    expect(refresh.dayChanged, isFalse);
    expect(refresh.resetDeepReadings, isFalse);
    expect(refresh.clearQuestClaim, isFalse);
    expect(refresh.visibleStreak, 6);
  });

  test('midnight resets daily work without erasing a valid streak', () {
    final refresh = evaluateMysticDailyRefresh(
      now: DateTime(2026, 8, 3, 0, 0, 2),
      activeDay: '2026-08-02',
      deepReadingsDay: '2026-08-02',
      dailyQuestClaimedDay: '2026-08-02',
      lastActiveDay: '2026-08-02',
      streak: 6,
    );

    expect(refresh.today, '2026-08-03');
    expect(refresh.dayChanged, isTrue);
    expect(refresh.resetDeepReadings, isTrue);
    expect(refresh.clearQuestClaim, isTrue);
    expect(refresh.visibleStreak, 6);
  });

  test('a genuinely broken streak is not shown as still active', () {
    final refresh = evaluateMysticDailyRefresh(
      now: DateTime(2026, 8, 5, 9),
      activeDay: '2026-08-04',
      deepReadingsDay: '2026-08-04',
      dailyQuestClaimedDay: null,
      lastActiveDay: '2026-08-02',
      streak: 9,
    );

    expect(refresh.visibleStreak, 0);
  });

  test('next-day timer always crosses the local midnight boundary', () {
    final now = DateTime(2026, 8, 2, 23, 59, 58);
    expect(durationUntilNextMysticDay(now), const Duration(seconds: 3));
  });
}
