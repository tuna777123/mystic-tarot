import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v1.22 revenue-ready final contract stays complete', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final premium = File(
      'lib/src/store_ready_premium_screen.dart',
    ).readAsStringSync();
    final identifiers = File(
      'tool/configure_store_identifiers.dart',
    ).readAsStringSync();
    final appLock = File('tool/configure_app_lock.dart').readAsStringSync();
    final reminders = File(
      'tool/configure_ritual_notifications.dart',
    ).readAsStringSync();
    final production = File(
      '.github/workflows/store-release.yml',
    ).readAsStringSync();
    final notes = File('RELEASE_NOTES_1.22.md').readAsStringSync();
    final currentPatchNotes = File(
      'RELEASE_NOTES_1.22.2.md',
    ).readAsStringSync();
    final storePack = File('STORE_RELEASE.md').readAsStringSync();

    expect(pubspec, contains('version: 1.22.2+31'));
    expect(
      premium.indexOf('..._planIds.map((id) => _productTile(context, id))'),
      lessThan(premium.indexOf('LaunchContinuityTimeline(')),
    );
    expect(
      premium.indexOf("ValueKey('premium-primary-action')"),
      lessThan(premium.indexOf('LaunchContinuityTimeline(')),
    );
    expect(premium, contains("ValueKey('premium-store-retry')"));
    expect(premium, contains("ValueKey('premium-sticky-primary-action')"));
    expect(premium, contains('Future<void> _retryStore()'));
    expect(premium, contains('Widget _renewalDisclosure'));
    expect(premium, contains('Navigator.pop(context, true)'));
    expect(
      premium,
      contains(
        'Daily Guidance and your saved journal remain available without Plus.',
      ),
    );
    expect(premium, isNot(contains('MOST POPULAR')));
    expect(premium, isNot(contains('limited time')));

    expect(
      identifiers,
      contains("import 'configure_app_lock.dart' as app_lock_config;"),
    );
    expect(
      identifiers,
      contains(
        "import 'configure_ritual_notifications.dart' as ritual_config;",
      ),
    );
    expect(identifiers, contains('configureRitualNotifications()'));
    expect(identifiers, contains('configureAppLock('));
    expect(identifiers, contains('requireAndroid: hasAndroid'));
    expect(identifiers, contains('requireIos: hasIos'));
    expect(appLock, contains('void configureAppLock({'));
    expect(reminders, contains('void configureRitualNotifications({'));
    expect(
      'dart run tool/configure_store_identifiers.dart'
          .allMatches(production)
          .length,
      greaterThanOrEqualTo(3),
    );
    expect(production, contains('REVENUECAT_ANDROID_API_KEY'));
    expect(production, contains('REVENUECAT_IOS_API_KEY'));
    expect(production, contains('Verify Android signature'));
    expect(production, contains('Verify iOS signature and identity'));
    expect(notes, startsWith('# Mystic Tarot 1.22.0'));
    expect(currentPatchNotes, startsWith('# Mystic Tarot 1.22.2'));
    expect(storePack, contains('Current verified source version: `1.22.2+31`'));
    expect(storePack, contains('No countdown, fake scarcity'));
    expect(File('tool/v122_revenue_final.py').existsSync(), isFalse);
    expect(File('tool/v122_revenue_final_v2.py').existsSync(), isFalse);
    expect(File('tool/v122_revenue_final_v3.py').existsSync(), isFalse);
    expect(File('tool/v122_revenue_final_v4.py').existsSync(), isFalse);
    expect(File('tool/v122_revenue_final_v5.py').existsSync(), isFalse);
    expect(File('tool/v122_revenue_final_v6.py').existsSync(), isFalse);
    expect(
      File('.github/workflows/v122-materialize.yml').existsSync(),
      isFalse,
    );
  });
}
