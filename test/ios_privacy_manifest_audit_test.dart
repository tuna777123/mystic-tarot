import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/ios_privacy_manifest_audit.dart';

void main() {
  test('fails closed when built app has no privacy manifests', () async {
    final root = Directory.systemTemp.createTempSync('mystic-privacy-none-');
    final app = Directory('${root.path}${Platform.pathSeparator}Runner.app')
      ..createSync();
    addTearDown(() => root.deleteSync(recursive: true));

    expect(
      () => verifyIosAppPrivacyManifests(
        appBundle: app,
        commandRunner: _successfulRunner,
      ),
      throwsA(isA<IosPrivacyManifestAuditFailure>()),
    );
  });

  test('inventories nested manifests and lints every file', () async {
    final root = Directory.systemTemp.createTempSync('mystic-privacy-valid-');
    final app = Directory('${root.path}${Platform.pathSeparator}Runner.app')
      ..createSync();
    addTearDown(() => root.deleteSync(recursive: true));

    final first = File(
      '${app.path}${Platform.pathSeparator}Frameworks'
      '${Platform.pathSeparator}GoogleMobileAds.framework'
      '${Platform.pathSeparator}PrivacyInfo.xcprivacy',
    )..createSync(recursive: true);
    first.writeAsStringSync('<plist version="1.0"><dict/></plist>');

    final second = File(
      '${app.path}${Platform.pathSeparator}Frameworks'
      '${Platform.pathSeparator}UserMessagingPlatform.framework'
      '${Platform.pathSeparator}PrivacyInfo.xcprivacy',
    )..createSync(recursive: true);
    second.writeAsStringSync('<plist version="1.0"><dict/></plist>');

    final linted = <String>[];
    final result = await verifyIosAppPrivacyManifests(
      appBundle: app,
      commandRunner: (
        executable,
        arguments, {
        workingDirectory,
      }) async {
        expect(executable, 'plutil');
        expect(arguments.first, '-lint');
        linted.add(arguments.last);
        return ProcessResult(1, 0, 'OK', '');
      },
    );

    expect(result.manifestCount, 2);
    expect(
      result.manifestPaths,
      <String>[
        'Frameworks/GoogleMobileAds.framework/PrivacyInfo.xcprivacy',
        'Frameworks/UserMessagingPlatform.framework/PrivacyInfo.xcprivacy',
      ],
    );
    expect(linted, hasLength(2));
    expect(result.toJson()['privacyManifestCount'], 2);
  });

  test('fails closed when plutil rejects a privacy manifest', () async {
    final root = Directory.systemTemp.createTempSync('mystic-privacy-bad-');
    final app = Directory('${root.path}${Platform.pathSeparator}Runner.app')
      ..createSync();
    addTearDown(() => root.deleteSync(recursive: true));

    File(
      '${app.path}${Platform.pathSeparator}PrivacyInfo.xcprivacy',
    ).writeAsStringSync('not a plist');

    expect(
      () => verifyIosAppPrivacyManifests(
        appBundle: app,
        commandRunner: (
          executable,
          arguments, {
          workingDirectory,
        }) async => ProcessResult(1, 1, '', 'invalid plist'),
      ),
      throwsA(
        isA<IosPrivacyManifestAuditFailure>().having(
          (error) => error.message,
          'message',
          contains('invalid plist'),
        ),
      ),
    );
  });

  test('audits privacy manifests inside the exported IPA payload', () async {
    final root = Directory.systemTemp.createTempSync('mystic-privacy-ipa-');
    addTearDown(() => root.deleteSync(recursive: true));
    final ipa = File('${root.path}${Platform.pathSeparator}Mystic.ipa')
      ..writeAsBytesSync(const <int>[1]);

    final result = await verifyIosArtifactPrivacyManifests(
      ipaFile: ipa,
      commandRunner: (
        executable,
        arguments, {
        workingDirectory,
      }) async {
        if (executable == 'unzip') {
          final outputDirectory = Directory(arguments[arguments.indexOf('-d') + 1]);
          final manifest = File(
            '${outputDirectory.path}${Platform.pathSeparator}Payload'
            '${Platform.pathSeparator}Runner.app'
            '${Platform.pathSeparator}Frameworks'
            '${Platform.pathSeparator}GoogleMobileAds.framework'
            '${Platform.pathSeparator}PrivacyInfo.xcprivacy',
          )..createSync(recursive: true);
          manifest.writeAsStringSync('<plist version="1.0"><dict/></plist>');
          return ProcessResult(1, 0, '', '');
        }
        if (executable == 'plutil') {
          return ProcessResult(1, 0, 'OK', '');
        }
        return ProcessResult(1, 127, '', 'unexpected command');
      },
    );

    expect(result.manifestCount, 1);
    expect(
      result.manifestPaths.single,
      'Frameworks/GoogleMobileAds.framework/PrivacyInfo.xcprivacy',
    );
  });

  test('fails closed for an empty signed IPA', () async {
    final root = Directory.systemTemp.createTempSync('mystic-privacy-empty-ipa-');
    addTearDown(() => root.deleteSync(recursive: true));
    final ipa = File('${root.path}${Platform.pathSeparator}Mystic.ipa')
      ..writeAsBytesSync(const <int>[]);

    expect(
      () => verifyIosArtifactPrivacyManifests(
        ipaFile: ipa,
        commandRunner: _successfulRunner,
      ),
      throwsA(isA<IosPrivacyManifestAuditFailure>()),
    );
  });
}

Future<ProcessResult> _successfulRunner(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) async => ProcessResult(1, 0, 'OK', '');
