import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release candidate uses the canonical native materialization path', () {
    final workflow = File(
      '.github/workflows/release-candidate.yml',
    ).readAsStringSync();

    expect(
      workflow,
      contains('dart run tool/configure_store_identifiers.dart'),
    );
    expect(
      workflow,
      contains('dart run tool/configure_ritual_notifications.dart'),
    );
    expect(workflow, contains('dart run tool/configure_app_lock.dart'));
    expect(workflow, contains('flutter pub get --enforce-lockfile'));
    expect(workflow, contains('flutter analyze --fatal-infos'));
    expect(workflow, contains('bash tool/verify_launch_surface.sh'));
    expect(
      workflow,
      isNot(contains('sed -i')),
      reason:
          'Release Candidate must not maintain a second hand-written native '
          'identity materialization path.',
    );
  });

  test('release candidate validates changes before they reach main', () {
    final workflow = File(
      '.github/workflows/release-candidate.yml',
    ).readAsStringSync();

    expect(workflow, contains('pull_request:'));
    expect(workflow, contains('branches: [main]'));
    for (final path in const <String>[
      'lib/**',
      'test/**',
      'tool/**',
      'assets/**',
      'pubspec.yaml',
      'pubspec.lock',
      '.github/workflows/release-candidate.yml',
      '.github/workflows/store-release.yml',
    ]) {
      expect(
        workflow,
        contains(path),
        reason: 'Release Candidate trigger is missing release input: $path',
      );
    }
  });

  test(
    'only the protected production workflow can produce signed store builds',
    () {
      expect(
        File('.github/workflows/store-android.yml').existsSync(),
        isFalse,
        reason:
            'The obsolete parallel Android signing workflow must stay removed; '
            'signed store candidates belong to store-release.yml only.',
      );

      final productionWorkflow = File(
        '.github/workflows/store-release.yml',
      ).readAsStringSync();
      expect(productionWorkflow, contains('name: Production Store Release'));
      expect(
        RegExp(
          r'^\s*environment:\s*production-stores\s*$',
          multiLine: true,
        ).allMatches(productionWorkflow).length,
        2,
      );
    },
  );

  test('only the canonical Pages workflow can deploy the public site', () {
    expect(
      File('.github/workflows/web-preview.yml').existsSync(),
      isFalse,
      reason:
          'The obsolete Web Preview deployment must stay removed so it cannot '
          'race the verified Pages deployment.',
    );

    final pagesWorkflow = File(
      '.github/workflows/pages.yml',
    ).readAsStringSync();
    expect(pagesWorkflow, contains('name: Deploy GitHub Pages'));
    expect(pagesWorkflow, contains('actions/deploy-pages@v5'));
    expect(pagesWorkflow, contains('Verify live application'));
    expect(pagesWorkflow, contains('context=pages/deployment'));
  });
}
