import 'package:flutter_test/flutter_test.dart';

import '../tool/src/kotlin_plugin_warnings.dart';

void main() {
  test('parses the Flutter KGP warning list', () {
    const log = '''
WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP): flutter_timezone
Future versions of Flutter will fail to build.
''';

    expect(parseLegacyKgpPlugins(log), <String>{'flutter_timezone'});
  });

  test('returns empty when the warning is absent', () {
    expect(parseLegacyKgpPlugins('Build completed successfully.'), isEmpty);
  });

  test('the reviewed set contains only the plugin still shipped', () {
    expect(conditionallyCompatibleLegacyKgpPlugins, {'flutter_timezone'});
    expect(expectedLegacyKgpPlugins, {'flutter_timezone'});
  });

  test('accepts only the exact reviewed warning set', () {
    final delta = compareLegacyKgpPlugins(<String>{'flutter_timezone'});

    expect(delta.isValid, isTrue);
    expect(delta.missing, isEmpty);
    expect(delta.unexpected, isEmpty);
  });

  test('detects a disappeared warning for explicit policy review', () {
    final delta = compareLegacyKgpPlugins(<String>{});

    expect(delta.isValid, isFalse);
    expect(delta.missing, {'flutter_timezone'});
    expect(delta.unexpected, isEmpty);
  });

  test('blocks billing and unknown legacy plugins if they reappear', () {
    final delta = compareLegacyKgpPlugins(<String>{
      'flutter_timezone',
      'purchases_flutter',
      'share_plus',
      'unexpected_plugin',
    });

    expect(delta.isValid, isFalse);
    expect(delta.missing, isEmpty);
    expect(delta.unexpected, {
      'purchases_flutter',
      'share_plus',
      'unexpected_plugin',
    });
  });

  test('report records that only the conditional warning remains', () {
    final report = buildKotlinCompatibilityReport(<String>{'flutter_timezone'});

    expect(report, contains('Result: **PASS**'));
    expect(
      report,
      contains('Conditional compatibility warning: `flutter_timezone`'),
    );
    expect(report, contains('purchases_flutter` is intentionally absent'));
  });
}
