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

    final appleDevice = storeScreenshotDevices.firstWhere(
      (device) => device.slug.startsWith('apple-'),
    );
    expect(appleDevice.slug, 'apple-6.9');
    expect(appleDevice.width, 1290);
    expect(appleDevice.height, 2796);

    final googlePlayDevice = storeScreenshotDevices.firstWhere(
      (device) => device.slug == 'google-play-phone',
    );
    expect(googlePlayDevice.width, 1080);
    expect(googlePlayDevice.height, 1920);
    expect(googlePlayDevice.width / googlePlayDevice.height, 9 / 16);

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

  test('screenshot workflow partitions, audits, and uploads the pack', () {
    final workflow = File(
      '.github/workflows/store-screenshots.yml',
    ).readAsStringSync();
    final generator = File(
      'test/store_screenshot_generator_test.dart',
    ).readAsStringSync();
    final verifier = File(
      'tool/verify_store_screenshot_pack.dart',
    ).readAsStringSync();

    expect(workflow, contains('validate-screenshot-source'));
    expect(workflow, contains('generate-store-screenshot-partitions'));
    expect(workflow, contains('audit-and-package-store-screenshots'));
    expect(workflow, contains('matrix:'));
    expect(workflow, contains('device: apple-6.9'));
    expect(workflow, isNot(contains('device: apple-6.7')));
    expect(workflow, contains("GENERATE_STORE_SCREENSHOTS: '1'"));
    expect(workflow, contains('STORE_SCREENSHOT_DEVICE'));
    expect(workflow, contains('STORE_SCREENSHOT_LOCALE'));
    expect(workflow, contains('actions/download-artifact@v7'));
    expect(workflow, contains('merge-multiple: true'));
    expect(workflow, contains('verify_store_screenshot_pack.dart'));
    expect(workflow, contains('actions/upload-artifact@v7'));
    expect(workflow, contains('if-no-files-found: error'));
    expect(generator, contains('RenderRepaintBoundary'));
    expect(generator, contains('ui.ImageByteFormat.png'));
    expect(generator, contains('Roboto-Regular.ttf'));
    expect(generator, contains('MaterialIcons-Regular.otf'));
    expect(generator, contains("_expectProportionalFont('Roboto')"));
    expect(generator, contains("_expectProportionalFont('Arial')"));
    expect(generator, contains('ĞİŞÇÖÜ éèñãç'));
    expect(
      generator,
      contains('must not fall back to Flutter test Ahem squares'),
    );
    expect(
      generator,
      contains("Platform.environment['STORE_SCREENSHOT_DEVICE']"),
    );
    expect(
      generator,
      contains("Platform.environment['STORE_SCREENSHOT_LOCALE']"),
    );
    expect(verifier, contains('Invalid PNG signature'));
    expect(verifier, contains('Wrong dimensions'));
    expect(verifier, contains('Unexpected screenshot'));
  });

  test('screenshot artifacts are bound to app version and source commit', () {
    final workflow = File(
      '.github/workflows/store-screenshots.yml',
    ).readAsStringSync();
    final verifier = File(
      'tool/verify_store_screenshot_pack.dart',
    ).readAsStringSync();

    expect(workflow, contains('- pubspec.yaml'));
    expect(
      workflow,
      contains(r'github.event.pull_request.head.sha || github.sha'),
    );
    expect(workflow, contains('expected_version='));
    expect(workflow, contains('build/store_screenshots/manifest.json'));
    expect(workflow, contains('applicationVersion'));
    expect(workflow, contains('sourceCommit'));

    expect(verifier, contains("File('pubspec.yaml')"));
    expect(verifier, contains("'schemaVersion': 1"));
    expect(verifier, contains("'applicationVersion': releaseVersion"));
    expect(verifier, contains("'sourceCommit': sourceCommit"));
    expect(
      verifier,
      contains("'screenshotCount': expectedStoreScreenshotCount"),
    );
    expect(verifier, contains('manifest.json'));
    expect(verifier, contains(r'^[0-9a-f]{40}$'));
  });
}
