import 'dart:io';

const permanentIdentifier = 'com.tunabozcali.mystictarot';

const generatedIdentifiers = <String>[
  'com.tunabozcali.mystic_tarot',
  'com.tunabozcali.mysticTarot',
  'com.example.mystic_tarot',
];

void main() {
  final roots = <Directory>[
    Directory('android'),
    Directory('ios'),
  ].where((directory) => directory.existsSync());

  var changedFiles = 0;
  for (final root in roots) {
    for (final entity in root.listSync(recursive: true, followLinks: false)) {
      if (entity is! File || !_isTextBuildFile(entity.path)) continue;
      final original = entity.readAsStringSync();
      var updated = original;
      for (final generated in generatedIdentifiers) {
        updated = updated.replaceAll(generated, permanentIdentifier);
      }
      if (updated != original) {
        entity.writeAsStringSync(updated);
        changedFiles += 1;
      }
    }
  }

  final errors = <String>[];
  final androidBuild = File('android/app/build.gradle.kts');
  if (androidBuild.existsSync()) {
    final source = androidBuild.readAsStringSync();
    if (!source.contains('namespace = "$permanentIdentifier"')) {
      errors.add('Android namespace was not set to $permanentIdentifier.');
    }
    if (!source.contains('applicationId = "$permanentIdentifier"')) {
      errors.add('Android applicationId was not set to $permanentIdentifier.');
    }
  }

  final iosProject = File('ios/Runner.xcodeproj/project.pbxproj');
  if (iosProject.existsSync() &&
      !iosProject.readAsStringSync().contains(
            'PRODUCT_BUNDLE_IDENTIFIER = $permanentIdentifier;',
          )) {
    errors.add('iOS bundle identifier was not set to $permanentIdentifier.');
  }

  if (errors.isNotEmpty) {
    for (final error in errors) {
      stderr.writeln(error);
    }
    exitCode = 1;
    return;
  }
  stdout.writeln(
    'Permanent store identifiers verified; $changedFiles file(s) updated.',
  );
}

bool _isTextBuildFile(String path) {
  return path.endsWith('.kt') ||
      path.endsWith('.kts') ||
      path.endsWith('project.pbxproj');
}
