import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Flutter CI audits the exact AAB before artifact upload', () {
    final workflow = File(
      '.github/workflows/flutter-ci.yml',
    ).readAsStringSync();

    expect(workflow, contains("BUNDLETOOL_VERSION: '1.18.3'"));
    expect(
      workflow,
      contains(
        'a099cfa1543f55593bc2ed16a70a7c67fe54b1747bb7301f37fdfd6d91028e29',
      ),
    );
    expect(workflow, contains('sha256sum --check --strict'));
    expect(workflow, contains('tool/audit_android_bundle.dart'));
    expect(
      workflow,
      contains('build/app/outputs/bundle/release/app-release.aab'),
    );
    expect(workflow, contains('mystic-tarot-android-audit'));

    final buildIndex = workflow.indexOf('Build Android release bundle');
    final auditIndex = workflow.indexOf('Audit Android release bundle');
    final uploadIndex = workflow.indexOf('Upload Android bundle');
    expect(buildIndex, greaterThanOrEqualTo(0));
    expect(auditIndex, greaterThan(buildIndex));
    expect(uploadIndex, greaterThan(auditIndex));
  });

  test('production workflow audits the signed AAB before publication', () {
    final workflow = File(
      '.github/workflows/store-release.yml',
    ).readAsStringSync();

    expect(workflow, contains('Require main release source'));
    expect(workflow, contains('refs/heads/main'));
    expect(workflow, contains("BUNDLETOOL_VERSION: '1.18.3'"));
    expect(
      workflow,
      contains(
        'a099cfa1543f55593bc2ed16a70a7c67fe54b1747bb7301f37fdfd6d91028e29',
      ),
    );
    expect(workflow, contains('sha256sum --check --strict'));
    expect(workflow, contains('Audit signed Android release bundle'));
    expect(workflow, contains('tool/audit_android_bundle.dart'));
    expect(workflow, contains('build/release/android/aab-audit.md'));

    final buildIndex = workflow.indexOf('Build signed Android bundle');
    final signatureIndex = workflow.indexOf('Verify Android signature');
    final auditIndex = workflow.indexOf('Audit signed Android release bundle');
    final metadataIndex = workflow.indexOf('Create Android release manifest');
    final uploadIndex = workflow.indexOf('Upload signed Android package');
    expect(buildIndex, greaterThanOrEqualTo(0));
    expect(signatureIndex, greaterThan(buildIndex));
    expect(auditIndex, greaterThan(signatureIndex));
    expect(metadataIndex, greaterThan(auditIndex));
    expect(uploadIndex, greaterThan(metadataIndex));
  });

  test('bundle audit tool and policy stay in the release tree', () {
    final tool = File('tool/audit_android_bundle.dart');
    final policy = File('tool/src/android_bundle_audit.dart');

    expect(tool.existsSync(), isTrue);
    expect(policy.existsSync(), isTrue);
    expect(tool.readAsStringSync(), contains('bundletool'));
    expect(tool.readAsStringSync(), contains('jarsigner'));
    expect(tool.readAsStringSync(), contains('sha256sum'));
    expect(policy.readAsStringSync(), contains('AD_ID'));
    expect(policy.readAsStringSync(), contains('Lcom/appsflyer/'));
  });
}
