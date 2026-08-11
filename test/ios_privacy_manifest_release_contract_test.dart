import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS CI audits and uploads privacy manifest evidence', () {
    final workflow = File('.github/workflows/ios-ci.yml').readAsStringSync();

    expect(
      workflow,
      contains('dart run tool/audit_ios_privacy_manifests.dart'),
    );
    expect(workflow, contains('--app=build/ios/iphoneos/Runner.app'));
    expect(
      workflow,
      contains('build/reports/ios-privacy-manifest-evidence.json'),
    );
    expect(workflow, contains('mystic-tarot-ios-privacy-manifest-evidence'));
  });

  test(
    'signed iOS release manifest fails closed through IPA privacy audit',
    () {
      final writer = File(
        'tool/write_release_manifest.dart',
      ).readAsStringSync();
      final productionWorkflow = File(
        '.github/workflows/store-release.yml',
      ).readAsStringSync();

      expect(writer, contains("import 'src/ios_privacy_manifest_audit.dart';"));
      expect(writer, contains('verifyIosArtifactPrivacyManifests('));
      expect(writer, contains("'privacyManifestsVerified': true"));
      expect(writer, contains("'privacyManifestCount':"));
      expect(writer, contains("'privacyManifestPaths':"));
      expect(writer, contains('ios-privacy-manifest-evidence.json'));
      expect(
        productionWorkflow,
        contains('dart run tool/write_release_manifest.dart --platform=ios'),
        reason:
            'The signed IPA must keep using the release manifest writer that '
            'enforces privacy-manifest evidence.',
      );
    },
  );
}
