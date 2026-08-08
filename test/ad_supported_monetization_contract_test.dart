import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('native monetization is Google Mobile Ads with UMP consent', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final service = File('lib/src/ad_revenue_service.dart').readAsStringSync();
    final main = File('lib/main.dart').readAsStringSync();

    expect(pubspec, contains('google_mobile_ads: ^9.0.0'));
    expect(main, contains('AdRevenueService.instance.initialize()'));
    expect(
      service,
      contains('ConsentInformation.instance.requestConsentInfoUpdate'),
    );
    expect(service, contains('ConsentForm.loadAndShowConsentFormIfRequired'));
    expect(service, contains('ConsentInformation.instance.canRequestAds()'));
    expect(service, contains('getPrivacyOptionsRequirementStatus'));
    expect(service, contains('PrivacyOptionsRequirementStatus.required'));
    expect(service, contains('MobileAds.instance.initialize()'));
    expect(service, contains('AppOpenAd.load'));
    expect(service, contains('InterstitialAd.load'));
    expect(service, contains('_interstitialEveryReadings = 3'));
    expect(service, contains('_minimumReadingsBeforeAppOpen = 3'));
    expect(
      service,
      contains('_minimumBackgroundDuration = Duration(seconds: 30)'),
    );
    expect(service, contains('_minimumAppOpenInterval = Duration(hours: 2)'));
    expect(service, contains('SharedPreferences.getInstance()'));
    expect(service, contains('MYSTIC_USE_TEST_ADS'));
    expect(service, contains('ADMOB_ANDROID_APP_OPEN_ID'));
    expect(service, contains('ADMOB_IOS_APP_OPEN_ID'));
    expect(service, contains('ADMOB_ANDROID_INTERSTITIAL_ID'));
    expect(service, contains('ADMOB_IOS_INTERSTITIAL_ID'));
  });

  test(
    'subscription revenue is retired without deleting compatibility code',
    () {
      final store = File(
        'lib/src/store_purchase_service.dart',
      ).readAsStringSync();
      final paywall = File(
        'lib/src/store_ready_premium_screen.dart',
      ).readAsStringSync();

      expect(store, contains('advertising-only business model'));
      expect(store, contains('bool isPlus = true'));
      expect(store, contains('bool get canPurchase => false'));
      expect(store, contains('bool get canRestore => false'));
      expect(store, isNot(contains('RevenueCatSubscriptionClient()')));
      expect(paywall, contains('there is no subscription to buy'));
      expect(paywall, contains('Continue free'));
    },
  );

  test(
    'native shells receive AdMob app IDs and saved readings drive cadence',
    () {
      final configure = File(
        'tool/configure_store_identifiers.dart',
      ).readAsStringSync();
      final journal = File(
        'lib/src/reading_journal_store.dart',
      ).readAsStringSync();

      expect(configure, contains('ADMOB_ANDROID_APP_ID'));
      expect(configure, contains('ADMOB_IOS_APP_ID'));
      expect(configure, contains('com.google.android.gms.ads.APPLICATION_ID'));
      expect(configure, contains('GADApplicationIdentifier'));
      expect(journal, contains('onNewReadingSaved'));
      expect(journal, contains('nextCount == previousCount + 1'));
      expect(journal, contains('recordCompletedReading'));
    },
  );
}
