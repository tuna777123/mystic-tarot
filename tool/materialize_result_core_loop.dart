import 'dart:io';

const _sourcePath = 'lib/src/app.dart';

void main() => materializeResultCoreLoop();

void materializeResultCoreLoop() {
  final file = File(_sourcePath);
  if (!file.existsSync()) {
    throw StateError('$_sourcePath is missing.');
  }

  final original = file.readAsStringSync();
  final updated = materializeResultCoreLoopInSource(original);
  if (updated != original) {
    file.writeAsStringSync(updated);
  }
}

String materializeResultCoreLoopInSource(String source) {
  const loopMarker = "'MYSTIC MIRROR • 24H LOOP'";
  const saveMarker = "'Save this reading'";
  const memoryMarker = '_memoryBridge(context),';
  const oracleMarker = '_oracleInvitation(context, record),';
  const savedStateAnchor =
      '              if (revealComplete && saved) const SizedBox(height: 10),';

  final loopIndex = _uniqueIndex(source, loopMarker);
  final saveIndex = _uniqueIndex(source, saveMarker);
  final memoryIndex = _uniqueIndex(source, memoryMarker);
  final oracleIndex = _uniqueIndex(source, oracleMarker);
  final savedStateIndex = _uniqueIndex(source, savedStateAnchor);

  final alreadyMaterialized =
      loopIndex < saveIndex &&
      saveIndex < memoryIndex &&
      memoryIndex < oracleIndex &&
      oracleIndex < savedStateIndex;
  if (alreadyMaterialized) return source;

  final legacyOrder =
      memoryIndex < oracleIndex &&
      oracleIndex < loopIndex &&
      loopIndex < saveIndex &&
      saveIndex < savedStateIndex;
  if (!legacyOrder) {
    throw StateError(
      'Reading result hierarchy no longer matches the reviewed legacy or materialized order.',
    );
  }

  const legacySecondaryBlock = '''              if (revealComplete && widget.pastRecords.isNotEmpty)
                const SizedBox(height: 14),
              if (revealComplete && widget.pastRecords.isNotEmpty)
                _memoryBridge(context),
              if (revealComplete) const SizedBox(height: 14),
              if (revealComplete) _oracleInvitation(context, record),
              if (revealComplete) const SizedBox(height: 14),
''';
  _requireUnique(source, legacySecondaryBlock);

  const coreLoopSpacer =
      '              if (revealComplete) const SizedBox(height: 14),\n';
  const movedSecondaryBlock = '''              if (revealComplete && widget.pastRecords.isNotEmpty)
                const SizedBox(height: 14),
              if (revealComplete && widget.pastRecords.isNotEmpty)
                _memoryBridge(context),
              if (revealComplete) const SizedBox(height: 14),
              if (revealComplete) _oracleInvitation(context, record),
''';

  var updated = source.replaceFirst(legacySecondaryBlock, coreLoopSpacer);
  _requireUnique(updated, savedStateAnchor);
  updated = updated.replaceFirst(
    savedStateAnchor,
    '$movedSecondaryBlock$savedStateAnchor',
  );

  final updatedLoopIndex = _uniqueIndex(updated, loopMarker);
  final updatedSaveIndex = _uniqueIndex(updated, saveMarker);
  final updatedMemoryIndex = _uniqueIndex(updated, memoryMarker);
  final updatedOracleIndex = _uniqueIndex(updated, oracleMarker);
  if (!(updatedLoopIndex < updatedSaveIndex &&
      updatedSaveIndex < updatedMemoryIndex &&
      updatedMemoryIndex < updatedOracleIndex)) {
    throw StateError('Reading result hierarchy materialization failed.');
  }

  return updated;
}

int _uniqueIndex(String source, String marker) {
  _requireUnique(source, marker);
  return source.indexOf(marker);
}

void _requireUnique(String source, String marker) {
  final first = source.indexOf(marker);
  final last = source.lastIndexOf(marker);
  if (first < 0 || first != last) {
    throw StateError('Expected exactly one result hierarchy anchor: $marker');
  }
}
