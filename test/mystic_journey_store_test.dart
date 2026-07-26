import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/mystic_journey.dart';
import 'package:mystic_tarot/src/mystic_journey_codec.dart';
import 'package:mystic_tarot/src/mystic_journey_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MysticJourney journey(String id) => MysticJourney(
        id: id,
        title: 'Journey $id',
        area: JourneyArea.custom,
        createdAt: DateTime.utc(2026, 7, 20),
      );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saves and loads journeys', () async {
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesMysticJourneyStore(
      preferences: preferences,
    );

    await store.save([journey('one'), journey('two')]);
    final result = await store.load();

    expect(result.journeys.map((item) => item.id), ['one', 'two']);
    expect(result.recoveredFromBackup, isFalse);
    expect(result.rejectedItems, 0);
  });

  test('preserves the previous snapshot before replacing primary data',
      () async {
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesMysticJourneyStore(
      preferences: preferences,
    );

    await store.save([journey('first')]);
    await store.save([journey('second')]);

    final backup = preferences.getString(
      SharedPreferencesMysticJourneyStore.backupKey,
    );
    final backupReport = MysticJourneyCodec.decode(backup!);

    expect(backupReport.journeys.single.id, 'first');
    expect((await store.load()).journeys.single.id, 'second');
  });

  test('recovers from backup when primary data is corrupted', () async {
    final backup = MysticJourneyCodec.encode([journey('safe')]);
    SharedPreferences.setMockInitialValues({
      SharedPreferencesMysticJourneyStore.primaryKey: '{corrupted',
      SharedPreferencesMysticJourneyStore.backupKey: backup,
    });
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesMysticJourneyStore(
      preferences: preferences,
    );

    final result = await store.load();

    expect(result.journeys.single.id, 'safe');
    expect(result.recoveredFromBackup, isTrue);
  });

  test('returns a safe empty result when both snapshots are corrupted',
      () async {
    SharedPreferences.setMockInitialValues({
      SharedPreferencesMysticJourneyStore.primaryKey: 'bad-primary',
      SharedPreferencesMysticJourneyStore.backupKey: 'bad-backup',
    });
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesMysticJourneyStore(
      preferences: preferences,
    );

    final result = await store.load();

    expect(result.journeys, isEmpty);
    expect(result.recoveredFromBackup, isFalse);
  });

  test('clears primary and backup snapshots', () async {
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesMysticJourneyStore(
      preferences: preferences,
    );

    await store.save([journey('one')]);
    await store.save([journey('two')]);
    await store.clear();

    expect(
        preferences.containsKey(
          SharedPreferencesMysticJourneyStore.primaryKey,
        ),
        isFalse);
    expect(
        preferences.containsKey(
          SharedPreferencesMysticJourneyStore.backupKey,
        ),
        isFalse);
  });
}
