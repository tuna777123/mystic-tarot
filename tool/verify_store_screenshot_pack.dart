import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:mystic_tarot/src/store_screenshot_manifest.dart';

const maximumStoreScreenshotBytes = 8 * 1024 * 1024;
const visualSampleGridSize = 32;
const minimumDistinctSampledColors = 16;
const minimumSampledLuminanceRange = 12.0;

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
    'maximumPngBytes': maximumStoreScreenshotBytes,
    'decodedPngValidation': true,
    'visualSampleGridSize': visualSampleGridSize,
    'minimumDistinctSampledColors': minimumDistinctSampledColors,
    'minimumSampledLuminanceRange': minimumSampledLuminanceRange,
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
  stdout.writeln('- Maximum PNG size: `$maximumStoreScreenshotBytes bytes`');
  stdout.writeln('- Decoded PNG validation: `enabled`');
  stdout.writeln(
    '- Visual sampling: `${visualSampleGridSize}x$visualSampleGridSize grid`',
  );
  stdout.writeln('- Missing or unexpected files: `none`');
  stdout.writeln(
    '- Dimension, signature, decode, color-type, visual-content, or file-size failures: `none`',
  );
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

  final data = ByteData.sublistView(bytes);
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
  if (bytes.length > maximumStoreScreenshotBytes) {
    errors.add(
      'PNG exceeds the 8 MB store limit for $relativePath: '
      '${bytes.length} bytes.',
    );
  }

  img.Image? decoded;
  try {
    decoded = img.decodePng(bytes);
  } on Object catch (error) {
    errors.add('PNG decode failed for $relativePath: $error');
  }
  if (decoded == null) {
    errors.add('PNG decoder returned no image for $relativePath.');
    return errors;
  }
  if (decoded.width != device.width || decoded.height != device.height) {
    errors.add(
      'Decoded dimensions for $relativePath are '
      '${decoded.width}x${decoded.height}; expected '
      '${device.width}x${device.height}.',
    );
  }
  errors.addAll(_validateVisualContent(decoded, relativePath));
  return errors;
}

List<String> _validateVisualContent(img.Image image, String relativePath) {
  final colors = <int>{};
  var minimumLuminance = 255.0;
  var maximumLuminance = 0.0;

  for (var row = 0; row < visualSampleGridSize; row++) {
    final y = ((image.height - 1) * row / (visualSampleGridSize - 1)).round();
    for (var column = 0; column < visualSampleGridSize; column++) {
      final x =
          ((image.width - 1) * column / (visualSampleGridSize - 1)).round();
      final pixel = image.getPixel(x, y);
      final red = (pixel.rNormalized * 255).round();
      final green = (pixel.gNormalized * 255).round();
      final blue = (pixel.bNormalized * 255).round();
      colors.add((red << 16) | (green << 8) | blue);
      final luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue;
      if (luminance < minimumLuminance) minimumLuminance = luminance;
      if (luminance > maximumLuminance) maximumLuminance = luminance;
    }
  }

  final errors = <String>[];
  if (colors.length < minimumDistinctSampledColors) {
    errors.add(
      'PNG has too little sampled color variation for $relativePath: '
      '${colors.length} distinct colors; expected at least '
      '$minimumDistinctSampledColors.',
    );
  }
  final luminanceRange = maximumLuminance - minimumLuminance;
  if (luminanceRange < minimumSampledLuminanceRange) {
    errors.add(
      'PNG has too little sampled luminance variation for $relativePath: '
      '${luminanceRange.toStringAsFixed(2)}; expected at least '
      '$minimumSampledLuminanceRange.',
    );
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
