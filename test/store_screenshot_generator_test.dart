import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mystic_tarot/src/store_screenshot_manifest.dart';
import 'package:mystic_tarot/src/store_showcase.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_loadStoreScreenshotFonts);

  test('store screenshot fonts render proportional Latin glyphs', () {
    _expectProportionalFont('Roboto');
    _expectProportionalFont('Arial');
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
                final rgb = img.Image.fromBytes(
                  width: image.width,
                  height: image.height,
                  bytes: byteData.buffer,
                  bytesOffset: byteData.offsetInBytes,
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
            expect(capture, isNotNull);
            expect(capture!.width, device.width);
            expect(capture.height, device.height);

            final relativePath = storeScreenshotRelativePath(
              device: device,
              locale: locale,
              scene: scene,
            );
            final file = File('${output.path}/$relativePath');
            file.parent.createSync(recursive: true);
            file.writeAsBytesSync(capture.bytes, flush: true);
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

Future<void> _loadStoreScreenshotFonts() async {
  final materialFontDirectory = _flutterMaterialFontDirectory();
  final roboto = File('${materialFontDirectory.path}/Roboto-Regular.ttf');
  final materialIcons = File(
    '${materialFontDirectory.path}/MaterialIcons-Regular.otf',
  );

  if (!roboto.existsSync()) {
    throw StateError('Roboto font not found at ${roboto.path}.');
  }
  if (!materialIcons.existsSync()) {
    throw StateError('Material Icons font not found at ${materialIcons.path}.');
  }

  final robotoBytes = await roboto.readAsBytes();
  await _loadFontFamily('Roboto', robotoBytes);
  await _loadFontFamily('Arial', robotoBytes);
  await _loadFontFamily('MaterialIcons', await materialIcons.readAsBytes());
}

Directory _flutterMaterialFontDirectory() {
  final configuredRoot = Platform.environment['FLUTTER_ROOT'];
  if (configuredRoot != null && configuredRoot.trim().isNotEmpty) {
    return Directory('$configuredRoot/bin/cache/artifacts/material_fonts');
  }

  var flutterRoot = File(Platform.resolvedExecutable).parent;
  for (var depth = 0; depth < 4; depth++) {
    flutterRoot = flutterRoot.parent;
  }
  return Directory('${flutterRoot.path}/bin/cache/artifacts/material_fonts');
}

Future<void> _loadFontFamily(String family, Uint8List bytes) async {
  final loader = FontLoader(family)
    ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
  await loader.load();
}

void _expectProportionalFont(String family) {
  double widthOf(String text) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontFamily: family, fontSize: 32),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width;
  }

  final narrow = widthOf('iiiiiiii');
  final wide = widthOf('WWWWWWWW');
  expect(
    wide,
    greaterThan(narrow * 1.5),
    reason: '$family must not fall back to Flutter test Ahem squares.',
  );
  expect(widthOf('ĞİŞÇÖÜ éèñãç'), greaterThan(0));
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
