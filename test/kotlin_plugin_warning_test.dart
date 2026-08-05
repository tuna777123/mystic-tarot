import 'package:flutter_test/flutter_test.dart';

import '../tool/src/kotlin_plugin_warning.dart';

void main() {
  test('extracts the current temporary upstream blockers', () {
    final snapshot = KotlinPluginWarningSnapshot.parse('''
WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP): flutter_timezone, purchases_flutter
Future versions of Flutter will fail to build.
''');

    expect(snapshot.warningPresent, isTrue);
    expect(snapshot.plugins, {'flutter_timezone', 'purchases_flutter'});
    expect(
      snapshot.unexpectedPlugins({'flutter_timezone', 'purchases_flutter'}),
      isEmpty,
    );
  });

  test('passes cleanly after every plugin migrates upstream', () {
    final snapshot = KotlinPluginWarningSnapshot.parse(
      'Built build/app/outputs/bundle/release/app-release.aab',
    );

    expect(snapshot.warningPresent, isFalse);
    expect(snapshot.plugins, isEmpty);
    expect(snapshot.unexpectedPlugins(const {}), isEmpty);
  });

  test('detects a newly introduced incompatible plugin', () {
    final snapshot = KotlinPluginWarningSnapshot.parse('''
WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP): flutter_timezone, purchases_flutter, unsafe_plugin
''');

    expect(
      snapshot.unexpectedPlugins({'flutter_timezone', 'purchases_flutter'}),
      {'unsafe_plugin'},
    );
  });

  test('combines repeated warning lines without duplicates', () {
    final snapshot = KotlinPluginWarningSnapshot.parse('''
WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP): flutter_timezone
WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP): flutter_timezone, purchases_flutter
''');

    expect(snapshot.plugins, {'flutter_timezone', 'purchases_flutter'});
  });

  test('fails closed when Flutter changes the warning shape', () {
    expect(
      () => KotlinPluginWarningSnapshot.parse(
        '${KotlinPluginWarningSnapshot.warningPrefix}\nplugin list moved',
      ),
      throwsFormatException,
    );
  });
}
