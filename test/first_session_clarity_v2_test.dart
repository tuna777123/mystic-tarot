import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/growth_engine.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/tarot_data.dart';

ReadingRecord _firstDaily(DateTime createdAt) {
  return ReadingRecord(
    kind: ReadingKind.daily,
    question: 'What should I notice?',
    cards: [DrawnCard(tarotDeck.first, false)],
    createdAt: createdAt,
    emotion: EmotionalState.curious,
    alignedAction: 'Take one grounded step.',
  );
}

void main() {
  test('first completed daily reading reinforces the Mirror return', () {
    const engine = MysticGrowthEngine();
    final now = DateTime(2026, 9, 1, 18);

    final snapshot = engine.analyze(
      records: [_firstDaily(now)],
      streak: 1,
      completedArcanaDays: 0,
      freeReadingsLeft: 0,
      mirrorDueCount: 0,
      now: now,
    );

    expect(snapshot.stage, MysticGrowthStage.activated);
    expect(snapshot.hasVisiblePattern, isFalse);
    expect(snapshot.nextAction.type, MysticNextActionType.reviewPattern);
    expect(snapshot.nextAction.cta, 'Review my saved reading');
    expect(snapshot.nextAction.body, contains('tomorrow’s Mystic Mirror'));
  });

  test('next-step UI never turns continuity activity into evidence percent', () {
    final source = File('lib/src/mystic_next_step.dart').readAsStringSync();

    expect(source, contains('PRIVATE EVIDENCE MEMORY'));
    expect(source, contains('Reality Evidence is earned'));
    expect(source, contains('No score is inferred from taps, streaks'));
    expect(source, contains('VIEW SAVED READING'));
    expect(source, isNot(contains('snapshot.premiumValueScore')));
    expect(source, isNot(contains('LinearProgressIndicator(')));
  });

  test('reading-history themes are distinguished from Reality Evidence', () {
    final source = File('lib/src/mystic_next_step.dart').readAsStringSync();

    expect(source, contains('A reading-history theme is visible'));
    expect(
      source,
      contains(
        'Reality Evidence still comes only from completed Mirror check-ins.',
      ),
    );
  });
}
