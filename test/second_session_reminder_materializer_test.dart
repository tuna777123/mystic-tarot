import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/materialize_second_session_reminder.dart';

void main() {
  const firstSessionSource = '''
void complete() {
            final shouldOfferRitualReminder =
                journal.isEmpty && record.kind == ReadingKind.daily;
}
''';
  const sameDaySecondReadingSource = '''
void complete() {
            final shouldOfferRitualReminder =
                journal.isNotEmpty && record.kind == ReadingKind.daily;
}
''';

  test('ritual reminder requires a prior daily reading from another day', () {
    final transformed = transformSecondSessionReminder(firstSessionSource);

    expect(transformed, contains('journal.any('));
    expect(transformed, contains('saved.kind == ReadingKind.daily'));
    expect(
      transformed,
      contains('_dayKey(saved.createdAt) != _dayKey(record.createdAt)'),
    );
    expect(
      transformed,
      isNot(contains('journal.isNotEmpty && record.kind == ReadingKind.daily')),
    );
    expect(
      transformed,
      isNot(contains('journal.isEmpty && record.kind == ReadingKind.daily')),
    );
  });

  test('previous same-day deferred form upgrades to later-day return', () {
    final transformed = transformSecondSessionReminder(
      sameDaySecondReadingSource,
    );

    expect(transformed, contains('journal.any('));
    expect(
      transformed,
      contains('_dayKey(saved.createdAt) != _dayKey(record.createdAt)'),
    );
  });

  test('transformation is idempotent', () {
    final once = transformSecondSessionReminder(firstSessionSource);
    final twice = transformSecondSessionReminder(once);

    expect(twice, once);
  });

  test('release materialization wires the deferred reminder pass', () {
    final optionalName = File(
      'tool/materialize_optional_name_onboarding.dart',
    ).readAsStringSync();
    final app = File('lib/src/app.dart').readAsStringSync();

    expect(
      optionalName,
      contains('second_session_reminder.materializeSecondSessionReminder();'),
    );
    expect(app, contains('if (!mounted || settings.promptCompleted) return;'));
  });

  test('unexpected onboarding source fails closed', () {
    expect(
      () => transformSecondSessionReminder('no known reminder anchor'),
      throwsStateError,
    );
  });
}
