import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('content rating worksheet remains tied to launch architecture', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final worksheet = File(
      'docs/CONTENT_RATING_OWNER_WORKSHEET.md',
    ).readAsStringSync();

    expect(pubspec, contains('google_mobile_ads:'));
    expect(pubspec, contains('url_launcher:'));

    for (final forbiddenDependency in <String>[
      'purchases_flutter:',
      'in_app_purchase:',
      'webview_flutter:',
      'flutter_inappwebview:',
    ]) {
      expect(
        pubspec,
        isNot(contains(forbiddenDependency)),
        reason:
            '$forbiddenDependency changes a store-rating/business-model '
            'assumption and requires worksheet review.',
      );
    }

    expect(worksheet, contains('| Advertising | **Yes** |'));
    expect(worksheet, contains('| User-Generated Content | No |'));
    expect(worksheet, contains('| Messaging and Chat | No |'));
    expect(worksheet, contains('| Unrestricted Web Access | No,'));
    expect(worksheet, contains('| Health or Wellness Topics | **Yes'));

    for (final visualReviewItem in <String>[
      'Horror/Fear Themes',
      'Mature or Suggestive Themes',
      'Sexual Content or Nudity',
      'Cartoon or Fantasy Violence',
      'Realistic Violence',
      'Guns or Other Weapons',
    ]) {
      expect(
        worksheet,
        contains('| $visualReviewItem | **VISUAL REVIEW'),
        reason:
            '$visualReviewItem must remain an explicit signed-art review gate.',
      );
    }

    expect(
      worksheet,
      contains('https://developer.apple.com/help/app-store-connect/'),
    );
    expect(
      worksheet,
      contains('https://support.google.com/googleplay/android-developer/'),
    );
    expect(worksheet, contains('does **not** mark Mystic as “Made for Kids”'));
  });
}
