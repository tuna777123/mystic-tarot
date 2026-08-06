import 'dart:io';
import 'dart:typed_data';

import 'package:mystic_tarot/src/store_screenshot_manifest.dart';

void main(List<String> arguments) {
  final root = Directory(
    arguments.isEmpty ? 'build/store_screenshots' : arguments.first,
  );
  final errors = <String>[];

  if (!root.existsSync()) {
    _fail(<String>['Screenshot directory does not exist: ${root.path}']);
    return;
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
    return;
  }

  stdout.writeln('# Mystic Tarot Store Screenshot Audit');
  stdout.writeln();
  stdout.writeln('- Result: **PASS**');
  stdout.writeln('- Locales: `${storeScreenshotLocales.join(', ')}`');
  stdout.writeln(
    '- Devices: `${storeScreenshotDevices.map((item) => '${item.slug} ${item.width}x${item.height}').join(', ')}`',
  );
  stdout.writeln('- Scenes per locale: `${StoreScreenshotScene.values.length}`');
  stdout.writeln('- Verified PNG files: `$expectedStoreScreenshotCount`');
  stdout.writeln('- Missing or unexpected files: `none`');
  stdout.writeln('- Dimension or PNG signature failures: `none`');
}

List<String> _validatePng(
  File file,
  String relativePath,
  StoreScreenshotDevice device,
) {
  final bytes = file.readAsBytesSync();
  final errors = <String>[];
  if (bytes.length < 24) {
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
  if (width != device.width || height != device.height) {
    errors.add(
      'Wrong dimensions for $relativePath: ${width}x$height; '
      'expected ${device.width}x${device.height}.',
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
  exitCode = 1;
  throw const FileSystemException('Store screenshot audit failed.');
}
