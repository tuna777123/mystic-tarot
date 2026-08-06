import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mystic_tarot/src/store_screenshot_manifest.dart';
import 'package:mystic_tarot/src/store_showcase.dart';

import 'support/store_screenshot_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadStoreScreenshotFonts);

  test('store screenshot fonts render proportional Latin glyphs', () {
    expect(verifyStoreScreenshotFonts, returnsNormally);
  });

  testWidgets(
    'generates the requested localized store screenshot partition',
    (tester) async {
      final requestedDevice = Platform.environment['STORE_SCREENSHOT_DEVICE'];
      final requestedLocale = Platform.environment['STORE_SCREENSHOT_LOCALE'];
      final devices = _selectedDevices(requestedDevice);
      final locales = _selectedLocales(requestedLocale);
      final output = Directory('build/store_screenshots');
      if (output.existsSync()) output.deleteSync(recursive: true);
      output.createSync(recursive: true);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      var generated = 0;
      for (final device in devices) {
        tester.view.physicalSize = Size(
          device.width.toDouble(),
          device.height.toDouble(),
        );
        tester.view.devicePixelRatio = device.devicePixelRatio;

        for (final locale in locales) {
          for (final scene in StoreScreenshotScene.values) {
            final boundaryKey = GlobalKey();
            await tester.pumpWidget(
              RepaintBoundary(
                key: boundaryKey,
                child: StoreShowcaseApp(locale: locale, scene: scene),
              ),
            );
            await tester.pumpAndSettle();

            expect(tester.takeException(), isNull);
            final boundary =
                boundaryKey.currentContext!.findRenderObject()
                    as RenderRepaintBoundary;
            final capture = await tester.runAsync(() async {
              final image = await boundary.toImage(
                pixelRatio: device.devicePixelRatio,
              );
              try {
                final byteData = await image.toByteData(
                  format: ui.ImageByteFormat.rawRgba,
                );
                if (byteData == null) {
                  throw StateError('Flutter returned no raw screenshot bytes.');
                }
                final rgbaBytes = byteData.buffer.asUint8List(
                  byteData.offsetInBytes,
                  byteData.lengthInBytes,
                );
                _verifyOpaqueRgba(rgbaBytes);
                final rgb = img.Image.fromBytes(
                  width: image.width,
                  height: image.height,
                  bytes: rgbaBytes.buffer,
                  bytesOffset: rgbaBytes.offsetInBytes,
                  numChannels: 4,
                  order: img.ChannelOrder.rgba,
                ).convert(numChannels: 3);
                return (
                  width: image.width,
                  height: image.height,
                  bytes: img.encodePng(rgb),
                );
              } finally {
                image.dispose();
              }
            });
            final verifiedCapture =
                capture ??
                (throw StateError('Flutter screenshot capture did not run.'));
            expect(verifiedCapture.width, device.width);
            expect(verifiedCapture.height, device.height);

            final relativePath = storeScreenshotRelativePath(
              device: device,
              locale: locale,
              scene: scene,
            );
            final file = File('${output.path}/$relativePath');
            file.parent.createSync(recursive: true);
            file.writeAsBytesSync(verifiedCapture.bytes, flush: true);
            generated++;
          }
        }
      }

      expect(
        generated,
        devices.length * locales.length * StoreScreenshotScene.values.length,
      );
    },
    skip: Platform.environment['GENERATE_STORE_SCREENSHOTS'] != '1',
  );
}

void _verifyOpaqueRgba(Uint8List bytes) {
  if (bytes.length % 4 != 0) {
    throw StateError('Rendered screenshot returned malformed RGBA bytes.');
  }
  for (var index = 3; index < bytes.length; index += 4) {
    if (bytes[index] != 255) {
      throw StateError('Rendered screenshot contains transparent pixels.');
    }
  }
}

List<StoreScreenshotDevice> _selectedDevices(String? requested) {
  if (requested == null || requested.isEmpty) return storeScreenshotDevices;
  final matches = storeScreenshotDevices
      .where((device) => device.slug == requested)
      .toList(growable: false);
  if (matches.isEmpty) {
    throw StateError('Unknown store screenshot device: $requested');
  }
  return matches;
}

List<String> _selectedLocales(String? requested) {
  if (requested == null || requested.isEmpty) return storeScreenshotLocales;
  if (!storeScreenshotLocales.contains(requested)) {
    throw StateError('Unknown store screenshot locale: $requested');
  }
  return <String>[requested];
}
