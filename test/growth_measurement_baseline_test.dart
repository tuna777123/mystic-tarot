import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mystic_tarot/src/growth_measurement_baseline.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists one local UTC measurement start across callers', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    var now = DateTime(2026, 8, 9, 20);
    final baseline = MysticGrowthMeasurementBaseline(
      preferences: preferences,
      now: () => now,
    );

    final first = await baseline.ensureStarted();
    now = DateTime(2026, 8, 10, 20);
    final second = await baseline.ensureStarted();

    expect(first, DateTime(2026, 8, 9, 20).toUtc());
    expect(second, first);
    expect(await baseline.read(), first);
  });

  test('delete-all style SharedPreferences clear starts a new cohort', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    var now = DateTime(2026, 8, 9, 20);
    final baseline = MysticGrowthMeasurementBaseline(
      preferences: preferences,
      now: () => now,
    );

    final first = await baseline.ensureStarted();
    await preferences.clear();
    now = DateTime(2026, 8, 12, 9);
    final restarted = await baseline.ensureStarted();

    expect(restarted, isNot(first));
    expect(restarted, DateTime(2026, 8, 12, 9).toUtc());
    expect(await baseline.read(), restarted);
  });

  test('explicit clear removes the internal timestamp', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final baseline = MysticGrowthMeasurementBaseline(
      preferences: preferences,
      now: () => DateTime(2026, 8, 9),
    );

    await baseline.ensureStarted();
    expect(preferences.containsKey(MysticGrowthMeasurementBaseline.storageKey), isTrue);

    await baseline.clear();

    expect(preferences.containsKey(MysticGrowthMeasurementBaseline.storageKey), isFalse);
    expect(await baseline.read(), isNull);
  });
}
