import 'package:flutter_test/flutter_test.dart';

import '../tool/src/kotlin_plugin_warnings.dart';

void main() {
  test('parses the Flutter KGP warning list', () {
    const log = '''
WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP): flutter_timezone, purchases_flutter
Future versions of Flutter will fail to build.
''';

    expect(parseLegacyKgpPlugins(log), <String>{
      'flutter_timezone',
      'purchases_flutter',
    });
  });

  test('returns empty when the warning is absent', () {
    expect(parseLegacyKgpPlugins('Build completed successfully.'), isEmpty);
  });

  test('reviewed classifications are disjoint and cover the warning set', () {
    expect(
      conditionallyCompatibleLegacyKgpPlugins.intersection(
        upstreamBlockedLegacyKgpPlugins,
      ),
      isEmpty,
    );
    expect(<String>{
      ...conditionallyCompatibleLegacyKgpPlugins,
      ...upstreamBlockedLegacyKgpPlugins,
    }, expectedLegacyKgpPlugins);
  });

  test('accepts only the exact reviewed warning set', () {
    final delta = compareLegacyKgpPlugins(<String>{
      'purchases_flutter',
      'flutter_timezone',
    });

    expect(delta.isValid, isTrue);
    expect(delta.missing, isEmpty);
    expect(delta.unexpected, isEmpty);
  });

  test('detects a disappeared warning for explicit policy review', () {
    final delta = compareLegacyKgpPlugins(<String>{'purchases_flutter'});

    expect(delta.isValid, isFalse);
    expect(delta.missing, {'flutter_timezone'});
    expect(delta.unexpected, isEmpty);
  });

  test('blocks share_plus and unknown legacy plugins', () {
    final delta = compareLegacyKgpPlugins(<String>{
      'flutter_timezone',
      'purchases_flutter',
      'share_plus',
      'unexpected_plugin',
    });

    expect(delta.isValid, isFalse);
    expect(delta.missing, isEmpty);
    expect(delta.unexpected, {'share_plus', 'unexpected_plugin'});
  });

  test('report distinguishes conditional and upstream migration risk', () {
    final report = buildKotlinCompatibilityReport(<String>{
      'purchases_flutter',
      'flutter_timezone',
    });

    expect(report, contains('Result: **PASS**'));
    expect(
      report,
      contains('Conditional compatibility warning: `flutter_timezone`'),
    );
    expect(report, contains('Upstream migration pending: `purchases_flutter`'));
    expect(report, contains('Any addition, removal'));
  });
}
