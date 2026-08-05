import 'dart:async';

import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/app_locale.dart';
import 'src/app_lock_gate.dart';
import 'src/app_observability.dart';
import 'src/ritual_reminder_service.dart';

Future<void> main() async {
  MysticAppObservability.configure();
  await MysticAppObservability.run(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await ensureInitialMysticLanguagePreference();
    runApp(const AppLockGate(child: MysticApp()));
    unawaited(RitualReminderService.instance.initialize());
  });
}
