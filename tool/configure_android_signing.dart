import 'dart:io';

void main() {
  final file = File('android/app/build.gradle.kts');
  if (!file.existsSync()) {
    stderr.writeln('android/app/build.gradle.kts was not generated.');
    exitCode = 1;
    return;
  }

  var source = file.readAsStringSync();
  const imports = '''import java.io.FileInputStream
import java.util.Properties

''';
  if (!source.startsWith('import java.io.FileInputStream')) {
    source = '$imports$source';
  }

  const properties = '''
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
require(keystorePropertiesFile.exists()) {
    "android/key.properties is required for a signed store build."
}
keystoreProperties.load(FileInputStream(keystorePropertiesFile))

''';
  final pluginsEnd = source.indexOf('}\n', source.indexOf('plugins {'));
  if (pluginsEnd < 0) {
    stderr.writeln('Could not locate the generated plugins block.');
    exitCode = 1;
    return;
  }
  if (!source.contains('val keystoreProperties = Properties()')) {
    source = source.replaceRange(
      pluginsEnd + 2,
      pluginsEnd + 2,
      '\n$properties',
    );
  }

  const signingConfig = '''
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

''';
  if (!source.contains('signingConfigs {')) {
    source = source.replaceFirst(
      '    buildTypes {',
      '$signingConfig    buildTypes {',
    );
  }
  source = source.replaceFirst(
    'signingConfig = signingConfigs.getByName("debug")',
    'signingConfig = signingConfigs.getByName("release")',
  );

  if (!source.contains('signingConfigs.getByName("release")')) {
    stderr.writeln('Could not activate the release signing configuration.');
    exitCode = 1;
    return;
  }
  file.writeAsStringSync(source);
}
