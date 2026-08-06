import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

          final overflowingParagraphs = tester
              .renderObjectList<RenderParagraph>(find.byType(RichText))
              .where((paragraph) => paragraph.didExceedMaxLines)
              .toList(growable: false);
          expect(
            overflowingParagraphs,
            isEmpty,
            reason: '${device.slug}/$locale/${scene.slug} must not hide '
                'localized copy behind an ellipsis.',
          );

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

  test('store screenshot copy avoids promotional and ranking claims', () {
    final showcase = File('lib/src/store_showcase.dart').readAsStringSync();
    final normalized = showcase.toLowerCase();

    for (final forbiddenPhrase in const <String>[
      'download now',
      'install now',
      'try now',
      'limited time',
      'discount',
      'sale',
      'best app',
      'top app',
      'million downloads',
    ]) {
      expect(
        normalized,
        isNot(contains(forbiddenPhrase)),
        reason: 'Store screenshot copy must not contain "$forbiddenPhrase".',
      );
    }

    for (final forbiddenPattern in <RegExp>[
      RegExp(r'#\s*1\b'),
      RegExp(r'\$\s*\d'),
      RegExp(r'[€£₺¥]\s*\d'),
      RegExp(r'\d\s*%'),
    ]) {
      expect(
        forbiddenPattern.hasMatch(showcase),
        isFalse,
        reason: 'Store screenshot copy must not contain specific prices, '
            'discount percentages, or ranking claims.',
      );
    }
  });

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
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(workflow, contains('validate-screenshot-source'));
    expect(workflow, contains('generate-store-screenshot-partitions'));
    expect(workflow, contains('audit-and-package-store-screenshots'));
    expect(
      RegExp(r'timeout-minutes:\s+20').allMatches(workflow),
      hasLength(3),
    );
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
    expect(RegExp(r'overwrite:\s+true').allMatches(workflow), hasLength(2));
    expect(workflow, contains('retention-days: 7'));
    expect(workflow, contains('retention-days: 14'));
    expect(workflow, isNot(contains('retention-days: 1\n')));

    expect(pubspec, contains('image: ^4.8.0'));
    expect(generator, contains('RenderRepaintBoundary'));
    expect(generator, contains("package:image/image.dart' as img"));
    expect(generator, contains('ui.ImageByteFormat.rawRgba'));
    expect(generator, contains('_verifyOpaqueRgba(rgbaBytes)'));
    expect(generator, contains('bytes[index] != 255'));
    expect(
      generator,
      contains('Rendered screenshot contains transparent pixels'),
    );
    expect(generator, contains('img.ChannelOrder.rgba'));
    expect(generator, contains('.convert(numChannels: 3)'));
    expect(generator, contains('img.encodePng(rgb)'));
    expect(generator, contains('final verifiedCapture ='));
    expect(
      generator,
      contains('Flutter screenshot capture did not run.'),
    );
    expect(generator, isNot(contains('capture!.width')));
    expect(generator, isNot(contains('capture.height')));
    expect(generator, isNot(contains('capture.bytes')));
    expect(generator, isNot(contains('ui.ImageByteFormat.png')));
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

    expect(verifier, contains("package:image/image.dart' as img"));
    expect(verifier, contains('Invalid PNG signature'));
    expect(verifier, contains('Wrong dimensions'));
    expect(verifier, contains('Wrong PNG bit depth'));
    expect(verifier, contains('PNG must be RGB without an alpha channel'));
    expect(verifier, contains('colorType != 2'));
    expect(verifier, contains('img.decodePng(bytes)'));
    expect(verifier, contains('_validateVisualContent(decoded, relativePath)'));
    expect(verifier, contains('visualSampleGridSize = 32'));
    expect(verifier, contains('minimumDistinctSampledColors = 16'));
    expect(verifier, contains('minimumSampledLuminanceRange = 12.0'));
    expect(verifier, contains('pixel.rNormalized'));
    expect(verifier, contains('pixel.gNormalized'));
    expect(verifier, contains('pixel.bNormalized'));
    expect(
      verifier,
      contains('maximumStoreScreenshotBytes = 8 * 1024 * 1024'),
    );
    expect(verifier, contains('bytes.length > maximumStoreScreenshotBytes'));
    expect(verifier, contains('PNG exceeds the 8 MB store limit'));
    expect(verifier, contains('Unexpected screenshot'));
  });

  test('screenshot artifacts are bound to app version and source commit', () {
    final workflow = File(
      '.github/workflows/store-screenshots.yml',
    ).readAsStringSync();
    final verifier = File(
      'tool/verify_store_screenshot_pack.dart',
    ).readAsStringSync();

    const sourceExpression =
        r'github.event.pull_request.head.sha || github.sha';
    expect(workflow, contains('- pubspec.yaml'));
    expect(workflow, contains(sourceExpression));
    expect(
      RegExp(
        r'ref: \$\{\{ github\.event\.pull_request\.head\.sha \|\| github\.sha \}\}',
      ).allMatches(workflow),
      hasLength(3),
    );
    expect(
      RegExp(r'persist-credentials:\s+false').allMatches(workflow),
      hasLength(3),
    );
    expect(RegExp(r'git rev-parse HEAD').allMatches(workflow), hasLength(3));
    expect(
      workflow,
      contains('test "\$(git rev-parse HEAD)" = "\$SOURCE_COMMIT"'),
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
    expect(verifier, contains("'pngBitDepth': 8"));
    expect(verifier, contains("'pngColorType': 2"));
    expect(verifier, contains("'alphaChannel': false"));
    expect(
      verifier,
      contains("'maximumPngBytes': maximumStoreScreenshotBytes"),
    );
    expect(verifier, contains("'decodedPngValidation': true"));
    expect(
      verifier,
      contains("'visualSampleGridSize': visualSampleGridSize"),
    );
    expect(
      verifier,
      contains(
        "'minimumDistinctSampledColors': minimumDistinctSampledColors",
      ),
    );
    expect(
      verifier,
      contains(
        "'minimumSampledLuminanceRange': minimumSampledLuminanceRange",
      ),
    );
    expect(verifier, contains('manifest.json'));
    expect(verifier, contains(r'^[0-9a-f]{40}$'));
  });
}
