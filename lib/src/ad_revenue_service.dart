import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Privacy-aware, ad-only monetization for native Mystic Tarot builds.
///
/// The public web edition intentionally remains ad-free because the official
/// Google Mobile Ads Flutter plugin supports Android and iOS, not web.
class AdRevenueService {
  AdRevenueService._();

  static final AdRevenueService instance = AdRevenueService._();

  static const _androidTestInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const _iosTestInterstitial =
      'ca-app-pub-3940256099942544/4411468910';

  static const _androidProductionInterstitial = String.fromEnvironment(
    'ADMOB_ANDROID_INTERSTITIAL_ID',
  );
  static const _iosProductionInterstitial = String.fromEnvironment(
    'ADMOB_IOS_INTERSTITIAL_ID',
  );
  static const _useTestAds = bool.fromEnvironment(
    'MYSTIC_USE_TEST_ADS',
    defaultValue: true,
  );

  InterstitialAd? _interstitial;
  bool _initializing = false;
  bool _initialized = false;
  int _completedReadingsSinceAd = 0;

  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  bool get privacyOptionsAvailable => supported;

  String? get _interstitialId {
    if (!supported) return null;
    if (_useTestAds) {
      return defaultTargetPlatform == TargetPlatform.android
          ? _androidTestInterstitial
          : _iosTestInterstitial;
    }
    final configured = defaultTargetPlatform == TargetPlatform.android
        ? _androidProductionInterstitial
        : _iosProductionInterstitial;
    return configured.trim().isEmpty ? null : configured.trim();
  }

  Future<void> initialize() async {
    if (!supported || _initialized || _initializing) return;
    _initializing = true;
    try {
      final completer = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () {
          ConsentForm.loadAndShowConsentFormIfRequired((_) async {
            await _initializeAdsIfAllowed();
            if (!completer.isCompleted) completer.complete();
          });
        },
        (_) async {
          await _initializeAdsIfAllowed();
          if (!completer.isCompleted) completer.complete();
        },
      );
      await completer.future;
    } finally {
      _initializing = false;
    }
  }

  Future<void> _initializeAdsIfAllowed() async {
    if (_initialized || !supported) return;
    final canRequest = await ConsentInformation.instance.canRequestAds();
    if (!canRequest) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    _loadInterstitial();
  }

  void recordCompletedReading() {
    if (!_initialized) return;
    _completedReadingsSinceAd += 1;
    if (_completedReadingsSinceAd < 3) return;
    _completedReadingsSinceAd = 0;
    _showInterstitialIfReady();
  }

  void _loadInterstitial() {
    final id = _interstitialId;
    if (!_initialized || id == null || _interstitial != null) return;
    InterstitialAd.load(
      adUnitId: id,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitial = null;
              _loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose();
              _interstitial = null;
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (_) {
          _interstitial = null;
        },
      ),
    );
  }

  void _showInterstitialIfReady() {
    final ad = _interstitial;
    if (ad == null) {
      _loadInterstitial();
      return;
    }
    _interstitial = null;
    ad.show();
  }

  void showPrivacyOptions() {
    if (!supported) return;
    ConsentForm.showPrivacyOptionsForm((_) {});
  }

  void dispose() {
    _interstitial?.dispose();
    _interstitial = null;
  }
}
