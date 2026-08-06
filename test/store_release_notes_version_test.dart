import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const releaseNoteFiles = <String>[
    'docs/STORE_RELEASE_NOTES_EN.md',
    'docs/STORE_LISTING_TR.md',
    'docs/STORE_LISTING_ES.md',
    'docs/STORE_LISTING_FR.md',
    'docs/STORE_LISTING_PT_BR.md',
  ];

  String sourceVersion() {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(
      r'^version:\s*(\d+\.\d+\.\d+)\+\d+\s*$',
      multiLine: true,
    ).firstMatch(pubspec);
    expect(match, isNotNull, reason: 'pubspec.yaml must contain x.y.z+build.');
    return match!.group(1)!;
  }

  test('all five store release notes match the source version', () {
    final expectedVersion = sourceVersion();
    final headingPattern = RegExp(
      r'^## [^\n]*—\s*(\d+\.\d+\.\d+)\s*$',
      multiLine: true,
    );

    for (final path in releaseNoteFiles) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: 'Missing release notes: $path');

      final content = file.readAsStringSync();
      final headings = headingPattern.allMatches(content).toList();
      expect(
        headings,
        hasLength(1),
        reason:
            '$path must contain exactly one versioned release-notes heading.',
      );
      expect(
        headings.single.group(1),
        expectedVersion,
        reason: '$path is stale relative to pubspec.yaml.',
      );
      expect(
        content,
        isNot(contains('1.13.0')),
        reason: '$path still contains the obsolete launch-note version.',
      );
      expect(
        content.toLowerCase(),
        contains('mystic intelligence'),
        reason: '$path must preserve the current private report value.',
      );
    }
  });

  test('current notes cover startup, language, accessibility, and privacy', () {
    final combined = releaseNoteFiles
        .map((path) => File(path).readAsStringSync().toLowerCase())
        .join('\n');

    expect(combined, contains('device language'));
    expect(combined, contains('cihaz dilinde'));
    expect(combined, contains('idioma del dispositivo'));
    expect(combined, contains('langue de l’appareil'));
    expect(combined, contains('idioma do dispositivo'));
    expect(combined, contains('reduce motion'));
    expect(combined, contains('hareketi azalt'));
    expect(combined, contains('transferencia privada cifrada'));
    expect(combined, contains('transfert privé chiffré'));
    expect(combined, contains('transferência privada criptografada'));
  });
}
