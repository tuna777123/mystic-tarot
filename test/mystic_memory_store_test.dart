import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/mystic_memory.dart';
import 'package:mystic_tarot/src/mystic_memory_codec.dart';
import 'package:mystic_tarot/src/mystic_memory_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TimelineEvent event(String id) => TimelineEvent(
        id: id,
        occurredAt: DateTime.utc(2026, 7, 27),
        type: MemoryEventType.note,
        title: 'Memory $id',
      );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saves and loads timeline events', () async {
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesMysticMemoryStore(
      preferences: preferences,
    );

    await store.save([event('one'), event('two')]);
    final result = await store.load();

    expect(result.events.map((item) => item.id), ['one', 'two']);
    expect(result.recoveredFromBackup, isFalse);
    expect(result.rejectedItems, 0);
  });

  test('preserves the previous snapshot before replacing primary data',
      () async {
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesMysticMemoryStore(
      preferences: preferences,
    );

    await store.save([event('first')]);
    await store.save([event('second')]);

    final backup = preferences.getString(
      SharedPreferencesMysticMemoryStore.backupKey,
    );
    final backupReport = MysticMemoryCodec.decode(backup!);

    expect(backupReport.events.single.id, 'first');
    expect((await store.load()).events.single.id, 'second');
  });

  test('recovers from backup when primary data is corrupted', () async {
    final backup = MysticMemoryCodec.encode([event('safe')]);
    SharedPreferences.setMockInitialValues({
      SharedPreferencesMysticMemoryStore.primaryKey: '{corrupted',
      SharedPreferencesMysticMemoryStore.backupKey: backup,
    });
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesMysticMemoryStore(
      preferences: preferences,
    );

    final result = await store.load();

    expect(result.events.single.id, 'safe');
    expect(result.recoveredFromBackup, isTrue);
  });

  test('returns a safe empty result when both snapshots are corrupted',
      () async {
    SharedPreferences.setMockInitialValues({
      SharedPreferencesMysticMemoryStore.primaryKey: 'bad-primary',
      SharedPreferencesMysticMemoryStore.backupKey: 'bad-backup',
    });
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesMysticMemoryStore(
      preferences: preferences,
    );

    final result = await store.load();

    expect(result.events, isEmpty);
    expect(result.recoveredFromBackup, isFalse);
  });

  test('clears primary and backup snapshots', () async {
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesMysticMemoryStore(
      preferences: preferences,
    );

    await store.save([event('one')]);
    await store.save([event('two')]);
    await store.clear();

    expect(
      preferences.containsKey(SharedPreferencesMysticMemoryStore.primaryKey),
      isFalse,
    );
    expect(
      preferences.containsKey(SharedPreferencesMysticMemoryStore.backupKey),
      isFalse,
    );
  });
}
