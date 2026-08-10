import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/configure_store_identifiers.dart';
import '../tool/src/ios_admob_plist_audit.dart';

void main() {
  const productionLikeAppId = 'ca-app-pub-1234567890123456~1234567890';
  const minimalPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
\t<key>CFBundleIdentifier</key>
\t<string>com.tunabozcali.mystictarot</string>
</dict>
</plist>
''';

  test('accepts the exact production app id and reviewed SKAdNetwork set', () {
    final xml = materializeIosAdMobPlist(minimalPlist, productionLikeAppId);
    final result = auditIosAdMobPlistXml(
      xml,
      expectedAppId: productionLikeAppId,
    );

    expect(result.appId, productionLikeAppId);
    expect(result.skAdNetworkCount, iosSkAdNetworkIdentifiers.length);
  });

  test('rejects a different AdMob application id', () {
    final xml = materializeIosAdMobPlist(minimalPlist, productionLikeAppId);

    expect(
      () => auditIosAdMobPlistXml(
        xml,
        expectedAppId: 'ca-app-pub-9999999999999999~9999999999',
      ),
      throwsA(isA<IosAdMobPlistAuditFailure>()),
    );
  });

  test('rejects a missing reviewed SKAdNetwork identifier', () {
    final xml = materializeIosAdMobPlist(minimalPlist, productionLikeAppId);
    final missing = xml.replaceFirst(
      '<string>${iosSkAdNetworkIdentifiers.first}</string>',
      '',
    );

    expect(
      () => auditIosAdMobPlistXml(
        missing,
        expectedAppId: productionLikeAppId,
      ),
      throwsA(isA<IosAdMobPlistAuditFailure>()),
    );
  });

  test('rejects duplicate SKAdNetwork identifiers', () {
    final xml = materializeIosAdMobPlist(minimalPlist, productionLikeAppId);
    final marker = '<string>${iosSkAdNetworkIdentifiers.first}</string>';
    final duplicate = xml.replaceFirst(marker, '$marker\n$marker');

    expect(
      () => auditIosAdMobPlistXml(
        duplicate,
        expectedAppId: productionLikeAppId,
      ),
      throwsA(isA<IosAdMobPlistAuditFailure>()),
    );
  });

  test('production release manifest fail-closes on exported iOS AdMob drift', () {
    final source = File('tool/write_release_manifest.dart').readAsStringSync();
    final workflow = File('.github/workflows/store-release.yml').readAsStringSync();

    expect(source, contains("Platform.environment['ADMOB_IOS_APP_ID']"));
    expect(source, contains('verifyIosArtifactAdMobConfiguration('));
    expect(source, contains("'productionAdMobAppIdVerified': true"));
    expect(source, contains("'skAdNetworkCount': iosAdMobAudit.skAdNetworkCount"));
    expect(
      workflow,
      contains('dart run tool/write_release_manifest.dart --platform=ios'),
    );
  });
}
