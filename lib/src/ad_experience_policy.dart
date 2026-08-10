/// Product-level guardrails that keep advertising from interrupting Mystic's
/// reflection loop or appearing back-to-back.
///
/// This policy is intentionally independent from the ad SDK so cadence can be
/// tested deterministically without loading native ads.
class AdExperiencePolicy {
  const AdExperiencePolicy._();

  static const maxAppOpenCacheAge = Duration(hours: 4);
  static const minimumAppOpenInterval = Duration(hours: 2);
  static const minimumBackgroundDuration = Duration(seconds: 30);
  static const minimumReadingsBeforeAppOpen = 3;
  static const interstitialEveryReadings = 3;

  /// A full-screen ad should never feel like it is chasing the user from one
  /// surface to the next. This gap applies across formats and app restarts.
  static const minimumFullScreenGap = Duration(minutes: 20);

  static bool fullScreenGapSatisfied({
    required DateTime now,
    DateTime? lastFullScreenShownAt,
  }) {
    if (lastFullScreenShownAt == null) return true;
    return now.difference(lastFullScreenShownAt) >= minimumFullScreenGap;
  }

  static bool appOpenIntervalSatisfied({
    required DateTime now,
    DateTime? lastAppOpenShownAt,
  }) {
    if (lastAppOpenShownAt == null) return true;
    return now.difference(lastAppOpenShownAt) >= minimumAppOpenInterval;
  }

  static bool appOpenEligible({
    required DateTime now,
    required int completedReadings,
    DateTime? lastAppOpenShownAt,
    DateTime? lastFullScreenShownAt,
  }) {
    return completedReadings >= minimumReadingsBeforeAppOpen &&
        appOpenIntervalSatisfied(
          now: now,
          lastAppOpenShownAt: lastAppOpenShownAt,
        ) &&
        fullScreenGapSatisfied(
          now: now,
          lastFullScreenShownAt: lastFullScreenShownAt,
        );
  }
}
