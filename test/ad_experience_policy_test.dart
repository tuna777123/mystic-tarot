import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/ad_experience_policy.dart';

void main() {
  final now = DateTime.utc(2026, 8, 10, 18);

  test('full-screen formats keep a twenty minute cross-format gap', () {
    expect(
      AdExperiencePolicy.fullScreenGapSatisfied(
        now: now,
        lastFullScreenShownAt: now.subtract(const Duration(minutes: 19)),
      ),
      isFalse,
    );
    expect(
      AdExperiencePolicy.fullScreenGapSatisfied(
        now: now,
        lastFullScreenShownAt: now.subtract(const Duration(minutes: 20)),
      ),
      isTrue,
    );
  });

  test('app-open remains for experienced returning users only', () {
    expect(
      AdExperiencePolicy.appOpenEligible(now: now, completedReadings: 2),
      isFalse,
    );
    expect(
      AdExperiencePolicy.appOpenEligible(now: now, completedReadings: 3),
      isTrue,
    );
  });

  test('recent interstitial suppresses an otherwise eligible app-open ad', () {
    expect(
      AdExperiencePolicy.appOpenEligible(
        now: now,
        completedReadings: 8,
        lastAppOpenShownAt: now.subtract(const Duration(hours: 3)),
        lastFullScreenShownAt: now.subtract(const Duration(minutes: 5)),
      ),
      isFalse,
    );
  });

  test('app-open retains its two-hour format-specific cooldown', () {
    expect(
      AdExperiencePolicy.appOpenEligible(
        now: now,
        completedReadings: 8,
        lastAppOpenShownAt: now.subtract(const Duration(minutes: 119)),
        lastFullScreenShownAt: now.subtract(const Duration(hours: 3)),
      ),
      isFalse,
    );
  });
}
