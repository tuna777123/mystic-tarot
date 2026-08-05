import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android release logs are audited before artifact upload', () {
    final workflow = File(
      '.github/workflows/flutter-ci.yml',
    ).readAsStringSync();

    expect(workflow, contains('build/reports/android-release.log'));
    expect(workflow, contains('verify_kotlin_plugin_warnings.dart'));
    expect(workflow, contains('mystic-tarot-built-in-kotlin-audit'));

    final buildIndex = workflow.indexOf('Build Android release bundle');
    final kotlinAuditIndex = workflow.indexOf(
      'Audit Built-in Kotlin compatibility',
    );
    final bundleAuditIndex = workflow.indexOf('Audit Android release bundle');
    final uploadIndex = workflow.indexOf('Upload Android bundle');

    expect(buildIndex, greaterThanOrEqualTo(0));
    expect(kotlinAuditIndex, greaterThan(buildIndex));
    expect(bundleAuditIndex, greaterThan(kotlinAuditIndex));
    expect(uploadIndex, greaterThan(bundleAuditIndex));
  });

  test('signed production Android releases enforce the same Kotlin policy', () {
    final workflow = File(
      '.github/workflows/store-release.yml',
    ).readAsStringSync();

    expect(workflow, contains('build/reports/android-store-release.log'));
    expect(workflow, contains('verify_kotlin_plugin_warnings.dart'));
    expect(
      workflow,
      contains('build/release/android/built-in-kotlin-audit.md'),
    );
    expect(
      workflow,
      contains('2>&1 | tee build/reports/android-store-release.log'),
    );

    final buildIndex = workflow.indexOf('Build signed Android bundle');
    final kotlinAuditIndex = workflow.indexOf(
      'Audit Built-in Kotlin compatibility',
    );
    final signatureIndex = workflow.indexOf('Verify Android signature');
    final bundleAuditIndex = workflow.indexOf(
      'Audit signed Android release bundle',
    );
    final uploadIndex = workflow.indexOf('Upload signed Android package');

    expect(buildIndex, greaterThanOrEqualTo(0));
    expect(kotlinAuditIndex, greaterThan(buildIndex));
    expect(signatureIndex, greaterThan(kotlinAuditIndex));
    expect(bundleAuditIndex, greaterThan(signatureIndex));
    expect(uploadIndex, greaterThan(bundleAuditIndex));
  });

  test('policy requires the exact reviewed upstream blocker set', () {
    final policy = File(
      'tool/src/kotlin_plugin_warnings.dart',
    ).readAsStringSync();
    final verifier = File(
      'tool/verify_kotlin_plugin_warnings.dart',
    ).readAsStringSync();

    expect(policy, contains('expectedLegacyKgpPlugins'));
    expect(policy, contains("'flutter_timezone'"));
    expect(policy, contains("'purchases_flutter'"));
    expect(policy, isNot(contains("'share_plus',")));
    expect(policy, contains('expectedLegacyKgpPlugins.difference(observed)'));
    expect(policy, contains('observed.difference(expectedLegacyKgpPlugins)'));
    expect(verifier, contains('if (!delta.isValid)'));
  });
}
