import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('native monetization is Google Mobile Ads with UMP consent', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final service = File('lib/src/ad_revenue_service.dart').readAsStringSync();
    final policy = File('lib/src/ad_experience_policy.dart').readAsStringSync();
    final main = File('lib/main.dart').readAsStringSync();

    expect(pubspec, contains('google_mobile_ads: 9.0.0'));
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
    expect(service, contains("import 'ad_experience_policy.dart';"));
    expect(service, contains('AdExperiencePolicy.interstitialEveryReadings'));
    expect(service, contains('AdExperiencePolicy.appOpenEligible('));
    expect(service, contains('AdExperiencePolicy.minimumBackgroundDuration'));
    expect(policy, contains('interstitialEveryReadings = 4'));
    expect(policy, contains('minimumReadingsBeforeAppOpen = 5'));
    expect(
      policy,
      contains('minimumBackgroundDuration = Duration(minutes: 1)'),
    );
    expect(policy, contains('minimumAppOpenInterval = Duration(hours: 6)'));
    expect(policy, contains('minimumFullScreenGap = Duration(minutes: 45)'));
    expect(service, contains('SharedPreferences.getInstance()'));
    expect(service, contains('MYSTIC_USE_TEST_ADS'));
    expect(service, contains('ADMOB_ANDROID_APP_OPEN_ID'));
    expect(service, contains('ADMOB_IOS_APP_OPEN_ID'));
    expect(service, contains('ADMOB_ANDROID_INTERSTITIAL_ID'));
    expect(service, contains('ADMOB_IOS_INTERSTITIAL_ID'));
  });

  test('release-facing advertising documentation matches runtime cadence', () {
    final documents = <String, String>{
      'README.md': File('README.md').readAsStringSync(),
      'STORE_RELEASE.md': File('STORE_RELEASE.md').readAsStringSync(),
      'docs/AD_REVENUE_MODEL.md': File(
        'docs/AD_REVENUE_MODEL.md',
      ).readAsStringSync(),
      'docs/FINAL_DELIVERY.md': File(
        'docs/FINAL_DELIVERY.md',
      ).readAsStringSync(),
      'docs/OWNER_FINAL_CHECKLIST.md': File(
        'docs/OWNER_FINAL_CHECKLIST.md',
      ).readAsStringSync(),
      'docs/OWNER_GUIDE_A_TO_Z.md': File(
        'docs/OWNER_GUIDE_A_TO_Z.md',
      ).readAsStringSync(),
    };

    final combined = documents.values.join('\n');
    expect(combined, contains('five completed readings'));
    expect(combined, contains('one minute'));
    expect(combined, contains('six hours'));
    expect(combined, contains('45-minute'));
    expect(combined, contains('every fourth'));

    const stalePhrases = <String>[
      'every third genuinely new saved reading',
      'at least three completed readings',
      'at least 30 seconds in the background',
      'once every two hours',
      'every-third-new-reading',
      'reading 3 creates an eligible interstitial opportunity',
      'no app-open before 3 readings',
      'background <30 seconds',
      '2-hour app-open minimum interval',
      'first two new readings remain uninterrupted',
    ];
    for (final entry in documents.entries) {
      for (final stale in stalePhrases) {
        expect(
          entry.value,
          isNot(contains(stale)),
          reason: '${entry.key} contains stale ad cadence: $stale',
        );
      }
    }
  });

  test('subscription runtime is completely absent from the ad-only binary', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final subscriptionClient = File(
      'lib/src/subscription_client.dart',
    ).readAsStringSync();
    final store = File(
      'lib/src/store_purchase_service.dart',
    ).readAsStringSync();
    final paywall = File(
      'lib/src/store_ready_premium_screen.dart',
    ).readAsStringSync();

    expect(pubspec, isNot(contains('purchases_flutter')));
    expect(subscriptionClient, isNot(contains('package:purchases_flutter')));
    expect(subscriptionClient, isNot(contains('RevenueCatSubscriptionClient')));
    expect(subscriptionClient, isNot(contains('Purchases.configure(')));
    expect(subscriptionClient, isNot(contains('Purchases.purchase(')));
    expect(store, contains('advertising-only business model'));
    expect(store, contains('bool isPlus = true'));
    expect(store, contains('bool get canPurchase => false'));
    expect(store, contains('bool get canRestore => false'));
    expect(store, isNot(contains('RevenueCatSubscriptionClient()')));
    expect(paywall, contains('there is no subscription to buy'));
    expect(paywall, contains('Continue free'));
  });

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
