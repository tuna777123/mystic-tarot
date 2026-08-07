import 'package:shared_preferences/shared_preferences.dart';

import 'journal_transfer.dart';
import 'journal_transfer_protection.dart';
import 'models.dart';
import 'mystic_mirror.dart';
import 'oracle_conversation.dart';
import 'reading_journal_store.dart';

class PrivateJournalTransferPreview {
  const PrivateJournalTransferPreview({
    required this.mergedRecords,
    required this.mergedReflections,
    required this.mergedOracleTurns,
    required this.importedReadings,
    required this.importedReflections,
    required this.importedOracleTurns,
    required this.addedReadings,
    required this.changedReflections,
    required this.addedOracleTurns,
    required this.rejectedItems,
    this.wasProtected = false,
  });

  final List<ReadingRecord> mergedRecords;
  final Map<String, MysticMirrorReflection> mergedReflections;
  final List<OracleConversationTurn> mergedOracleTurns;
  final int importedReadings;
  final int importedReflections;
  final int importedOracleTurns;
  final int addedReadings;
  final int changedReflections;
  final int addedOracleTurns;
  final int rejectedItems;
  final bool wasProtected;

  int get totalChanges => addedReadings + changedReflections + addedOracleTurns;
}

class PrivateJournalTransferService {
  PrivateJournalTransferService({SharedPreferences? preferences})
    : _providedPreferences = preferences,
      _mirrorStore = MysticMirrorStore(preferences: preferences),
      _oracleStore = OracleConversationStore(preferences: preferences);

  final SharedPreferences? _providedPreferences;
  final MysticMirrorStore _mirrorStore;
  final OracleConversationStore _oracleStore;

  Future<SharedPreferences> _preferences() async =>
      _providedPreferences ?? SharedPreferences.getInstance();

  Future<String> createCode(
    Iterable<ReadingRecord> records, {
    String? passphrase,
  }) async {
    final orderedRecords = _orderedRecords(records);
    if (orderedRecords.isEmpty) {
      throw StateError('A private transfer needs at least one saved reading.');
    }
    final recordIds = orderedRecords.map(readingJournalRecordId).toSet();
    final reflections = (await _mirrorStore.load()).values.where(
      (item) => recordIds.contains(item.recordId),
    );
    final oracleTurns = (await _oracleStore.loadAll()).where(
      (item) => recordIds.contains(item.recordId),
    );
    final clearCode = JournalTransferCodec.encode(
      records: orderedRecords,
      reflections: reflections,
      oracleTurns: oracleTurns,
    );
    if (passphrase == null || passphrase.isEmpty) return clearCode;
    return JournalTransferProtection.protect(
      clearText: clearCode,
      passphrase: passphrase,
    );
  }

  Future<PrivateJournalTransferPreview> preview({
    required String code,
    required Iterable<ReadingRecord> currentRecords,
    String? passphrase,
  }) async {
    final wasProtected = JournalTransferProtection.isProtectedCode(code);
    final imported = await _decode(code, passphrase: passphrase);
    final current = _orderedRecords(currentRecords);
    final currentReflections = await _mirrorStore.load();
    final currentOracle = await _oracleStore.loadAll();

    final records = _mergeRecords(current, imported.records);
    final validRecordIds = records.map(readingJournalRecordId).toSet();
    final reflections = <String, MysticMirrorReflection>{
      for (final item in currentReflections.values)
        if (validRecordIds.contains(item.recordId)) item.recordId: item,
    };
    var changedReflections = 0;
    for (final item in imported.reflections.values) {
      if (!validRecordIds.contains(item.recordId)) continue;
      final existing = reflections[item.recordId];
      if (existing == null || item.completedAt.isAfter(existing.completedAt)) {
        reflections[item.recordId] = item;
        changedReflections++;
      }
    }

    final oracleById = <String, OracleConversationTurn>{
      for (final item in currentOracle)
        if (validRecordIds.contains(item.recordId)) item.turnId: item,
    };
    var addedOracle = 0;
    for (final item in imported.oracleTurns) {
      if (!validRecordIds.contains(item.recordId)) continue;
      if (!oracleById.containsKey(item.turnId)) addedOracle++;
      oracleById.putIfAbsent(item.turnId, () => item);
    }
    final orderedOracle = oracleById.values.toList()
      ..sort((first, second) => first.createdAt.compareTo(second.createdAt));

    final currentIds = current.map(readingJournalRecordId).toSet();
    return PrivateJournalTransferPreview(
      mergedRecords: List<ReadingRecord>.unmodifiable(records),
      mergedReflections: Map<String, MysticMirrorReflection>.unmodifiable(
        reflections,
      ),
      mergedOracleTurns: List<OracleConversationTurn>.unmodifiable(
        orderedOracle,
      ),
      importedReadings: imported.records.length,
      importedReflections: imported.reflections.length,
      importedOracleTurns: imported.oracleTurns.length,
      addedReadings: imported.records
          .map(readingJournalRecordId)
          .where((id) => !currentIds.contains(id))
          .length,
      changedReflections: changedReflections,
      addedOracleTurns: addedOracle,
      rejectedItems: imported.rejectedItems,
      wasProtected: wasProtected,
    );
  }

