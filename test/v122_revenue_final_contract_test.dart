import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v1.23 product remains hardened under advertising-only revenue', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final access = File(
      'lib/src/store_ready_premium_screen.dart',
    ).readAsStringSync();
    final adService = File(
      'lib/src/ad_revenue_service.dart',
    ).readAsStringSync();
    final adPolicy = File(
      'lib/src/ad_experience_policy.dart',
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
    final historicalNotes = File('RELEASE_NOTES_1.22.md').readAsStringSync();
    final currentNotes = File('RELEASE_NOTES_1.23.0.md').readAsStringSync();
    final storePack = File('STORE_RELEASE.md').readAsStringSync();

    expect(pubspec, contains('version: 1.23.0+33'));
    expect(pubspec, contains('google_mobile_ads: ^9.0.0'));
    expect(access, contains('Everything is unlocked.'));
    expect(access, contains('there is no subscription to buy'));
    expect(access, contains('Continue free'));
    expect(access, contains('Navigator.pop(context, true)'));
    expect(access, isNot(contains('MOST POPULAR')));
    expect(access, isNot(contains('limited time')));
    expect(access, isNot(contains('Manage subscription')));

    expect(adService, contains("import 'ad_experience_policy.dart';"));
    expect(adService, contains('ConsentInformation.instance.canRequestAds()'));
    expect(adService, contains('AppOpenAd.load'));
    expect(adService, contains('InterstitialAd.load'));
    expect(
      adService,
      contains('AdExperiencePolicy.minimumAppOpenInterval'),
    );
    expect(
      adService,
      contains('AdExperiencePolicy.minimumBackgroundDuration'),
    );
    expect(
      adService,
      contains('AdExperiencePolicy.interstitialEveryReadings'),
    );
    expect(adPolicy, contains('minimumAppOpenInterval = Duration(hours: 2)'));
    expect(
      adPolicy,
      contains('minimumBackgroundDuration = Duration(seconds: 30)'),
    );
    expect(adPolicy, contains('minimumReadingsBeforeAppOpen = 3'));
    expect(adPolicy, contains('interstitialEveryReadings = 3'));
    expect(adPolicy, contains('minimumFullScreenGap = Duration(minutes: 20)'));
    expect(adService, contains('SharedPreferences.getInstance()'));

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
    expect(identifiers, contains('ADMOB_ANDROID_APP_ID'));
    expect(identifiers, contains('ADMOB_IOS_APP_ID'));
    expect(appLock, contains('void configureAppLock({'));
    expect(reminders, contains('void configureRitualNotifications({'));

    expect(
      'dart run tool/configure_store_identifiers.dart'
          .allMatches(production)
          .length,
      greaterThanOrEqualTo(3),
    );
    expect(production, contains('ADMOB_ANDROID_APP_ID'));
    expect(production, contains('ADMOB_IOS_APP_ID'));
    expect(production, contains('MYSTIC_USE_TEST_ADS=false'));
    expect(production, isNot(contains('REVENUECAT_ANDROID_API_KEY')));
    expect(production, isNot(contains('REVENUECAT_IOS_API_KEY')));
    expect(production, contains('Verify Android signature'));
    expect(production, contains('Verify iOS signature and identity'));

    expect(historicalNotes, startsWith('# Mystic Tarot 1.22.0'));
    expect(currentNotes, startsWith('# Mystic Tarot 1.23.0'));
    expect(currentNotes, contains('advertising-supported'));
    expect(storePack, contains('Current source version: `1.23.0+33`'));
    expect(storePack, contains('free and advertising-supported'));
    expect(storePack, contains('MYSTIC_USE_TEST_ADS=false'));

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
