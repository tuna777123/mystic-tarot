import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web bootstrap keeps Mystic Tarot in full-page mode', () {
    final bootstrap = File('web/flutter_bootstrap.js').readAsStringSync();

    expect(bootstrap, contains('{{flutter_js}}'));
    expect(bootstrap, contains('{{flutter_build_config}}'));
    expect(bootstrap, contains('renderer: "canvaskit"'));
    expect(bootstrap, contains('canvasKitBaseUrl: "canvaskit"'));
    expect(bootstrap, contains('multiViewEnabled: false'));
    expect(
      bootstrap,
      contains('engineInitializer.initializeEngine(engineConfig)'),
    );
    expect(bootstrap, contains('appRunner.runApp()'));
  });
}
