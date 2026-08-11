import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/ad_experience_policy.dart';

void main() {
  final now = DateTime.utc(2026, 8, 10, 18);

  test('full-screen formats keep a forty-five minute cross-format gap', () {
    expect(
      AdExperiencePolicy.fullScreenGapSatisfied(
        now: now,
        lastFullScreenShownAt: now.subtract(const Duration(minutes: 44)),
      ),
      isFalse,
    );
    expect(
      AdExperiencePolicy.fullScreenGapSatisfied(
        now: now,
        lastFullScreenShownAt: now.subtract(const Duration(minutes: 45)),
      ),
      isTrue,
    );
  });

  test('app-open remains for established returning users only', () {
    expect(
      AdExperiencePolicy.appOpenEligible(now: now, completedReadings: 4),
      isFalse,
    );
    expect(
      AdExperiencePolicy.appOpenEligible(now: now, completedReadings: 5),
      isTrue,
    );
  });

  test('recent interstitial suppresses an otherwise eligible app-open ad', () {
    expect(
      AdExperiencePolicy.appOpenEligible(
        now: now,
        completedReadings: 8,
        lastAppOpenShownAt: now.subtract(const Duration(hours: 7)),
        lastFullScreenShownAt: now.subtract(const Duration(minutes: 44)),
      ),
      isFalse,
    );
  });

  test('app-open keeps a six-hour format-specific cooldown', () {
    expect(
      AdExperiencePolicy.appOpenEligible(
        now: now,
        completedReadings: 8,
        lastAppOpenShownAt: now.subtract(const Duration(minutes: 359)),
        lastFullScreenShownAt: now.subtract(const Duration(hours: 7)),
      ),
      isFalse,
    );
    expect(
      AdExperiencePolicy.appOpenEligible(
        now: now,
        completedReadings: 8,
        lastAppOpenShownAt: now.subtract(const Duration(hours: 6)),
        lastFullScreenShownAt: now.subtract(const Duration(hours: 7)),
      ),
      isTrue,
    );
  });

  test('reflection-first cadence uses four-reading interstitial spacing', () {
    expect(AdExperiencePolicy.interstitialEveryReadings, 4);
    expect(AdExperiencePolicy.minimumBackgroundDuration, const Duration(minutes: 1));
  });
}
