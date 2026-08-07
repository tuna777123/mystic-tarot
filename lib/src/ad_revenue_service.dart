import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Privacy-aware, advertising-only monetization for native Mystic Tarot builds.
///
/// Revenue formats:
/// - app-open ads on eligible returning foreground transitions;
/// - interstitial ads after every third genuinely new saved reading.
///
/// The public web edition intentionally remains ad-free because the official
/// Google Mobile Ads Flutter plugin supports Android and iOS, not web.
class AdRevenueService with WidgetsBindingObserver {
  AdRevenueService._();

  static final AdRevenueService instance = AdRevenueService._();

  static const _androidTestAppOpen = 'ca-app-pub-3940256099942544/9257395921';
  static const _iosTestAppOpen = 'ca-app-pub-3940256099942544/5575463023';
  static const _androidTestInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const _iosTestInterstitial = 'ca-app-pub-3940256099942544/4411468910';

  static const _androidProductionAppOpen = String.fromEnvironment(
    'ADMOB_ANDROID_APP_OPEN_ID',
  );
  static const _iosProductionAppOpen = String.fromEnvironment(
    'ADMOB_IOS_APP_OPEN_ID',
  );
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

  static const _maxAppOpenCacheAge = Duration(hours: 4);
  static const _minimumAppOpenInterval = Duration(hours: 1);

  AppOpenAd? _appOpenAd;
  DateTime? _appOpenLoadedAt;
  DateTime? _lastAppOpenShownAt;
  InterstitialAd? _interstitial;
  bool _initializing = false;
  bool _initialized = false;
  bool _observerAttached = false;
  bool _showingFullScreenAd = false;
  bool _hasBackgroundedSinceInitialization = false;
  int _completedReadingsSinceAd = 0;

  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  bool get privacyOptionsAvailable => supported;

  String? get _appOpenId {
    if (!supported) return null;
    if (_useTestAds) {
      return defaultTargetPlatform == TargetPlatform.android
          ? _androidTestAppOpen
          : _iosTestAppOpen;
    }
    final configured = defaultTargetPlatform == TargetPlatform.android
        ? _androidProductionAppOpen
        : _iosProductionAppOpen;
    return configured.trim().isEmpty ? null : configured.trim();
  }

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
          // A previous valid consent decision may still permit requests after a
          // transient refresh error. canRequestAds() remains the final gate.
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
    if (!_observerAttached) {
      WidgetsBinding.instance.addObserver(this);
      _observerAttached = true;
    }
    _loadAppOpen();
    _loadInterstitial();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_initialized) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _hasBackgroundedSinceInitialization = true;
      return;
    }
    if (state != AppLifecycleState.resumed ||
        !_hasBackgroundedSinceInitialization) {
      return;
    }
    _hasBackgroundedSinceInitialization = false;
    _showAppOpenIfReady();
  }

  /// Called only when a genuinely new reading is persisted.
  ///
  /// The first two new readings remain uninterrupted; the third may show a
  /// preloaded interstitial at the natural completion boundary.
  void recordCompletedReading() {
    if (!_initialized || _showingFullScreenAd) return;
    _completedReadingsSinceAd += 1;
    if (_completedReadingsSinceAd < 3) return;
    _completedReadingsSinceAd = 0;
    _showInterstitialIfReady();
  }

  void _loadAppOpen() {
    final id = _appOpenId;
    if (!_initialized || id == null || _appOpenAd != null) return;
    AppOpenAd.load(
      adUnitId: id,
      adRequest: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenLoadedAt = DateTime.now();
        },
        onAdFailedToLoad: (_) {
          _appOpenAd = null;
          _appOpenLoadedAt = null;
        },
      ),
    );
  }

  bool get _appOpenExpired {
    final loadedAt = _appOpenLoadedAt;
    if (loadedAt == null) return true;
    return DateTime.now().difference(loadedAt) >= _maxAppOpenCacheAge;
  }

  bool get _appOpenIntervalSatisfied {
    final shownAt = _lastAppOpenShownAt;
    if (shownAt == null) return true;
    return DateTime.now().difference(shownAt) >= _minimumAppOpenInterval;
  }

  void _showAppOpenIfReady() {
    if (_showingFullScreenAd || !_appOpenIntervalSatisfied) return;
    final ad = _appOpenAd;
    if (ad == null) {
      _loadAppOpen();
      return;
    }
    if (_appOpenExpired) {
      ad.dispose();
      _appOpenAd = null;
      _appOpenLoadedAt = null;
      _loadAppOpen();
      return;
    }

    _showingFullScreenAd = true;
    _lastAppOpenShownAt = DateTime.now();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _showingFullScreenAd = false;
        _appOpenAd = null;
        _appOpenLoadedAt = null;
        _loadAppOpen();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _showingFullScreenAd = false;
        _appOpenAd = null;
        _appOpenLoadedAt = null;
        _loadAppOpen();
      },
    );
    _appOpenAd = null;
    ad.show();
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
        },
        onAdFailedToLoad: (_) {
          _interstitial = null;
        },
      ),
    );
  }

  void _showInterstitialIfReady() {
    if (_showingFullScreenAd) return;
    final ad = _interstitial;
    if (ad == null) {
      _loadInterstitial();
      return;
    }

    _showingFullScreenAd = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _showingFullScreenAd = false;
        _interstitial = null;
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _showingFullScreenAd = false;
        _interstitial = null;
        _loadInterstitial();
      },
    );
    _interstitial = null;
    ad.show();
  }

  void showPrivacyOptions() {
    if (!supported) return;
    ConsentForm.showPrivacyOptionsForm((_) {});
  }

  void dispose() {
    if (_observerAttached) {
      WidgetsBinding.instance.removeObserver(this);
      _observerAttached = false;
    }
    _appOpenAd?.dispose();
    _interstitial?.dispose();
    _appOpenAd = null;
    _interstitial = null;
  }
}
