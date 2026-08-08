import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('advertising-only runtime exposes no legacy paid copy', () {
    final app = File('lib/src/app.dart').readAsStringSync();
    final intelligence = File(
      'lib/src/mystic_plus_intelligence_screen.dart',
    ).readAsStringSync();
    final access = File(
      'lib/src/store_ready_premium_screen.dart',
    ).readAsStringSync();

    expect(app, contains('bool isPlus = true'));
    expect(app, contains('Free · advertising-supported'));
    expect(app, contains('Advertising privacy choices'));
    expect(app, isNot(contains('Mystic Plus')));
    expect(app, isNot(contains('View plan and manage subscription')));
    expect(intelligence, contains('MYSTIC INTELLIGENCE'));
    expect(intelligence, isNot(contains('Mystic Plus')));
    expect(intelligence, isNot(contains('View and manage my plan')));
    expect(access, contains('Everything is unlocked.'));
    expect(access, isNot(contains('Manage subscription')));
  });
}
