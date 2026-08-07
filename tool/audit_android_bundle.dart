import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'src/android_bundle_audit.dart';

const _defaultPackage = 'com.tunabozcali.mystictarot';
const _defaultMaximumBytes = 80 * 1024 * 1024;

Future<void> main(List<String> arguments) async {
  try {
    final options = _AuditOptions.parse(arguments);
    final report = await _audit(options);
    await options.reportFile.parent.create(recursive: true);
    await options.reportFile.writeAsString(report);
    stdout.write(report);
  } on AuditFailure catch (error) {
    stderr.writeln('Android bundle audit failed: ${error.message}');
    exitCode = 1;
  } on ProcessException catch (error) {
    stderr.writeln('Android bundle audit could not run: $error');
    exitCode = 1;
  }
}

Future<String> _audit(_AuditOptions options) async {
  final bundle = options.bundleFile;
  if (!bundle.existsSync()) {
    throw AuditFailure('Bundle does not exist: ${bundle.path}');
  }
  if (!options.bundletoolFile.existsSync()) {
    throw AuditFailure(
      'Pinned bundletool does not exist: ${options.bundletoolFile.path}',
    );
  }

  final bundleBytes = bundle.lengthSync();
  if (bundleBytes <= 0 || bundleBytes > options.maximumBytes) {
    throw AuditFailure(
      'Bundle size ${formatByteCount(bundleBytes)} exceeds the '
      '${formatByteCount(options.maximumBytes)} release budget.',
    );
  }

  await _runChecked('unzip', ['-tqq', bundle.path]);
  final signatureResult = await Process.run(
    'jarsigner',
    ['-verify', '-strict', '-certs', bundle.path],
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );
  final signatureOutput =
      '${signatureResult.stdout}\n${signatureResult.stderr}';
  validateStrictJarsignerResult(
    exitCode: signatureResult.exitCode,
    output: signatureOutput,
  );

  await _runChecked('java', [
    '-jar',
    options.bundletoolFile.path,
    'validate',
    '--bundle=${bundle.path}',
  ]);

  final manifestResult = await _runChecked('java', [
    '-jar',
    options.bundletoolFile.path,
    'dump',
    'manifest',
    '--bundle=${bundle.path}',
  ]);
  final manifest = ManifestSnapshot.parse(manifestResult.stdout as String);
  final expectedVersion = PubspecVersion.parse(
    File('pubspec.yaml').readAsStringSync(),
  );

  if (manifest.packageName != options.expectedPackage) {
    throw AuditFailure(
      'Expected package ${options.expectedPackage}, found '
      '${manifest.packageName}.',
    );
  }
  if (manifest.versionName != expectedVersion.name ||
      manifest.versionCode != expectedVersion.code) {
    throw AuditFailure(
      'Manifest version ${manifest.versionName}+${manifest.versionCode} '
      'does not match pubspec ${expectedVersion.name}+${expectedVersion.code}.',
    );
  }

  final forbiddenPermissions = findForbiddenPermissions(manifest.permissions);
  if (forbiddenPermissions.isNotEmpty) {
    throw AuditFailure(
      'Forbidden permissions detected: '
      '${_sorted(forbiddenPermissions).join(', ')}',
    );
  }
  final reviewedAdPermissions = findReviewedAdvertisingPermissions(
    manifest.permissions,
  );

  final entryResult = await _runChecked('unzip', ['-Z1', bundle.path]);
  final entries = const LineSplitter()
      .convert(entryResult.stdout as String)
      .where((entry) => entry.isNotEmpty)
      .toList(growable: false);
  for (final requiredEntry in <String>{
    'BundleConfig.pb',
    'base/manifest/AndroidManifest.xml',
    'base/dex/classes.dex',
  }) {
    if (!entries.contains(requiredEntry)) {
      throw AuditFailure('Bundle is missing required entry $requiredEntry.');
    }
  }

  final abis = parseAndroidAbis(entries);
  final missingAbis = requiredAndroidAbis.difference(abis);
  if (missingAbis.isNotEmpty) {
    throw AuditFailure(
      'Bundle is missing required ABIs: ${_sorted(missingAbis).join(', ')}',
    );
  }
  if (abis.contains('x86')) {
    throw const AuditFailure('Legacy 32-bit x86 ABI must not ship.');
  }

  final dexEntries = entries
      .where((entry) => RegExp(r'^base/dex/.*\.dex$').hasMatch(entry))
      .toList(growable: false);
  final forbiddenMarkers = <String>{};
  for (final dexEntry in dexEntries) {
    final dexResult = await _runChecked(
      'unzip',
      ['-p', bundle.path, dexEntry],
      binaryStdout: true,
    );
    final output = dexResult.stdout;
    if (output is! List<int>) {
      throw AuditFailure('Could not inspect binary DEX entry $dexEntry.');
    }
    forbiddenMarkers.addAll(
      findForbiddenDexMarkers(Uint8List.fromList(output)),
    );
  }
  if (forbiddenMarkers.isNotEmpty) {
    throw AuditFailure(
      'Unapproved analytics or attribution SDK classes detected: '
      '${_sorted(forbiddenMarkers).join(', ')}',
    );
  }

  final hashResult = await _runChecked('sha256sum', [bundle.path]);
  final sha256 = (hashResult.stdout as String)
      .trim()
      .split(RegExp(r'\s+'))
      .first;
  final permissions = _sorted(manifest.permissions);
  final sortedReviewedAdPermissions = _sorted(reviewedAdPermissions);
  final sortedAbis = _sorted(abis);

  return '''# Mystic Tarot Android Bundle Audit

- Result: **PASS**
- Package: `${manifest.packageName}`
- Version: `${manifest.versionName}+${manifest.versionCode}`
- Bundle size: `${formatByteCount(bundleBytes)}`
- SHA-256: `$sha256`
- Signature container: `strict jarsigner policy passed`
- Bundle structure: `bundletool validate passed`
- Native ABIs: `${sortedAbis.join(', ')}`
- Declared permissions: `${permissions.isEmpty ? 'none' : permissions.join(', ')}`
- Sensitive permission denylist: `clear`
- Reviewed Google advertising permissions: `${sortedReviewedAdPermissions.isEmpty ? 'none' : sortedReviewedAdPermissions.join(', ')}`
- Unapproved analytics/attribution SDK denylist: `clear`

This automated audit verifies the release artifact itself. Google Mobile Ads is an
intentional reviewed dependency in the advertising-supported native build. The
audit does not replace Play pre-launch testing, AdMob/UMP account configuration,
production signing ownership, store privacy declarations, or real-device
network and consent inspection.
''';
}

