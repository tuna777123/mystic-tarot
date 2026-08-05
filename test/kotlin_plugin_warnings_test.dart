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

  test('returns empty when every plugin uses Built-in Kotlin', () {
    expect(parseLegacyKgpPlugins('Build completed successfully.'), isEmpty);
  });

  test('allows only verified upstream blockers', () {
    expect(
      findUnexpectedLegacyKgpPlugins(<String>{
        'flutter_timezone',
        'purchases_flutter',
      }),
      isEmpty,
    );
  });

  test('blocks share_plus and unknown legacy plugins', () {
    expect(
      findUnexpectedLegacyKgpPlugins(<String>{
        'flutter_timezone',
        'share_plus',
        'unexpected_plugin',
      }),
      <String>{'share_plus', 'unexpected_plugin'},
    );
  });

  test('report stays honest when upstream blockers remain', () {
    final report = buildKotlinCompatibilityReport(<String>{
      'purchases_flutter',
      'flutter_timezone',
    });

    expect(report, contains('Result: **PASS**'));
    expect(report, contains('flutter_timezone, purchases_flutter'));
    expect(report, isNot(contains('All packaged Flutter plugins')));
  });
}
