import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Living Journal contains no stale paid-tier launch copy', () {
    final source = File(
      'lib/src/mystic_living_journal_feature.dart',
    ).readAsStringSync();

    for (final forbidden in [
      'Unlock your full pattern map',
      'Explore Premium',
      'Premium’u keşfet',
    ]) {
      expect(source.toLowerCase(), isNot(contains(forbidden.toLowerCase())));
    }
    expect(source, contains('Your Pattern Lab grows with evidence'));
    expect(source, contains('Share the 24h ritual'));
    expect(source, contains('sharePositionOrigin: _mirrorShareOrigin()'));
    expect(source, contains('Rect _mirrorShareOrigin()'));
  });

  test('growth engine contains no stale paid-tier CTA copy', () {
    final source = File('lib/src/growth_engine.dart').readAsStringSync();
    expect(source.toLowerCase(), isNot(contains('premium spreads continue')));
    expect(source.toLowerCase(), isNot(contains('explore mystic plus')));
    expect(source, contains('Complete my Mirror'));
  });

  test('privacy-safe business metrics contract stays explicit', () {
    final source = File('lib/src/business_metrics.dart').readAsStringSync();
    for (final privateField in [
      "'question'",
      "'note'",
      "'card'",
      "'name'",
      "'intention'",
      "'journal'",
      "'emotion'",
      "'outcome'",
      "'text'",
      "'pin'",
      "'query'",
    ]) {
      expect(source, contains(privateField));
    }
  });
}