Future<ProcessResult> _runChecked(
  String executable,
  List<String> arguments, {
  bool binaryStdout = false,
}) async {
  final result = await Process.run(
    executable,
    arguments,
    stdoutEncoding: binaryStdout ? null : utf8,
    stderrEncoding: utf8,
  );
  if (result.exitCode != 0) {
    final stderrText = result.stderr is String
        ? (result.stderr as String).trim()
        : '<binary stderr>';
    throw AuditFailure(
      '$executable ${arguments.join(' ')} exited with ${result.exitCode}: '
      '$stderrText',
    );
  }
  return result;
}

List<String> _sorted(Iterable<String> values) {
  return values.toList()..sort();
}

class _AuditOptions {
  const _AuditOptions({
    required this.bundleFile,
    required this.bundletoolFile,
    required this.reportFile,
    required this.expectedPackage,
    required this.maximumBytes,
  });

  final File bundleFile;
  final File bundletoolFile;
  final File reportFile;
  final String expectedPackage;
  final int maximumBytes;

  static _AuditOptions parse(List<String> arguments) {
    String? value(String name) {
      final index = arguments.indexOf(name);
      if (index == -1) return null;
      if (index + 1 >= arguments.length) {
        throw AuditFailure('$name requires a value.');
      }
      return arguments[index + 1];
    }

    final bundlePath = value('--bundle');
    final bundletoolPath = value('--bundletool');
    if (bundlePath == null || bundletoolPath == null) {
      throw const AuditFailure(
        'Usage: dart run tool/audit_android_bundle.dart '
        '--bundle <app.aab> --bundletool <bundletool.jar> '
        '[--report <audit.md>] [--package <applicationId>] '
        '[--max-bytes <bytes>]',
      );
    }

    final maximumBytesText = value('--max-bytes');
    final maximumBytes = maximumBytesText == null
        ? _defaultMaximumBytes
        : int.tryParse(maximumBytesText);
    if (maximumBytes == null || maximumBytes <= 0) {
      throw const AuditFailure('--max-bytes must be a positive integer.');
    }

    return _AuditOptions(
      bundleFile: File(bundlePath),
      bundletoolFile: File(bundletoolPath),
      reportFile: File(value('--report') ?? '$bundlePath.audit.md'),
      expectedPackage: value('--package') ?? _defaultPackage,
      maximumBytes: maximumBytes,
    );
  }
}
