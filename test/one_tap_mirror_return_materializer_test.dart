import 'package:flutter_test/flutter_test.dart';

import '../tool/materialize_one_tap_mirror_return.dart';

void main() {
  const appSource = '''
class AppState {
  int mirrorDueCount = 0;
  String? journalRecoveryMessage;

  void shell() {
    HomeScreen(
          onPremium: _showPremium,
          onOpenDestiny: _openDestinyHub,
          onOpenJournal: () => setState(() => tab = 2),
    );
        MysticLivingJournalFeature(
          records: journal,
          language: language,
    );
  }

  Future<void> _openSavedOracle(ReadingRecord record) async {}
}

class HomeScreen {
  const HomeScreen({
    required this.onPremium,
    required this.onOpenDestiny,
    required this.onOpenJournal,
  });

  final VoidCallback onPremium;
  final VoidCallback onOpenDestiny;
  final VoidCallback onOpenJournal;

  void run(MysticNextActionType type) {
    switch (type) {
      case MysticNextActionType.mirrorCheckIn:
      case MysticNextActionType.reviewPattern:
        onOpenJournal();
        return;
      default:
        return;
    }
  }
}
''';

  const journalSource = '''
class MysticLivingJournalFeature {
  const MysticLivingJournalFeature({
    this.onStartReading,
    this.onMirrorChanged,
    super.key,
  });

  final VoidCallback? onStartReading;
  final VoidCallback? onMirrorChanged;
}

class State {
  bool mirrorsLoading = true;
  bool oracleLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMirrors();
    _loadOracleMemory();
  }

  Future<void> _loadMirrors() async {
    final loaded = await _mirrorStore.load();
    if (!mounted) return;
    setState(() {
      mirrors = loaded;
      mirrorsLoading = false;
    });
  }

  Future<void> _loadOracleMemory() async {}
}
''';

  test('due Mirror next action becomes a direct check-in request', () {
    final transformed = transformOneTapMirrorAppSource(appSource);

    expect(transformed, contains('onOpenDueMirror: _openDueMirrorFromHome'));
    expect(transformed, contains('mirrorOpenRequest: _mirrorOpenRequest'));
    expect(
      transformed,
      contains(
        'case MysticNextActionType.mirrorCheckIn:\n        onOpenDueMirror();',
      ),
    );
    expect(
      transformed,
      contains(
        'case MysticNextActionType.reviewPattern:\n        onOpenJournal();',
      ),
    );
  });

  test('Living Journal opens the oldest due Mirror after becoming visible', () {
    final transformed = transformOneTapMirrorJournalSource(journalSource);

    expect(transformed, contains('final int mirrorOpenRequest;'));
    expect(transformed, contains('void didUpdateWidget'));
    expect(transformed, contains('final dueRecords = _dueRecords;'));
    expect(transformed, contains('_openMirrorCheckIn(record);'));
  });

  test('both transformations are idempotent', () {
    final appOnce = transformOneTapMirrorAppSource(appSource);
    final journalOnce = transformOneTapMirrorJournalSource(journalSource);

    expect(transformOneTapMirrorAppSource(appOnce), appOnce);
    expect(transformOneTapMirrorJournalSource(journalOnce), journalOnce);
  });

  test('unexpected source fails closed', () {
    expect(
      () => transformOneTapMirrorAppSource('unknown app source'),
      throwsStateError,
    );
    expect(
      () => transformOneTapMirrorJournalSource('unknown journal source'),
      throwsStateError,
    );
  });
}
