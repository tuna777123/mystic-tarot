class MysticDailyRefresh {
  const MysticDailyRefresh({
    required this.today,
    required this.dayChanged,
    required this.resetDeepReadings,
    required this.clearQuestClaim,
    required this.visibleStreak,
  });

  final String today;
  final bool dayChanged;
  final bool resetDeepReadings;
  final bool clearQuestClaim;
  final int visibleStreak;
}

String mysticDayKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

MysticDailyRefresh evaluateMysticDailyRefresh({
  required DateTime now,
  required String activeDay,
  required String? deepReadingsDay,
  required String? dailyQuestClaimedDay,
  required String? lastActiveDay,
  required int streak,
}) {
  final today = mysticDayKey(now);
  final yesterday = mysticDayKey(now.subtract(const Duration(days: 1)));
  final dayChanged = activeDay != today;
  final resetDeepReadings = deepReadingsDay != today;
  final clearQuestClaim =
      dailyQuestClaimedDay != null && dailyQuestClaimedDay != today;
  final visibleStreak =
      lastActiveDay == null ||
          lastActiveDay == today ||
          lastActiveDay == yesterday
      ? streak
      : 0;

  return MysticDailyRefresh(
    today: today,
    dayChanged: dayChanged,
    resetDeepReadings: resetDeepReadings,
    clearQuestClaim: clearQuestClaim,
    visibleStreak: visibleStreak,
  );
}

Duration durationUntilNextMysticDay(DateTime now) {
  final nextDay = DateTime(now.year, now.month, now.day + 1);
  final duration = nextDay.difference(now) + const Duration(seconds: 1);
  return duration.isNegative ? const Duration(seconds: 1) : duration;
}
