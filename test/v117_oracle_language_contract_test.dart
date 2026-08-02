import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final app = File('lib/src/app.dart').readAsStringSync();
  final language = File('lib/src/oracle_language.dart').readAsStringSync();
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final notes = File('RELEASE_NOTES.md').readAsStringSync();

  test('v1.17 uses the multilingual Oracle intent engine', () {
    expect(pubspec, contains('version: 1.17.0+23'));
    expect(app, contains("import 'oracle_language.dart';"));
    expect(app, contains('detectOracleQuestionIntent(question, widget.language)'));
    expect(language, contains('MysticLanguage.french'));
    expect(language, contains('OracleQuestionIntent.keyCard'));
  });

  test('French Oracle answers and memory never fall through to English', () {
    expect(app, contains('case MysticLanguage.french:'));
    expect(app, contains('les cartes proposent une perspective'));
    expect(app, contains('Dans les \$\{recent.length\} tirages mémorisés'));
    expect(app, contains('Ce n’est pas une prédiction'));
  });

  test('release notes describe language integrity without AI claims', () {
    expect(notes, startsWith('# Mystic Tarot 1.17.0 — Oracle Language Integrity'));
    expect(notes, contains('French Oracle responses'));
    expect(notes, contains('accent-tolerant'));
    expect(notes, isNot(contains('remote AI')));
  });

  test('temporary v1.17 integration files are absent from release tree', () {
    expect(File('tool/apply_v117.py').existsSync(), isFalse);
    expect(File('.github/workflows/apply-v117.yml').existsSync(), isFalse);
  });
}
