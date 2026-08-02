import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final app = File('lib/src/app.dart').readAsStringSync();
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final workflow = File('.github/workflows/flutter-ci.yml').readAsStringSync();
  final nativeService =
      File('lib/src/ritual_reminder_service_native.dart').readAsStringSync();

  test('v1.13 turns onboarding into the first real value moment', () {
    expect(pubspec, contains('version: 1.13.0+19'));
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

  test('release workflow configures native notification shell without source leaks', () {
    expect(workflow, contains('Configure daily ritual notifications'));
    expect(workflow, isNot(contains('Upload temporary source snapshot')));
    expect(workflow, isNot(contains('mystic-tarot-source')));
  });
}
