import 'package:flutter_test/flutter_test.dart';

import '../tool/src/kotlin_plugin_audit.dart';

void main() {
  test('extracts legacy Kotlin plugin names from Flutter build output', () {
    final detected = parseLegacyKotlinPluginWarnings('''
WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP): flutter_timezone, purchases_flutter
Future versions of Flutter will fail to build.
''');

    expect(detected, {'flutter_timezone', 'purchases_flutter'});
  });

  test('passes when detected blockers are a subset of the reviewed allowlist', () {
    final result = auditLegacyKotlinPlugins(
      buildLog: '''
WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP): purchases_flutter
''',
      allowedBlockers: {'flutter_timezone', 'purchases_flutter'},
    );

    expect(result.detectedBlockers, {'purchases_flutter'});
    expect(result.resolvedBlockers, {'flutter_timezone'});
  });

  test('passes when every plugin has migrated to built-in Kotlin', () {
    final result = auditLegacyKotlinPlugins(
      buildLog: 'Android App Bundle built successfully.',
      allowedBlockers: {'flutter_timezone', 'purchases_flutter'},
    );

    expect(result.detectedBlockers, isEmpty);
    expect(result.resolvedBlockers, {
      'flutter_timezone',
      'purchases_flutter',
    });
  });

  test('fails when an unreviewed plugin applies the legacy Kotlin plugin', () {
    expect(
      () => auditLegacyKotlinPlugins(
        buildLog: '''
WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP): flutter_timezone, share_plus
''',
        allowedBlockers: {'flutter_timezone', 'purchases_flutter'},
      ),
      throwsA(
        isA<KotlinPluginAuditFailure>().having(
          (error) => error.message,
          'message',
          contains('share_plus'),
        ),
      ),
    );
  });

  test('formats a stable audit report', () {
    final report = const KotlinPluginAuditResult(
      detectedBlockers: {'purchases_flutter'},
      resolvedBlockers: {'flutter_timezone'},
    ).formatReport();

    expect(report, contains('Result: **PASS**'));
    expect(report, contains('purchases_flutter'));
    expect(report, contains('flutter_timezone'));
  });
}
