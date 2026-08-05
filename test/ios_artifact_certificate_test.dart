import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/ios_artifact_certificate.dart';

void main() {
  const reviewedFingerprint =
      '0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF';

  test('matches the leaf certificate extracted from the final IPA', () async {
    final fixture = Directory.systemTemp.createTempSync('ios-cert-test-');
    addTearDown(() => fixture.deleteSync(recursive: true));
    final ipa = File('${fixture.path}/Mystic.ipa')..writeAsBytesSync([1]);
    final commands = <String>[];

    Future<ProcessResult> runner(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
    }) async {
      commands.add('$executable ${arguments.join(' ')}');
      if (executable == 'unzip') {
        final destination = arguments.last;
        Directory(
          '$destination/Payload/Runner.app',
        ).createSync(recursive: true);
      } else if (executable == 'codesign') {
        File('$workingDirectory/codesign0').writeAsBytesSync([1, 2, 3]);
      } else if (executable == 'shasum') {
        return ProcessResult(
          1,
          0,
          '${reviewedFingerprint.toLowerCase()}  codesign0\n',
          '',
        );
      }
      return ProcessResult(1, 0, '', '');
    }

    final actual = await verifyIosArtifactSigningCertificate(
      ipaFile: ipa,
      expectedFingerprint: reviewedFingerprint,
      commandRunner: runner,
    );

    expect(actual, reviewedFingerprint);
    expect(commands.first, startsWith('unzip -q'));
    expect(
      commands,
      contains(
        predicate<String>(
          (command) =>
              command.contains('codesign --display --extract-certificates'),
        ),
      ),
    );
    expect(commands.last, startsWith('shasum -a 256'));
  });

  test('rejects a different certificate in the final app', () async {
    final fixture = Directory.systemTemp.createTempSync('ios-cert-test-');
    addTearDown(() => fixture.deleteSync(recursive: true));
    final ipa = File('${fixture.path}/Mystic.ipa')..writeAsBytesSync([1]);
    const differentFingerprint =
        'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF';

    Future<ProcessResult> runner(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
    }) async {
      if (executable == 'unzip') {
        Directory(
          '${arguments.last}/Payload/Runner.app',
        ).createSync(recursive: true);
      } else if (executable == 'codesign') {
        File('$workingDirectory/codesign0').writeAsBytesSync([1]);
      } else if (executable == 'shasum') {
        return ProcessResult(1, 0, '$differentFingerprint  codesign0\n', '');
      }
      return ProcessResult(1, 0, '', '');
    }

    await expectLater(
      verifyIosArtifactSigningCertificate(
        ipaFile: ipa,
        expectedFingerprint: reviewedFingerprint,
        commandRunner: runner,
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('does not match'),
        ),
      ),
    );
  });

  test('release manifest records the verified iOS certificate', () {
    final source = File('tool/write_release_manifest.dart').readAsStringSync();

    expect(source, contains('verifyIosArtifactSigningCertificate'));
    expect(source, contains('IOS_DISTRIBUTION_CERT_SHA256'));
    expect(source, contains("'signingCertificateSha256'"));
  });
}
