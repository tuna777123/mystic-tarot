import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'business_metrics.dart';
import 'local_growth_ledger.dart';

class MysticBusinessMetricsBootstrap {
  MysticBusinessMetricsBootstrap._();

  static bool _configured = false;
  static final _GrowthActivityObserver _activityObserver =
      _GrowthActivityObserver();

  static void configure() {
    if (_configured) return;
    MysticBusinessMetrics.configure(
      reporter: MysticLocalGrowthLedger.instance.record,
    );
    WidgetsBinding.instance.addObserver(_activityObserver);
    _configured = true;
  }

  static void recordLaunch() {
    configure();
    unawaited(
      _recordActivity(source: 'launch'),
    );
  }

  static Future<void> _recordActivity({required String source}) =>
      MysticBusinessMetrics.record(
        MysticBusinessEvent.appOpened,
        dimensions: <String, String>{'platform': _platform, 'source': source},
      );

  static String get _platform {
    if (kIsWeb) return 'web';
    return defaultTargetPlatform.name;
  }
}

class _GrowthActivityObserver with WidgetsBindingObserver {
  bool _backgrounded = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _backgrounded = true;
      return;
    }
    if (state != AppLifecycleState.resumed || !_backgrounded) return;
    _backgrounded = false;
    unawaited(
      MysticBusinessMetricsBootstrap._recordActivity(source: 'foreground'),
    );
  }
}
