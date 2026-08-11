import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v1.21 launch differentiation contract stays complete', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final app = File('lib/src/app.dart').readAsStringSync();
    final continuity = File(
      'lib/src/launch_differentiation.dart',
    ).readAsStringSync();
    final positions = File('lib/src/reading_position.dart').readAsStringSync();
    final synthesis = File('lib/src/reading_synthesis.dart').readAsStringSync();
    final nextStep = File('lib/src/mystic_next_step.dart').readAsStringSync();
    final premium = File(
      'lib/src/store_ready_premium_screen.dart',
    ).readAsStringSync();
    final notes = File('RELEASE_NOTES_1.21.md').readAsStringSync();

    final version = RegExp(
      r'version: 1\.(\d+)\.(\d+)\+(\d+)',
    ).firstMatch(pubspec);
    expect(version, isNotNull);
    expect(int.parse(version!.group(1)!), greaterThanOrEqualTo(21));
    expect(int.parse(version.group(3)!), greaterThanOrEqualTo(27));
    expect(app, contains("import 'launch_differentiation.dart';"));
    expect(app, contains("import 'reading_synthesis.dart';"));
    expect(app, contains('LaunchContinuityTimeline('));
    expect(app, contains('buildReadingSynthesis('));
    expect(continuity, contains('Read today. Check reality tomorrow.'));
    expect(continuity, contains('THE MYSTIC LOOP'));
    expect(
      continuity,
      contains('A READING SHOULD LEAVE EVIDENCE, NOT JUST A FEELING.'),
    );
    expect(continuity, contains('Build private evidence over time.'));
    expect(continuity, contains('No prediction score.'));
    expect(continuity, contains('Private by design'));
    expect(continuity, contains('No account or cloud journal.'));
    expect(continuity, contains('optional PIN and biometrics'));
    expect(
      continuity,
      contains('Native ads respect available advertising privacy choices'),
    );
    expect(continuity, contains('public web edition stays ad-free'));
    expect(File('lib/src/app_lock.dart').existsSync(), isTrue);
    expect(File('lib/src/app_lock_gate.dart').existsSync(), isTrue);
    expect(nextStep, contains('MysticGrowthStage.activated'));
    expect(nextStep, contains('LaunchContinuityTimeline('));
    expect(nextStep, contains('PRIVATE EVIDENCE MEMORY'));
    expect(premium, contains('Everything is unlocked.'));
    expect(premium, contains('there is no subscription to buy'));
    expect(synthesis, contains('Taken together'));
    expect(synthesis, contains('lenses.length == 2'));
    expect(synthesis, contains('ReadingKind.compatibility'));
    expect(synthesis, contains('ReadingKind.timeline'));
    expect(synthesis, contains('ReadingKind.celticCross'));
    expect(synthesis, contains('Try this grounded action'));
    expect(synthesis, contains('localizedEmotionLabel'));
    expect(synthesis, contains('not a prediction'));
    expect(positions, contains('The shared growth edge'));
    expect(positions, contains('The next honest step for the connection'));
    expect(positions, contains('The choice that can change the trajectory'));
    expect(notes, startsWith('# Mystic Tarot 1.21.0'));
    expect(File('.github/workflows/v121-integrate.yml').existsSync(), isFalse);
    expect(File('tool/v121_integrate.py').existsSync(), isFalse);
  });
}
