import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/app_lock_gate.dart';
import 'src/app_observability.dart';
import 'src/ritual_reminder_service.dart';

Future<void> main() async {
  MysticAppObservability.configure();
  await MysticAppObservability.run(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await RitualReminderService.instance.initialize();
    runApp(const AppLockGate(child: MysticApp()));
  });
}
