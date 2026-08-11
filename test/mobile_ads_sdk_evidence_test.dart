import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/mobile_ads_sdk_evidence.dart';

void main() {
  const lockfile = '''packages:
  google_mobile_ads:
    dependency: "direct main"
    description:
      name: google_mobile_ads
      url: "https://pub.dev"
    source: hosted
    version: "9.0.0"
''';

  test('reads google_mobile_ads from the committed Flutter lockfile', () {
    expect(googleMobileAdsPluginVersionFromLockfile(lockfile), '9.0.0');
    expect(
      () => googleMobileAdsPluginVersionFromLockfile('packages:\n'),
      throwsFormatException,
    );
  });

  test('reads exact Android Mobile Ads and UMP resolved versions', () {
    final evidence = parseAndroidMobileAdsSdkEvidence(
      pubspecLock: lockfile,
      dependencyReport: '''
+--- com.google.android.gms:play-services-ads:25.3.0
\\--- com.google.android.ump:user-messaging-platform:4.0.0
''',
    );

    expect(evidence.platform, 'android');
    expect(evidence.flutterPluginVersion, '9.0.0');
    expect(evidence.mobileAdsSdkVersion, '25.3.0');
    expect(evidence.umpSdkVersion, '4.0.0');
  });

  test('uses Gradle conflict-resolution target versions', () {
    final evidence = parseAndroidMobileAdsSdkEvidence(
      pubspecLock: lockfile,
      dependencyReport: '''
+--- com.google.android.gms:play-services-ads:25.2.0 -> 25.3.0
\\--- com.google.android.ump:user-messaging-platform:3.2.0 -> 4.0.0
''',
    );

    expect(evidence.mobileAdsSdkVersion, '25.3.0');
    expect(evidence.umpSdkVersion, '4.0.0');
  });

  test('reads modern SwiftPM Mobile Ads and UMP package resolutions', () {
    final evidence = parseIosMobileAdsSdkEvidence(
      pubspecLock: lockfile,
      packageResolved: jsonEncode(<String, Object>{
        'version': 3,
        'pins': <Object>[
          <String, Object>{
            'identity': 'swift-package-manager-google-mobile-ads',
            'location':
                'https://github.com/googleads/swift-package-manager-google-mobile-ads',
            'state': <String, Object>{'version': '13.4.0'},
          },
          <String, Object>{
            'identity': 'swift-package-manager-google-user-messaging-platform',
            'location':
                'https://github.com/googleads/swift-package-manager-google-user-messaging-platform.git',
            'state': <String, Object>{'version': '3.1.0'},
          },
        ],
      }),
    );

    expect(evidence.platform, 'ios');
    expect(evidence.flutterPluginVersion, '9.0.0');
    expect(evidence.mobileAdsSdkVersion, '13.4.0');
    expect(evidence.umpSdkVersion, '3.1.0');
  });

  test('reads legacy SwiftPM Package.resolved shape', () {
    final evidence = parseIosMobileAdsSdkEvidence(
      pubspecLock: lockfile,
      packageResolved: jsonEncode(<String, Object>{
        'object': <String, Object>{
          'pins': <Object>[
            <String, Object>{
              'package': 'swift-package-manager-google-mobile-ads',
              'repositoryURL':
                  'https://github.com/googleads/swift-package-manager-google-mobile-ads',
              'state': <String, Object>{'version': '13.3.0'},
            },
            <String, Object>{
              'package': 'swift-package-manager-google-user-messaging-platform',
              'repositoryURL':
                  'https://github.com/googleads/swift-package-manager-google-user-messaging-platform.git',
              'state': <String, Object>{'version': '3.1.0'},
            },
          ],
        },
      }),
    );

    expect(evidence.mobileAdsSdkVersion, '13.3.0');
    expect(evidence.umpSdkVersion, '3.1.0');
  });

  test('fails closed if native Ads or UMP evidence is missing', () {
    expect(
      () => parseAndroidMobileAdsSdkEvidence(
        pubspecLock: lockfile,
        dependencyReport:
            '+--- com.google.android.gms:play-services-ads:25.3.0\n',
      ),
      throwsFormatException,
    );
    expect(
      () => parseIosMobileAdsSdkEvidence(
        pubspecLock: lockfile,
        packageResolved: jsonEncode(<String, Object>{
          'version': 3,
          'pins': <Object>[],
        }),
      ),
      throwsFormatException,
    );
  });

  test('release manifest and CI keep exact SDK evidence wired in', () {
    final manifestWriter = File(
      'tool/write_release_manifest.dart',
    ).readAsStringSync();
    final flutterWorkflow = File(
      '.github/workflows/flutter-ci.yml',
    ).readAsStringSync();
    final iosWorkflow = File('.github/workflows/ios-ci.yml').readAsStringSync();

    expect(manifestWriter, contains("'schemaVersion': 3"));
    expect(manifestWriter, contains("'mobileAdsSdkEvidence':"));
    expect(manifestWriter, contains('collectMobileAdsSdkEvidence('));
    expect(
      flutterWorkflow,
      contains('collect_mobile_ads_sdk_evidence.dart --platform=android'),
    );
    expect(
      iosWorkflow,
      contains('collect_mobile_ads_sdk_evidence.dart --platform=ios'),
    );
  });
}
