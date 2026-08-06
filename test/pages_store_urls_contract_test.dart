import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const localizedStorePages = <String>[
    'privacy.html',
    'privacy-tr.html',
    'privacy-es.html',
    'privacy-fr.html',
    'privacy-pt-br.html',
    'terms.html',
    'terms-tr.html',
    'terms-es.html',
    'terms-fr.html',
    'terms-pt-br.html',
    'support.html',
    'support-tr.html',
    'support-es.html',
    'support-fr.html',
    'support-pt-br.html',
  ];

  test('all launch-language store pages ship with the web source', () {
    for (final page in localizedStorePages) {
      expect(
        File('web/$page').existsSync(),
        isTrue,
        reason: 'Missing public store page: web/$page',
      );
    }
  });

  test('Pages verifies built and live store-facing URLs', () {
    final workflow = File('.github/workflows/pages.yml').readAsStringSync();

    for (final page in localizedStorePages) {
      expect(workflow, contains(page));
    }

    expect(workflow, contains('Verify live application and store URLs'));
    expect(workflow, contains('flutter_bootstrap.js'));
    expect(workflow, contains('<h1>Privacy Policy</h1>'));
    expect(workflow, contains('<h1>Terms of Use</h1>'));
    expect(workflow, contains('<h1>Support</h1>'));
    expect(workflow, contains('--retry-all-errors'));
    expect(workflow, contains(r'LIVE_RESULT: ${{ steps.live.outcome }}'));
    expect(workflow, contains('exit 1'));
  });
}
