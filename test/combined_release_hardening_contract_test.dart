import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production Android releases keep the hardened dependency graph', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final workflow = File(
      '.github/workflows/store-release.yml',
    ).readAsStringSync();
    final kotlinPolicy = File(
      'tool/src/kotlin_plugin_warnings.dart',
    ).readAsStringSync();

    expect(pubspec, contains('share_plus: ^13.3.0'));
    expect(pubspec, isNot(contains('purchases_flutter')));
    expect(pubspec, isNot(contains('dependency_overrides:')));
    expect(pubspec, isNot(contains('jni: 1.0.0')));

    expect(kotlinPolicy, contains("'flutter_timezone'"));
    expect(kotlinPolicy, isNot(contains("'purchases_flutter',")));
    expect(kotlinPolicy, isNot(contains("'share_plus',")));

    expect(workflow, contains('build/reports/android-store-release.log'));
    expect(workflow, contains('verify_kotlin_plugin_warnings.dart'));
    expect(workflow, contains('Audit signed Android release bundle'));
    expect(workflow, contains('built-in-kotlin-audit.md'));
    expect(workflow, contains('aab-audit.md'));

    final buildIndex = workflow.indexOf('Build signed Android bundle');
    final kotlinIndex = workflow.indexOf('Audit Built-in Kotlin compatibility');
    final signatureIndex = workflow.indexOf('Verify Android signature');
    final bundleAuditIndex = workflow.indexOf(
      'Audit signed Android release bundle',
    );
    final uploadIndex = workflow.indexOf('Upload signed Android package');

    expect(buildIndex, greaterThanOrEqualTo(0));
    expect(kotlinIndex, greaterThan(buildIndex));
    expect(signatureIndex, greaterThan(kotlinIndex));
    expect(bundleAuditIndex, greaterThan(signatureIndex));
    expect(uploadIndex, greaterThan(bundleAuditIndex));
  });
}
