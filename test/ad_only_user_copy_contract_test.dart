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
    final configurator = File(
      'tool/configure_store_identifiers.dart',
    ).readAsStringSync();
    final materializer = File(
      'tool/materialize_ad_only_ui.dart',
    ).readAsStringSync();

    expect(app, contains('bool isPlus = true'));
    expect(app, contains('Free · advertising-supported'));
    expect(app, contains('Advertising privacy choices'));
    expect(app, isNot(contains('Mystic Plus')));
    expect(app, isNot(contains("'PLUS'")));
    expect(app, isNot(contains('PLUS ACTIVE')));
    expect(app, isNot(contains('PLUS ETKİN')));
    expect(app, isNot(contains('VIEW PLUS')));
    expect(app, isNot(contains('PLUS’I GÖR')));
    expect(app.toLowerCase(), isNot(contains('premium spread')));
    expect(app.toLowerCase(), isNot(contains('premium açılım')));
    expect(app, isNot(contains('View plan and manage subscription')));

    expect(intelligence, contains('MYSTIC INTELLIGENCE'));
    expect(intelligence, contains('FittedBox('));
    expect(intelligence, isNot(contains('Mystic Plus')));
    expect(intelligence, isNot(contains('View and manage my plan')));

    expect(access, contains('Everything is unlocked.'));
    expect(access, isNot(contains('Manage subscription')));

    expect(
      configurator,
      contains("import 'materialize_ad_only_ui.dart' as ad_only_ui;"),
    );
    expect(configurator, contains('ad_only_ui.materializeAdOnlyUi();'));
    expect(materializer, contains('deep-reading paid badge'));
    expect(materializer, contains('responsive Intelligence header'));
    expect(materializer, contains('_rejectLegacyUserCopy'));
  });
}
