import 'dart:async';

import 'package:flutter/foundation.dart';

import 'business_metrics.dart';
import 'local_growth_ledger.dart';

class MysticBusinessMetricsBootstrap {
  MysticBusinessMetricsBootstrap._();

  static bool _configured = false;

  static void configure() {
    if (_configured) return;
    MysticBusinessMetrics.configure(
      reporter: MysticLocalGrowthLedger.instance.record,
    );
    _configured = true;
  }

  static void recordLaunch() {
    configure();
    unawaited(
      MysticBusinessMetrics.record(
        MysticBusinessEvent.appOpened,
        dimensions: <String, String>{'platform': _platform, 'source': 'launch'},
      ),
    );
  }

  static String get _platform {
    if (kIsWeb) return 'web';
    return defaultTargetPlatform.name;
  }
}
