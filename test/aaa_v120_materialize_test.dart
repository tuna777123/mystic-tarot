import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('materialize the focused v1.20 release candidate', () {
    final result = Process.runSync(
      'python3',
      const ['tool/v120_integrate.py'],
      runInShell: false,
    );
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    expect(result.exitCode, 0, reason: 'v1.20 integration script failed');

    const paths = <String>[
      'lib/src/app.dart',
      'lib/src/launch_differentiation.dart',
      'lib/src/mystic_next_step.dart',
      'lib/src/reading_synthesis.dart',
      'lib/src/store_ready_premium_screen.dart',
      'pubspec.yaml',
      'README.md',
      'STORE_RELEASE.md',
      'RELEASE_NOTES.md',
      'RELEASE_NOTES_1.20.md',
      'test/launch_differentiation_test.dart',
      'test/reading_synthesis_test.dart',
      'test/v120_launch_differentiation_contract_test.dart',
    ];

    final files = <String, String>{};
    for (final path in paths) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: 'Missing generated file: $path');
      files[path] = base64Encode(file.readAsBytesSync());
    }

    final payload = base64Encode(
      gzip.encode(utf8.encode(jsonEncode(files))),
    );
    File('web/v120-source-payload.txt').writeAsStringSync(payload);
    expect(payload.length, greaterThan(1000));
  });
}
