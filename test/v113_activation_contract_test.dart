import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final app = File('lib/src/app.dart').readAsStringSync();
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final workflow = File('.github/workflows/flutter-ci.yml').readAsStringSync();
  final nativeService = File(
    'lib/src/ritual_reminder_service_native.dart',
  ).readAsStringSync();

  test('v1.13 activation remains protected in later releases', () {
    expect(_isAtLeast(pubspec, major: 1, minor: 13), isTrue);
    expect(app, contains("en: 'Reveal my first card'"));
    expect(app, contains('_startReading(ReadingKind.daily)'));
  });

  test('daily reminder remains private, contextual and user controlled', () {
    expect(app, contains('_maybeOfferRitualReminder'));
    expect(app, contains('journal.isEmpty'));
    expect(app, contains('record.kind == ReadingKind.daily'));
    expect(
      nativeService,
      contains('AndroidScheduleMode.inexactAllowWhileIdle'),
    );
    expect(nativeService, contains('DateTimeComponents.time'));
    expect(
      nativeService,
      isNot(contains('AndroidScheduleMode.exactAllowWhileIdle')),
    );
    expect(nativeService, isNot(contains('journal')));
  });

  test('saved readings expose the existing privacy-safe story studio', () {
    expect(app, contains('Create a private story card'));
    expect(app, contains('_openStoryStudio(record)'));
  });

  test(
    'release workflow configures native notification shell without source leaks',
    () {
      expect(workflow, contains('Configure daily ritual notifications'));
      expect(workflow, isNot(contains('Upload temporary source snapshot')));
      expect(workflow, isNot(contains('mystic-tarot-source')));
    },
  );
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
