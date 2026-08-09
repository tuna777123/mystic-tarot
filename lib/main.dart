import 'dart:async';

import 'package:flutter/material.dart';

import 'src/ad_revenue_service.dart';
import 'src/app.dart';
import 'src/app_locale.dart';
import 'src/app_lock_gate.dart';
import 'src/app_observability.dart';
import 'src/business_metrics_bootstrap.dart';
import 'src/ritual_reminder_service.dart';

Future<void> main() async {
  MysticAppObservability.configure();
  await MysticAppObservability.run(() async {
    WidgetsFlutterBinding.ensureInitialized();
    MysticBusinessMetricsBootstrap.configure();
    await ensureInitialMysticLanguagePreference();
    runApp(const AppLockGate(child: MysticApp()));
    MysticBusinessMetricsBootstrap.recordLaunch();
    unawaited(RitualReminderService.instance.initialize());
    unawaited(AdRevenueService.instance.initialize());
  });
}
