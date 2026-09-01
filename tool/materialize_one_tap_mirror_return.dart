import 'dart:io';

void main() => materializeOneTapMirrorReturn();

/// Makes the strongest retention loop reachable from Home in one intentional
/// action: when Mystic's next action is a due Mirror check-in, opening it jumps
/// directly into the oldest due reality check instead of stopping at Journal.
///
/// The transformation is deterministic, idempotent and fails closed when the
/// source contract changes unexpectedly.
void materializeOneTapMirrorReturn() {
  final app = File('lib/src/app.dart');
  final journal = File('lib/src/mystic_living_journal_feature.dart');
  if (!app.existsSync() || !journal.existsSync()) {
    throw StateError('Mystic one-tap Mirror source files are missing.');
  }

  final appSource = transformOneTapMirrorAppSource(app.readAsStringSync());
  final journalSource = transformOneTapMirrorJournalSource(
    journal.readAsStringSync(),
  );
  app.writeAsStringSync(appSource);
  journal.writeAsStringSync(journalSource);

  if (!appSource.contains('onOpenDueMirror: _openDueMirrorFromHome')) {
    throw StateError('Home does not expose the direct due-Mirror action.');
  }
  if (!journalSource.contains('final int mirrorOpenRequest;')) {
    throw StateError('Living Journal does not expose the Mirror request token.');
  }
  if (!journalSource.contains('_openRequestedMirrorWhenReady')) {
    throw StateError('Living Journal does not handle direct Mirror requests.');
  }

  stdout.writeln(
    'One-tap Mystic Mirror return materialized: due reality checks open '
    'directly from Home while pattern review still opens the Journal.',
  );
}

String transformOneTapMirrorAppSource(String source) {
  var updated = source;

  updated = _replaceRequired(
    updated,
    '''  int mirrorDueCount = 0;
  String? journalRecoveryMessage;''',
    '''  int mirrorDueCount = 0;
  int _mirrorOpenRequest = 0;
  String? journalRecoveryMessage;''',
    'Mirror request state',
  );

  updated = _replaceRequired(
    updated,
    '''          onPremium: _showPremium,
          onOpenDestiny: _openDestinyHub,
          onOpenJournal: () => setState(() => tab = 2),''',
    '''          onPremium: _showPremium,
          onOpenDestiny: _openDestinyHub,
          onOpenDueMirror: _openDueMirrorFromHome,
          onOpenJournal: () => setState(() => tab = 2),''',
    'Home due-Mirror callback',
  );

  updated = _replaceRequired(
    updated,
    '''        MysticLivingJournalFeature(
          records: journal,
          language: language,''',
    '''        MysticLivingJournalFeature(
          records: journal,
          language: language,
          mirrorOpenRequest: _mirrorOpenRequest,''',
    'Journal Mirror request token',
  );

  updated = _insertBeforeRequired(
    updated,
    '''  Future<void> _openSavedOracle(ReadingRecord record) async {''',
    '''  void _openDueMirrorFromHome() {
    setState(() {
      tab = 2;
      _mirrorOpenRequest++;
    });
  }

''',
    'Home due-Mirror navigation method',
  );

  updated = _replaceRequired(
    updated,
    '''    required this.onPremium,
    required this.onOpenDestiny,
    required this.onOpenJournal,''',
    '''    required this.onPremium,
    required this.onOpenDestiny,
    required this.onOpenDueMirror,
    required this.onOpenJournal,''',
    'HomeScreen constructor due-Mirror callback',
  );

  updated = _replaceRequired(
    updated,
    '''  final VoidCallback onPremium;
  final VoidCallback onOpenDestiny;
  final VoidCallback onOpenJournal;''',
    '''  final VoidCallback onPremium;
  final VoidCallback onOpenDestiny;
  final VoidCallback onOpenDueMirror;
  final VoidCallback onOpenJournal;''',
    'HomeScreen due-Mirror field',
  );

  updated = _replaceRequired(
    updated,
    '''      case MysticNextActionType.mirrorCheckIn:
      case MysticNextActionType.reviewPattern:
        onOpenJournal();
        return;''',
    '''      case MysticNextActionType.mirrorCheckIn:
        onOpenDueMirror();
        return;
      case MysticNextActionType.reviewPattern:
        onOpenJournal();
        return;''',
    'Home next-action Mirror deep link',
  );

  return updated;
}

String transformOneTapMirrorJournalSource(String source) {
  var updated = source;

  updated = _replaceRequired(
    updated,
    '''    this.onStartReading,
    this.onMirrorChanged,
    super.key,''',
    '''    this.onStartReading,
    this.onMirrorChanged,
    this.mirrorOpenRequest = 0,
    super.key,''',
    'Living Journal Mirror request constructor',
  );

  updated = _replaceRequired(
    updated,
    '''  final VoidCallback? onStartReading;
  final VoidCallback? onMirrorChanged;''',
    '''  final VoidCallback? onStartReading;
  final VoidCallback? onMirrorChanged;
  final int mirrorOpenRequest;''',
    'Living Journal Mirror request field',
  );

  updated = _replaceRequired(
    updated,
    '''  bool mirrorsLoading = true;
  bool oracleLoading = true;''',
    '''  bool mirrorsLoading = true;
  bool oracleLoading = true;
  int _handledMirrorOpenRequest = 0;''',
    'Living Journal handled Mirror request state',
  );

  updated = _replaceRequired(
    updated,
    '''  @override
  void initState() {
    super.initState();
    _loadMirrors();
    _loadOracleMemory();
  }

  Future<void> _loadMirrors() async {''',
    '''  @override
  void initState() {
    super.initState();
    _loadMirrors();
    _loadOracleMemory();
  }

  @override
  void didUpdateWidget(covariant MysticLivingJournalFeature oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mirrorOpenRequest != oldWidget.mirrorOpenRequest) {
      _openRequestedMirrorWhenReady();
    }
  }

  Future<void> _loadMirrors() async {''',
    'Living Journal request update hook',
  );

  updated = _replaceRequired(
    updated,
    '''    setState(() {
      mirrors = loaded;
      mirrorsLoading = false;
    });
  }

  Future<void> _loadOracleMemory() async {''',
    '''    setState(() {
      mirrors = loaded;
      mirrorsLoading = false;
    });
    _openRequestedMirrorWhenReady();
  }

  void _openRequestedMirrorWhenReady() {
    if (mirrorsLoading ||
        widget.mirrorOpenRequest <= _handledMirrorOpenRequest) {
      return;
    }
    _handledMirrorOpenRequest = widget.mirrorOpenRequest;
    final dueRecords = _dueRecords;
    if (dueRecords.isEmpty) return;
    final record = dueRecords.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _openMirrorCheckIn(record);
    });
  }

  Future<void> _loadOracleMemory() async {''',
    'Living Journal direct Mirror request handler',
  );

  return updated;
}

String _replaceRequired(
  String source,
  String oldValue,
  String newValue,
  String label,
) {
  if (source.contains(newValue)) return source;
  final count = oldValue.allMatches(source).length;
  if (count != 1) {
    throw StateError(
      'Unable to materialize $label: expected exactly one source anchor, '
      'found $count.',
    );
  }
  return source.replaceFirst(oldValue, newValue);
}

String _insertBeforeRequired(
  String source,
  String anchor,
  String insertion,
  String label,
) {
  if (source.contains(insertion)) return source;
  final count = anchor.allMatches(source).length;
  if (count != 1) {
    throw StateError(
      'Unable to materialize $label: expected exactly one insertion anchor, '
      'found $count.',
    );
  }
  return source.replaceFirst(anchor, '$insertion$anchor');
}
