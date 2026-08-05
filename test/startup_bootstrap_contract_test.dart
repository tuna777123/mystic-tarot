import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the product opens before optional reminder initialization', () {
    final mainSource = File('lib/main.dart').readAsStringSync();
    final localeIndex = mainSource.indexOf(
      'await ensureInitialMysticLanguagePreference();',
    );
    final runAppIndex = mainSource.indexOf(
      'runApp(const AppLockGate(child: MysticApp()));',
    );
    final reminderIndex = mainSource.indexOf(
      'unawaited(RitualReminderService.instance.initialize());',
    );

    expect(mainSource, contains("import 'dart:async';"));
    expect(localeIndex, greaterThanOrEqualTo(0));
    expect(runAppIndex, greaterThan(localeIndex));
    expect(reminderIndex, greaterThan(runAppIndex));
    expect(
      mainSource,
      isNot(contains('await RitualReminderService.instance.initialize();')),
    );
  });
}
