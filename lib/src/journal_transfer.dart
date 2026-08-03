import 'dart:convert';

import 'models.dart';
import 'reading_journal_store.dart';

class JournalTransferResult {
  const JournalTransferResult({
    required this.records,
    required this.rejectedItems,
  });

  final List<ReadingRecord> records;
  final int rejectedItems;
}

class JournalTransferCodec {
  const JournalTransferCodec._();

  static const schemaVersion = 1;
  static const marker = 'MYSTIC-TAROT-JOURNAL-V1';

  static String encode(Iterable<ReadingRecord> records) {
    final journal = ReadingJournalCodec.encode(records);
    final envelope = jsonEncode(<String, Object>{
      'schemaVersion': schemaVersion,
      'product': 'Mystic Tarot',
      'kind': 'private-journal-transfer',
      'journal': journal,
    });
    return '$marker\n${base64Url.encode(utf8.encode(envelope))}';
  }

  static JournalTransferResult decode(String value) {
    final trimmed = value.trim();
    final lines = trimmed.split(RegExp(r'\s+'));
    if (lines.length != 2 || lines.first != marker) {
      throw const FormatException('Not a Mystic Tarot journal transfer code.');
    }
    final envelopeText = utf8.decode(base64Url.decode(base64Url.normalize(lines[1])));
    final envelope = jsonDecode(envelopeText);
    if (envelope is! Map<String, dynamic> ||
        envelope['schemaVersion'] != schemaVersion ||
        envelope['product'] != 'Mystic Tarot' ||
        envelope['kind'] != 'private-journal-transfer' ||
        envelope['journal'] is! String) {
      throw const FormatException('Unsupported journal transfer envelope.');
    }
    final report = ReadingJournalCodec.decode(envelope['journal'] as String);
    if (report.records.isEmpty && report.rejectedItems > 0) {
      throw const FormatException('Journal transfer contains no valid readings.');
    }
    return JournalTransferResult(
      records: report.records,
      rejectedItems: report.rejectedItems,
    );
  }
}
