/// Product-level guardrails that keep advertising from interrupting Mystic's
/// reflection loop or appearing back-to-back.
///
/// Mystic is advertising-supported, but the product must feel like a premium
/// reflection tool rather than an ad container. These limits intentionally
/// trade some short-term impression volume for trust, retention, and a cleaner
/// first-session experience.
///
/// This policy is independent from the ad SDK so cadence can be tested
/// deterministically without loading native ads.
class AdExperiencePolicy {
  const AdExperiencePolicy._();

  static const maxAppOpenCacheAge = Duration(hours: 4);

  /// Returning-user app-open ads are intentionally rare. A six-hour cooldown
  /// prevents the format from becoming part of the user's mental model of
  /// opening Mystic.
  static const minimumAppOpenInterval = Duration(hours: 6);

  /// Short app switches should never be monetized. The user must have truly
  /// left the experience before a returning app-open opportunity exists.
  static const minimumBackgroundDuration = Duration(minutes: 1);

  /// The first several readings establish product value and the 24-hour Mirror
  /// loop before an app-open ad can ever be eligible.
  static const minimumReadingsBeforeAppOpen = 5;

  /// Interstitials remain tied only to a natural saved-reading boundary, and
  /// no more often than every fourth genuinely new completed reading.
  static const interstitialEveryReadings = 4;

  /// Full-screen formats share one generous cooldown across app restarts so an
  /// interstitial cannot be followed by an app-open ad (or vice versa) while
  /// the reflection still feels recent.
  static const minimumFullScreenGap = Duration(minutes: 45);

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

  /// Once the natural four-reading boundary has been reached, the opportunity
  /// remains due until an interstitial actually produces an impression.
  ///
  /// This intentionally uses >= rather than modulo arithmetic: a temporarily
  /// unavailable ad or a shared full-screen cooldown must not silently consume
  /// the next eligible monetization boundary.
  static bool interstitialDue({
    required int completedReadingsSinceInterstitial,
  }) {
    return completedReadingsSinceInterstitial >= interstitialEveryReadings;
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
