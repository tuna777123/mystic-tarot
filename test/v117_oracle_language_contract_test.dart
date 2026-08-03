import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final app = File('lib/src/app.dart').readAsStringSync();
  final language = File('lib/src/oracle_language.dart').readAsStringSync();
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final notes = File('RELEASE_NOTES.md').readAsStringSync();

  test('v1.17 uses the multilingual Oracle intent engine', () {
    final version = RegExp(
      r'version: 1\.(\d+)\.0\+(\d+)',
    ).firstMatch(pubspec);
    expect(version, isNotNull);
    expect(int.parse(version!.group(1)!), greaterThanOrEqualTo(17));
    expect(int.parse(version.group(2)!), greaterThanOrEqualTo(23));
    expect(app, contains("import 'oracle_language.dart';"));
    expect(app, contains('detectOracleQuestionIntent(question, widget.language)'));
    expect(language, contains('MysticLanguage.french'));
    expect(language, contains('OracleQuestionIntent.keyCard'));
  });

  test('French Oracle answers and memory never fall through to English', () {
    expect(app, contains('case MysticLanguage.french:'));
    expect(app, contains('cartes proposent une perspective, pas un ordre'));
    expect(app, contains(r'Dans les ${recent.length} tirages mémorisés'));
    expect(app, contains('Ce n’est pas une prédiction'));
  });

  test('release notes retain grounded v1.17 language integrity', () {
    const heading = '# Mystic Tarot 1.17.0 — Oracle Language Integrity';
    final start = notes.indexOf(heading);
    expect(start, isNonNegative);
    final remaining = notes.substring(start);
    final boundary = remaining.indexOf('\n---\n');
    final release = boundary < 0 ? remaining : remaining.substring(0, boundary);
    expect(release, startsWith(heading));
    expect(release, contains('French Oracle responses'));
    expect(release, contains('accent-tolerant'));
    expect(release, contains('perspective, not certainty or commands'));
    expect(release, isNot(contains('remote AI')));
  });

  test('temporary v1.17 integration files are absent from release tree', () {
    expect(File('tool/apply_v117.py').existsSync(), isFalse);
    expect(File('.github/workflows/apply-v117.yml').existsSync(), isFalse);
    expect(File('tool/repair_v117.py').existsSync(), isFalse);
    expect(File('.github/workflows/repair-v117.yml').existsSync(), isFalse);
  });
}
