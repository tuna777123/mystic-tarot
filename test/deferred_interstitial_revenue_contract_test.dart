import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('interstitial opportunity persists until a real impression', () {
    final source = File('lib/src/ad_revenue_service.dart').readAsStringSync();
    final recordStart = source.indexOf('Future<void> _recordCompletedReading()');
    final loadStart = source.indexOf('void _loadAppOpen()');
    final showStart = source.indexOf('void _showInterstitialIfReady()');
    final privacyStart = source.indexOf('void showPrivacyOptions()');

    expect(recordStart, greaterThanOrEqualTo(0));
    expect(loadStart, greaterThan(recordStart));
    expect(showStart, greaterThan(loadStart));
    expect(privacyStart, greaterThan(showStart));

    final recordSection = source.substring(recordStart, loadStart);
    final showSection = source.substring(showStart, privacyStart);

    expect(
      source,
      contains('ad_completed_readings_since_interstitial_v1'),
    );
    expect(
      recordSection,
      contains('_completedReadingsSinceInterstitialKey'),
    );
    expect(
      recordSection,
      isNot(contains('_completedReadingsSinceAd = 0;')),
      reason: 'A load miss or cooldown must not consume a due impression.',
    );
    expect(
      showSection,
      contains('onAdImpression: (_) {'),
    );
    expect(
      showSection,
      contains('_completedReadingsSinceAd = 0;'),
      reason: 'Cadence should reset only after the interstitial is seen.',
    );
    expect(
      showSection,
      contains('_persistCompletedReadingsSinceInterstitial()'),
    );
  });
}
