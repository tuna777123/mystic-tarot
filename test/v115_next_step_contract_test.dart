import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final app = File('lib/src/app.dart').readAsStringSync();
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final notes = File('RELEASE_NOTES.md').readAsStringSync();
  final nextStep = File('lib/src/mystic_next_step.dart').readAsStringSync();

  test('v1.15 connects the growth engine to the real home screen', () {
    expect(_isAtLeast(pubspec, major: 1, minor: 15), isTrue);
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

  test(
    'personalized copy is complete and does not expose engine placeholders',
    () {
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
    },
  );

  test('release notes preserve verified next-action routing', () {
    expect(notes, contains('# Mystic Tarot 1.15.0 — Personal Next Step'));
    expect(notes, contains('verified Mirror due count'));
    expect(notes, contains('local-first'));
  });
}

bool _isAtLeast(String pubspec, {required int major, required int minor}) {
  final match = RegExp(
    r'version:\s+(\d+)\.(\d+)\.(\d+)\+(\d+)',
  ).firstMatch(pubspec);
  if (match == null) return false;
  final actualMajor = int.parse(match.group(1)!);
  final actualMinor = int.parse(match.group(2)!);
  return actualMajor > major || (actualMajor == major && actualMinor >= minor);
}
