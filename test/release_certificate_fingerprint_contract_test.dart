import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production workflow requires both certificate fingerprints', () {
    final workflow = File(
      '.github/workflows/store-release.yml',
    ).readAsStringSync();

    expect(
      workflow,
      contains(
        'ANDROID_UPLOAD_CERT_SHA256: '
        r'${{ secrets.ANDROID_UPLOAD_CERT_SHA256 }}',
      ),
    );
    expect(
      workflow,
      contains(
        'IOS_DISTRIBUTION_CERT_SHA256: '
        r'${{ secrets.IOS_DISTRIBUTION_CERT_SHA256 }}',
      ),
    );
  });

  test('Android verifies the keystore and final AAB certificate', () {
    final workflow = File(
      '.github/workflows/store-release.yml',
    ).readAsStringSync();

    expect(workflow, contains('keytool -exportcert'));
    expect(workflow, contains('android-upload-cert.der'));
    expect(workflow, contains('android-bundle-cert.pem'));
    expect(workflow, contains('ACTUAL_UPLOAD_CERT_SHA256'));
    expect(workflow, contains('ACTUAL_BUNDLE_CERT_SHA256'));
    expect(workflow, contains('-checkend 2592000'));

    final installIndex = workflow.indexOf(
      'Install and verify Android upload key',
    );
    final buildIndex = workflow.indexOf('Build signed Android bundle');
    final finalVerifyIndex = workflow.indexOf(
      'Verify Android signature and certificate',
    );
    final uploadIndex = workflow.indexOf('Upload signed Android package');
    expect(installIndex, greaterThanOrEqualTo(0));
    expect(buildIndex, greaterThan(installIndex));
    expect(finalVerifyIndex, greaterThan(buildIndex));
    expect(uploadIndex, greaterThan(finalVerifyIndex));
  });

  test('iOS verifies the P12 fingerprint and near-term validity', () {
    final workflow = File(
      '.github/workflows/store-release.yml',
    ).readAsStringSync();

    expect(workflow, contains('distribution-cert.pem'));
    expect(workflow, contains('ACTUAL_DISTRIBUTION_CERT_SHA256'));
    expect(workflow, contains('-checkend 604800'));
    expect(
      workflow,
      contains('security list-keychains -d user -s "$KEYCHAIN_PATH"'),
    );

    final verifyIndex = workflow.indexOf(
      'Install and verify Apple signing identity',
    );
    final archiveIndex = workflow.indexOf('Archive signed iOS app');
    final uploadIndex = workflow.indexOf('Upload signed iOS package');
    expect(verifyIndex, greaterThanOrEqualTo(0));
    expect(archiveIndex, greaterThan(verifyIndex));
    expect(uploadIndex, greaterThan(archiveIndex));
  });

  test('temporary certificate files are removed even after failure', () {
    final workflow = File(
      '.github/workflows/store-release.yml',
    ).readAsStringSync();

    expect(workflow, contains('rm -f "$RUNNER_TEMP/android-upload-cert.der"'));
    expect(workflow, contains('rm -f "$RUNNER_TEMP/android-bundle-cert.pem"'));
    expect(workflow, contains('rm -f "$RUNNER_TEMP/distribution-cert.pem"'));
  });
}
