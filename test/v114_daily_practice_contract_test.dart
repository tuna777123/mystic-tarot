import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final app = File('lib/src/app.dart').readAsStringSync();
  final practice = File('lib/src/daily_practice.dart').readAsStringSync();
  final state = File('lib/src/daily_state.dart').readAsStringSync();
  final pubspec = File('pubspec.yaml').readAsStringSync();

  test('v1.14 wires the daily practice into the real home quest', () {
    expect(_isAtLeast(pubspec, major: 1, minor: 14), isTrue);
    expect(app, contains('onRitual: _openDailyPractice'));
    expect(app, contains('showDailyPracticeSheet'));
    expect(app, contains('dailyPracticeId(result)'));
  });

  test('private writing is deliberately ephemeral', () {
    expect(practice, contains('This text disappears'));
    expect(practice, isNot(contains('SharedPreferences')));
    expect(practice, isNot(contains('ReadingJournalStore')));
    expect(practice, isNot(contains('RitualReminderService')));
  });

  test('open apps refresh all daily buckets at local midnight', () {
    expect(app, contains('_scheduleDayBoundary'));
    expect(app, contains('evaluateMysticDailyRefresh'));
    expect(app, contains('completedRituals.clear()'));
    expect(app, contains('deepReadingsToday = 0'));
    expect(state, contains('durationUntilNextMysticDay'));
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
