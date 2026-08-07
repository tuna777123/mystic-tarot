import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/journal_transfer.dart';
import 'package:mystic_tarot/src/journal_transfer_protection.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/private_journal_transfer.dart';
import 'package:mystic_tarot/src/tarot_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

ReadingRecord _record() => ReadingRecord(
  kind: ReadingKind.daily,
  question: 'What deserves protection?',
  cards: <DrawnCard>[DrawnCard(tarotDeck.first, false)],
  createdAt: DateTime.utc(2026, 8, 4, 10),
  emotion: EmotionalState.curious,
  alignedAction: 'Protect the next step.',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'service creates protected V2 codes and requires the passphrase',
    () async {
      final service = PrivateJournalTransferService(
        preferences: await SharedPreferences.getInstance(),
      );
      final code = await service.createCode(<ReadingRecord>[
        _record(),
      ], passphrase: 'violet moon 27');

      expect(code, startsWith('${JournalTransferProtection.marker}\n'));
      await expectLater(
        service.preview(code: code, currentRecords: const <ReadingRecord>[]),
        throwsA(isA<JournalTransferProtectionRequired>()),
      );

      final preview = await service.preview(
        code: code,
        currentRecords: const <ReadingRecord>[],
        passphrase: 'violet moon 27',
      );
      expect(preview.wasProtected, isTrue);
      expect(preview.addedReadings, 1);
      expect(
        preview.mergedRecords.single.question,
        'What deserves protection?',
      );
    },
  );

  test('legacy V1 codes remain restorable without a passphrase', () async {
    final service = PrivateJournalTransferService(
      preferences: await SharedPreferences.getInstance(),
    );
    final code = JournalTransferCodec.encode(
      records: <ReadingRecord>[_record()],
    );

    final preview = await service.preview(
      code: code,
      currentRecords: const <ReadingRecord>[],
    );

    expect(preview.wasProtected, isFalse);
    expect(preview.addedReadings, 1);
  });
}
