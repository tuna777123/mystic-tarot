import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/app_observability.dart';

Future<void> main() async {
  MysticAppObservability.configure();
  await MysticAppObservability.run(() async {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const MysticApp());
  });
}
