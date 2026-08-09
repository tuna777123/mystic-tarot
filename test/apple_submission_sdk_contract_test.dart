import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Apple submission SDK verifier stays fail-closed at major 26', () {
    final verifier = File('tool/verify_apple_submission_sdk.sh');

    expect(verifier.existsSync(), isTrue);
    final source = verifier.readAsStringSync();
    expect(source, contains('minimum_xcode_major=26'));
    expect(source, contains('minimum_ios_sdk_major=26'));
    expect(source, contains('xcodebuild -version'));
    expect(source, contains('xcrun --sdk iphoneos --show-sdk-version'));
  });

  test('unsigned and production iOS release paths use the SDK gate', () {
    final iosCi = File('.github/workflows/ios-ci.yml').readAsStringSync();
    final preflight = File(
      'tool/store_release_preflight.dart',
    ).readAsStringSync();
    final production = File(
      '.github/workflows/store-release.yml',
    ).readAsStringSync();

    expect(iosCi, contains('Verify Apple submission SDK floor'));
    expect(iosCi, contains('tool/verify_apple_submission_sdk.sh'));
    expect(preflight, contains('tool/verify_apple_submission_sdk.sh'));
    expect(production, contains('store_release_preflight.dart --platform=ios'));
  });
}
