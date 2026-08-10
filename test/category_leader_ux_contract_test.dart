import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'first session makes the evidence loop clear and starts with action',
    () {
      final app = File('lib/src/app.dart').readAsStringSync();
      final launch = File(
        'lib/src/launch_differentiation.dart',
      ).readAsStringSync();

      expect(launch, contains('Read today. Check reality tomorrow.'));
      expect(launch, contains('Build private evidence over time.'));
      expect(launch, contains('Mystic Mirror asks what actually happened'));
      expect(launch, contains('PRIVATE EVIDENCE'));
      expect(app, contains('Reveal my first card'));
      expect(app, contains('PATTERN MEMORY'));
      expect(app, contains('PRIVATE JOURNAL'));
      expect(app, contains('Your first reading starts next.'));

      final finishOnboarding = app.indexOf('Future<void> _finishOnboarding(');
      final startFirstDaily = app.indexOf(
        '_startReading(ReadingKind.daily);',
        finishOnboarding,
      );
      expect(finishOnboarding, greaterThanOrEqualTo(0));
      expect(startFirstDaily, greaterThan(finishOnboarding));
    },
  );

  test('selection and reveal preserve an intentional cinematic ritual', () {
    final app = File('lib/src/app.dart').readAsStringSync();

    expect(app, contains('HapticFeedback.selectionClick()'));
    expect(app, contains('MysticSoundscape.instance.selectCard()'));
    expect(app, contains('Seal my selection'));
    expect(app, contains('HapticFeedback.mediumImpact()'));
    expect(app, contains('MysticSoundscape.instance.revealCards()'));
    expect(app, contains('Your cards are\\nwaiting beneath the veil.'));
    expect(
      app,
      contains('Take what resonates. Tarot is a mirror for reflection'),
    );
    expect(app, contains('✦  YOUR GUIDANCE'));
    expect(app, contains('MYSTIC MIRROR • 24H LOOP'));
    expect(app, contains('Tomorrow, Mystic will ask what actually changed.'));
    expect(app, contains('Your reading isn’t finished yet.'));
    expect(app, contains('A reflective path is taking shape.'));
    expect(app, contains('MediaQuery.maybeOf(context)?.disableAnimations'));
    expect(app, contains('Save this reading'));
  });

  test(
    'Mystic Mirror rewards honest reality evidence rather than prediction',
    () {
      final journal = File(
        'lib/src/mystic_living_journal_feature.dart',
      ).readAsStringSync();

      expect(journal, contains('MYSTIC MIRROR IS READY'));
      expect(journal, contains('What actually changed?'));
      expect(
        journal,
        contains('Honest evidence is more useful than a perfect story.'),
      );
      expect(journal, contains('Save honest reflection'));
      expect(journal, contains('This is reflection, not a prediction score.'));
      expect(journal, contains('mysticMirrorShareText(widget.language)'));
      expect(journal, contains('Your Pattern Lab grows with evidence'));
      expect(journal, contains("YESTERDAY'S SIGNAL"));
      expect(
        journal,
        contains('Record reality, not whether tarot was right.'),
      );
      final explanation = File(
        'lib/src/reading_explanation.dart',
      ).readAsStringSync();
      expect(explanation, contains("ValueKey('reading-practical-bridge')"));
    },
  );

  test('full-screen ad disruption state begins only on a real impression', () {
    final service = File('lib/src/ad_revenue_service.dart').readAsStringSync();
    final policy = File('lib/src/ad_experience_policy.dart').readAsStringSync();

    expect(policy, contains('minimumFullScreenGap = Duration(minutes: 20)'));

    final appOpenShow = service.indexOf('void _showAppOpenIfReady()');
    final appOpenImpression = service.indexOf('onAdImpression:', appOpenShow);
    final appOpenTimestamp = service.indexOf(
      '_lastAppOpenShownAt = DateTime.now();',
      appOpenShow,
    );
    final appOpenFullScreenMark = service.indexOf(
      '_markFullScreenShown();',
      appOpenShow,
    );
    expect(appOpenImpression, greaterThan(appOpenShow));
    expect(appOpenTimestamp, greaterThan(appOpenImpression));
    expect(appOpenFullScreenMark, greaterThan(appOpenImpression));

    final interstitialShow = service.indexOf('void _showInterstitialIfReady()');
    final interstitialImpression = service.indexOf(
      'onAdImpression:',
      interstitialShow,
    );
    final interstitialFullScreenMark = service.indexOf(
      '_markFullScreenShown();',
      interstitialShow,
    );
    expect(interstitialImpression, greaterThan(interstitialShow));
    expect(interstitialFullScreenMark, greaterThan(interstitialImpression));
  });
}
