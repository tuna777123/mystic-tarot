import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/store_screenshot_manifest.dart';
import 'package:mystic_tarot/src/store_showcase.dart';

void main() {
  testWidgets(
    'generates the complete localized store screenshot pack',
    (tester) async {
      final output = Directory('build/store_screenshots');
      if (output.existsSync()) output.deleteSync(recursive: true);
      output.createSync(recursive: true);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      var generated = 0;
      for (final device in storeScreenshotDevices) {
        tester.view.physicalSize = Size(
          device.width.toDouble(),
          device.height.toDouble(),
        );
        tester.view.devicePixelRatio = device.devicePixelRatio;

        for (final locale in storeScreenshotLocales) {
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
            final image = await boundary.toImage(
              pixelRatio: device.devicePixelRatio,
            );
            expect(image.width, device.width);
            expect(image.height, device.height);

            final byteData = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            expect(byteData, isNotNull);
            final relativePath = storeScreenshotRelativePath(
              device: device,
              locale: locale,
              scene: scene,
            );
            final file = File('${output.path}/$relativePath');
            file.parent.createSync(recursive: true);
            file.writeAsBytesSync(byteData!.buffer.asUint8List(), flush: true);
            image.dispose();
            generated++;
          }
        }
      }

      expect(generated, expectedStoreScreenshotCount);
    },
    skip: Platform.environment['GENERATE_STORE_SCREENSHOTS'] != '1',
  );
}
