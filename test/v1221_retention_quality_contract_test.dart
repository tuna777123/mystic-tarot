import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'v1.22.1 retention-quality baseline survives the v1.23 ad-only release',
    () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final engine = File('lib/src/growth_engine.dart').readAsStringSync();
      final engineTests = File(
        'test/growth_engine_test.dart',
      ).readAsStringSync();
      final notes = File('RELEASE_NOTES.md').readAsStringSync();
      final patchNotes = File('RELEASE_NOTES_1.22.1.md').readAsStringSync();
      final previousPatchNotes = File(
        'RELEASE_NOTES_1.22.3.md',
      ).readAsStringSync();
      final currentReleaseNotes = File(
        'RELEASE_NOTES_1.23.0.md',
      ).readAsStringSync();
      final storePack = File('STORE_RELEASE.md').readAsStringSync();

      expect(pubspec, contains('version: 1.23.0+33'));
      expect(engine, contains('final activeDays = _activeDayCount(records);'));
      expect(
        engine.indexOf('if (visiblePattern)'),
        lessThan(engine.indexOf('if (completedArcanaDays < 22')),
      );
      expect(engine, contains('_calendarDayDifference(latest.createdAt, now)'));
      expect(
        engine,
        contains('.map((record) => _calendarDayKey(record.createdAt))'),
      );
      expect(
        engineTests,
        contains('same-day binge use does not masquerade as a durable habit'),
      );
      expect(
        engineTests,
        contains(
          'calendar-day return is recognized even when less than 24 hours passed',
        ),
      );
      expect(notes, startsWith('# Mystic Tarot 1.22.1'));
      expect(patchNotes, startsWith('# Mystic Tarot 1.22.1'));
      expect(previousPatchNotes, startsWith('# Mystic Tarot 1.22.3'));
      expect(previousPatchNotes, contains('Version `1.22.3+32`'));
      expect(currentReleaseNotes, startsWith('# Mystic Tarot 1.23.0'));
      expect(currentReleaseNotes, contains('1.23.0+33'));
      expect(
        storePack,
        contains('Current verified source version: `1.23.0+33`'),
      );
      expect(File('.github/workflows/v1221-format.yml').existsSync(), isFalse);
      expect(
        File('.github/workflows/v1221-finalize.yml').existsSync(),
        isFalse,
      );
    },
  );
}
