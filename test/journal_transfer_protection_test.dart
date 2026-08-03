import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/journal_transfer_protection.dart';

void main() {
  test('protected transfer hides clear text and unlocks with passphrase',
      () async {
    const clearText = 'MYSTIC-TAROT-JOURNAL-V1\nprivate-journal-payload';
    const passphrase = 'violet moon 27';

    final protected = await JournalTransferProtection.protect(
      clearText: clearText,
      passphrase: passphrase,
    );

    expect(protected, startsWith('${JournalTransferProtection.marker}\n'));
    expect(protected, isNot(contains('private-journal-payload')));
    expect(
      await JournalTransferProtection.unlock(
        protectedCode: protected,
        passphrase: passphrase,
      ),
      clearText,
    );
  });

  test('missing and incorrect passphrases fail without returning content',
      () async {
    final protected = await JournalTransferProtection.protect(
      clearText: 'MYSTIC-TAROT-JOURNAL-V1\nsecret',
      passphrase: 'correct horse',
    );

    await expectLater(
      JournalTransferProtection.unlock(
        protectedCode: protected,
        passphrase: '',
      ),
      throwsA(isA<JournalTransferProtectionRequired>()),
    );
    await expectLater(
      JournalTransferProtection.unlock(
        protectedCode: protected,
        passphrase: 'wrong passphrase',
      ),
      throwsA(isA<JournalTransferUnlockFailed>()),
    );
  });

  test('short passphrases are rejected before code creation', () async {
    await expectLater(
      JournalTransferProtection.protect(
        clearText: 'content',
        passphrase: 'short',
      ),
      throwsArgumentError,
    );
  });
}
