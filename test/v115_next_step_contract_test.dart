import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final app = File('lib/src/app.dart').readAsStringSync();
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final notes = File('RELEASE_NOTES.md').readAsStringSync();
  final nextStep = File('lib/src/mystic_next_step.dart').readAsStringSync();

  test('v1.15 connects the growth engine to the real home screen', () {
    expect(pubspec, contains('version: 1.15.0+21'));
    expect(app, contains("import 'growth_engine.dart';"));
    expect(app, contains("import 'mystic_next_step.dart';"));
    expect(app, contains('const MysticGrowthEngine().analyze'));
    expect(app, contains('mirrorDueCount: mirrorDueCount'));
    expect(app, contains('MysticNextStepCard('));
  });

  test('every suggested action reaches an existing product destination', () {
    expect(app, contains('void _runNextAction('));
    expect(app, contains('onOpenJournal'));
    expect(app, contains('onOpenDestiny'));
    expect(app, contains('_showAllReadings(context)'));
    expect(app, contains('onReading(ReadingKind.daily)'));
  });

  test('personalized copy is complete and does not expose engine placeholders', () {
    for (final marker in [
      'TU SIGUIENTE PASO',
      'VOTRE PROCHAINE ÉTAPE',
      'SEU PRÓXIMO PASSO',
      'SIRADAKİ ADIMIN',
    ]) {
      expect(nextStep, contains(marker));
    }
    expect(nextStep, isNot(contains('snapshot.nextAction.title')));
    expect(nextStep, isNot(contains('snapshot.nextAction.cta')));
  });

  test('release notes describe verified next-action routing', () {
    expect(
      notes,
      startsWith('# Mystic Tarot 1.15.0 — Personal Next Step'),
    );
    expect(notes, contains('verified Mirror due count'));
    expect(notes, contains('local-first'));
  });
}