  Future<PrivateJournalTransferPreview> commit({
    required String code,
    required Iterable<ReadingRecord> currentRecords,
    String? passphrase,
  }) async {
    final preview = await this.preview(
      code: code,
      currentRecords: currentRecords,
      passphrase: passphrase,
    );
    if (preview.totalChanges == 0) return preview;

    final preferences = await _preferences();
    final snapshot = <String, Object?>{
      for (final key in _transactionKeys) key: preferences.get(key),
    };
    final current = _orderedRecords(currentRecords);
    final currentReflections = await _mirrorStore.load();
    final currentOracle = await _oracleStore.loadAll();
    final discovered = <String>{
      ...?preferences.getStringList('discovered_cards'),
      ...preview.mergedRecords.expand(
        (record) => record.cards.map((item) => item.card.name),
      ),
    };

    try {
      await _mustWrite(
        preferences.setString(
          ReadingJournalStore.backupKey,
          ReadingJournalCodec.encode(current),
        ),
      );
      await _mustWrite(
        preferences.setStringList(
          MysticMirrorStore.backupKey,
          _orderedReflections(
            currentReflections.values,
          ).map((item) => item.encode()).toList(growable: false),
        ),
      );
      await _mustWrite(
        preferences.setStringList(
          OracleConversationStore.backupKey,
          currentOracle.map((item) => item.encode()).toList(growable: false),
        ),
      );
      await _mustWrite(
        preferences.setString(
          ReadingJournalStore.primaryKey,
          ReadingJournalCodec.encode(preview.mergedRecords),
        ),
      );
      await _mustWrite(
        preferences.setStringList(
          MysticMirrorStore.storageKey,
          _orderedReflections(
            preview.mergedReflections.values,
          ).map((item) => item.encode()).toList(growable: false),
        ),
      );
      await _mustWrite(
        preferences.setStringList(
          OracleConversationStore.storageKey,
          preview.mergedOracleTurns
              .map((item) => item.encode())
              .toList(growable: false),
        ),
      );
      await _mustWrite(
        preferences.setStringList(
          'discovered_cards',
          discovered.toList(growable: false)..sort(),
        ),
      );
      return preview;
    } catch (error) {
      await _rollback(preferences, snapshot);
      throw StateError(
        'Private journal restore could not be committed: $error',
      );
    }
  }

  Future<JournalTransferResult> _decode(
    String code, {
    String? passphrase,
  }) async {
    if (!JournalTransferProtection.isProtectedCode(code)) {
      return JournalTransferCodec.decode(code);
    }
    final clearCode = await JournalTransferProtection.unlock(
      protectedCode: code,
      passphrase: passphrase ?? '',
    );
    return JournalTransferCodec.decode(clearCode);
  }

  List<ReadingRecord> _mergeRecords(
    Iterable<ReadingRecord> current,
    Iterable<ReadingRecord> imported,
  ) {
    final merged = <String, ReadingRecord>{};
    for (final item in current) {
      merged[readingJournalRecordId(item)] = item;
    }
    for (final item in imported) {
      merged.putIfAbsent(readingJournalRecordId(item), () => item);
    }
    return _orderedRecords(merged.values);
  }

  List<ReadingRecord> _orderedRecords(Iterable<ReadingRecord> records) {
    final result = records.toList()
      ..sort((first, second) => second.createdAt.compareTo(first.createdAt));
    return result;
  }

  List<MysticMirrorReflection> _orderedReflections(
    Iterable<MysticMirrorReflection> reflections,
  ) {
    final result = reflections.toList()
      ..sort(
        (first, second) => second.completedAt.compareTo(first.completedAt),
      );
    return result;
  }

  Future<void> _mustWrite(Future<bool> operation) async {
    if (!await operation) throw StateError('Local storage rejected a write.');
  }

  Future<void> _rollback(
    SharedPreferences preferences,
    Map<String, Object?> snapshot,
  ) async {
    for (final entry in snapshot.entries) {
      final value = entry.value;
      if (value == null) {
        await preferences.remove(entry.key);
      } else if (value is String) {
        await preferences.setString(entry.key, value);
      } else if (value is List<String>) {
        await preferences.setStringList(entry.key, value);
      } else if (value is List) {
        await preferences.setStringList(
          entry.key,
          value.whereType<String>().toList(growable: false),
        );
      }
    }
  }

  static const _transactionKeys = <String>[
    ReadingJournalStore.primaryKey,
    ReadingJournalStore.backupKey,
    MysticMirrorStore.storageKey,
    MysticMirrorStore.backupKey,
    OracleConversationStore.storageKey,
    OracleConversationStore.backupKey,
    'discovered_cards',
  ];
}
