import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/store_screenshot_manifest.dart';
import 'package:mystic_tarot/src/store_showcase.dart';

void main() {
  test('store screenshot manifest is complete and collision-free', () {
    expect(storeScreenshotLocales, hasLength(5));
    expect(storeScreenshotDevices, hasLength(2));
    expect(StoreScreenshotScene.values, hasLength(5));
    expect(expectedStoreScreenshotCount, 50);

    final paths = <String>{};
    for (final device in storeScreenshotDevices) {
      expect(device.width, greaterThanOrEqualTo(1080));
      expect(device.height, greaterThanOrEqualTo(1920));
      for (final locale in storeScreenshotLocales) {
        for (final scene in StoreScreenshotScene.values) {
          paths.add(
            storeScreenshotRelativePath(
              device: device,
              locale: locale,
              scene: scene,
            ),
          );
        }
      }
    }
    expect(paths, hasLength(expectedStoreScreenshotCount));
  });

  for (final device in storeScreenshotDevices) {
    for (final locale in storeScreenshotLocales) {
      testWidgets('${device.slug} $locale scenes fit without exceptions', (
        tester,
      ) async {
        tester.view.physicalSize = Size(
          device.width.toDouble(),
          device.height.toDouble(),
        );
        tester.view.devicePixelRatio = device.devicePixelRatio;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        for (final scene in StoreScreenshotScene.values) {
          await tester.pumpWidget(
            StoreShowcaseApp(locale: locale, scene: scene),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '${device.slug}/$locale/${scene.slug} must render cleanly.',
          );
          expect(find.text('MYSTIC TAROT'), findsOneWidget);

          if (locale != 'en') {
            for (final englishOnlyLabel in const <String>[
              'The Star',
              'Strength',
              'The Moon',
              'Clarity',
              'Reflective',
              'MOOD',
              'PAST',
              'NEXT',
              'New view',
              'Renewal',
              '24 HOURS LATER',
              'Your reflection becomes evidence for future readings and stays private on this device.',
              'READINGS',
              'MIRRORS',
              'DAY STREAK',
            ]) {
              expect(
                find.text(englishOnlyLabel),
                findsNothing,
                reason: '$locale/${scene.slug} must not leak English labels.',
              );
            }
          }
        }
      });
    }
  }

  test('screenshot workflow generates, audits, and uploads the pack', () {
    final workflow = File(
      '.github/workflows/store-screenshots.yml',
    ).readAsStringSync();
    final generator = File(
      'test/store_screenshot_generator_test.dart',
    ).readAsStringSync();
    final verifier = File(
      'tool/verify_store_screenshot_pack.dart',
    ).readAsStringSync();

    expect(workflow, contains("GENERATE_STORE_SCREENSHOTS: '1'"));
    expect(workflow, contains('verify_store_screenshot_pack.dart'));
    expect(workflow, contains('actions/upload-artifact@v7'));
    expect(workflow, contains('if-no-files-found: error'));
    expect(generator, contains('RenderRepaintBoundary'));
    expect(generator, contains('ui.ImageByteFormat.png'));
    expect(verifier, contains('Invalid PNG signature'));
    expect(verifier, contains('Wrong dimensions'));
    expect(verifier, contains('Unexpected screenshot'));
  });
}
