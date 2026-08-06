import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:mystic_tarot/src/store_screenshot_manifest.dart';

void main(List<String> arguments) {
  final root = Directory(
    arguments.isEmpty ? 'build/store_screenshots' : arguments.first,
  );
  final sourceCommit = arguments.length > 1 ? arguments[1] : 'local';
  final errors = <String>[];

  if (!root.existsSync()) {
    _fail(<String>['Screenshot directory does not exist: ${root.path}']);
  }

  final releaseVersion = _readReleaseVersion(File('pubspec.yaml'));
  if (sourceCommit != 'local' &&
      !RegExp(r'^[0-9a-f]{40}$').hasMatch(sourceCommit)) {
    errors.add('Source commit must be a full lowercase Git SHA.');
  }

  final expectedPaths = <String>{};
  for (final device in storeScreenshotDevices) {
    for (final locale in storeScreenshotLocales) {
      for (final scene in StoreScreenshotScene.values) {
        final relativePath = storeScreenshotRelativePath(
          device: device,
          locale: locale,
          scene: scene,
        );
        expectedPaths.add(relativePath);
        final file = File('${root.path}/$relativePath');
        if (!file.existsSync()) {
          errors.add('Missing screenshot: $relativePath');
          continue;
        }
        errors.addAll(_validatePng(file, relativePath, device));
      }
    }
  }

  final actualPaths = root
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.toLowerCase().endsWith('.png'))
      .map((file) => _relativePath(root, file))
      .toSet();
  for (final extra in actualPaths.difference(expectedPaths)) {
    errors.add('Unexpected screenshot: $extra');
  }
  if (actualPaths.length != expectedStoreScreenshotCount) {
    errors.add(
      'Expected $expectedStoreScreenshotCount PNG files, found ${actualPaths.length}.',
    );
  }

  if (errors.isNotEmpty) {
    _fail(errors);
  }

  final manifest = <String, Object>{
    'schemaVersion': 1,
    'applicationVersion': releaseVersion,
    'sourceCommit': sourceCommit,
    'screenshotCount': expectedStoreScreenshotCount,
    'pngBitDepth': 8,
    'pngColorType': 2,
    'alphaChannel': false,
    'locales': storeScreenshotLocales,
    'devices': <Map<String, Object>>[
      for (final device in storeScreenshotDevices)
        <String, Object>{
          'slug': device.slug,
          'width': device.width,
          'height': device.height,
          'devicePixelRatio': device.devicePixelRatio,
        },
    ],
    'scenes': <String>[
      for (final scene in StoreScreenshotScene.values) scene.slug,
    ],
  };
  const encoder = JsonEncoder.withIndent('  ');
  File(
    '${root.path}/manifest.json',
  ).writeAsStringSync('${encoder.convert(manifest)}\n');

  stdout.writeln('# Mystic Tarot Store Screenshot Audit');
  stdout.writeln();
  stdout.writeln('- Result: **PASS**');
  stdout.writeln('- Application version: `$releaseVersion`');
  stdout.writeln('- Source commit: `$sourceCommit`');
  stdout.writeln('- Manifest: `manifest.json`');
  stdout.writeln('- Locales: `${storeScreenshotLocales.join(', ')}`');
  stdout.writeln(
    '- Devices: `${storeScreenshotDevices.map((item) => '${item.slug} ${item.width}x${item.height}').join(', ')}`',
  );
  stdout.writeln(
    '- Scenes per locale: `${StoreScreenshotScene.values.length}`',
  );
  stdout.writeln('- Verified PNG files: `$expectedStoreScreenshotCount`');
  stdout.writeln('- PNG encoding: `8-bit RGB, no alpha channel`');
  stdout.writeln('- Missing or unexpected files: `none`');
  stdout.writeln('- Dimension, signature, or color-type failures: `none`');
}

String _readReleaseVersion(File pubspec) {
  if (!pubspec.existsSync()) {
    _fail(<String>['pubspec.yaml does not exist.']);
  }
  final match = RegExp(
    r'^version:\s*(\d+\.\d+\.\d+\+\d+)\s*$',
    multiLine: true,
  ).firstMatch(pubspec.readAsStringSync());
  if (match == null) {
    _fail(<String>['pubspec.yaml must contain version x.y.z+build.']);
  }
  return match.group(1)!;
}

List<String> _validatePng(
  File file,
  String relativePath,
  StoreScreenshotDevice device,
) {
  final bytes = file.readAsBytesSync();
  final errors = <String>[];
  if (bytes.length < 26) {
    return <String>['Invalid or truncated PNG: $relativePath'];
  }

  const signature = <int>[137, 80, 78, 71, 13, 10, 26, 10];
  for (var index = 0; index < signature.length; index++) {
    if (bytes[index] != signature[index]) {
      errors.add('Invalid PNG signature: $relativePath');
      return errors;
    }
  }

  final data = ByteData.sublistView(Uint8List.fromList(bytes));
  final width = data.getUint32(16);
  final height = data.getUint32(20);
  final bitDepth = bytes[24];
  final colorType = bytes[25];
  if (width != device.width || height != device.height) {
    errors.add(
      'Wrong dimensions for $relativePath: ${width}x$height; '
      'expected ${device.width}x${device.height}.',
    );
  }
  if (bitDepth != 8) {
    errors.add(
      'Wrong PNG bit depth for $relativePath: $bitDepth; expected 8.',
    );
  }
  if (colorType != 2) {
    errors.add(
      'PNG must be RGB without an alpha channel for $relativePath: '
      'color type $colorType; expected 2.',
    );
  }
  if (bytes.length < 5000) {
    errors.add('PNG is unexpectedly small and may be blank: $relativePath');
  }
  return errors;
}

String _relativePath(Directory root, File file) {
  final rootPath = root.absolute.path.replaceAll('\\', '/');
  final filePath = file.absolute.path.replaceAll('\\', '/');
  return filePath.substring(rootPath.length + 1);
}

Never _fail(List<String> errors) {
  stderr.writeln('Store screenshot audit failed:');
  for (final error in errors) {
    stderr.writeln('- $error');
  }
  exit(1);
}
