import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/materialize_onboarding_clarity.dart';

void main() {
  test('first screen leads with the reality-check continuity loop', () {
    final source = File('lib/src/app.dart').readAsStringSync();
    final transformed = materializeOnboardingClaritySource(source);

    final pageStart = transformed.indexOf('    if (page == 0) {');
    final pageEnd = transformed.indexOf('    if (page == 1) {', pageStart + 1);
    expect(pageStart, greaterThanOrEqualTo(0));
    expect(pageEnd, greaterThan(pageStart));

    final firstPage = transformed.substring(pageStart, pageEnd);
    expect(firstPage, contains("en: 'Read today.\\nCheck reality tomorrow.',"));
    expect(
      firstPage,
      contains(
        "en: 'One private reading. One grounded action. In 24 hours, Mystic Mirror asks what actually changed.',",
      ),
    );
    expect(firstPage, contains("en: 'PRIVATE JOURNAL',"));
    expect(firstPage, isNot(contains("en: '78 ARCANA',")));
    expect(firstPage, isNot(contains("en: 'PATTERN MEMORY',")));
    expect(firstPage, contains('LaunchContinuityTimeline('));
    expect(firstPage, contains('children: launchLanguages'));
  });

  test('activation CTA is concrete instead of generic journey language', () {
    final source = File('lib/src/app.dart').readAsStringSync();
    final transformed = materializeOnboardingClaritySource(source);

    expect(transformed, contains("en: 'Start with one reading',"));
    expect(transformed, isNot(contains("en: 'Begin my journey',")));
  });

  test('onboarding clarity transform is idempotent', () {
    final source = File('lib/src/app.dart').readAsStringSync();
    final once = materializeOnboardingClaritySource(source);
    final twice = materializeOnboardingClaritySource(once);

    expect(twice, once);
  });

  test('store configuration always applies onboarding clarity', () {
    final source = File(
      'tool/configure_store_identifiers.dart',
    ).readAsStringSync();

    expect(
      source,
      contains(
        "import 'materialize_onboarding_clarity.dart' as onboarding_clarity;",
      ),
    );
    expect(
      source,
      contains('onboarding_clarity.materializeOnboardingClarity();'),
    );
  });

  test('unexpected source fails closed', () {
    expect(
      () => materializeOnboardingClaritySource('no onboarding anchors'),
      throwsStateError,
    );
  });
}
