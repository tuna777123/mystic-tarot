import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/business_metrics.dart';

void main() {
  tearDown(MysticBusinessMetrics.configure);

  test('allow-listed coarse dimensions are normalized and accepted', () {
    final result = MysticBusinessMetrics.validateDimensions({
      'language': 'TR',
      'reading_kind': 'daily',
      'source': 'mirror',
    });

    expect(result, {
      'language': 'TR',
      'reading_kind': 'daily',
      'source': 'mirror',
    });
  });

  test('private or unknown dimensions are rejected', () {
    for (final key in [
      'question',
      'journal_text',
      'card_name',
      'emotion',
      'outcome',
      'user_name',
      'intention',
    ]) {
      expect(
        () => MysticBusinessMetrics.validateDimensions({key: 'private'}),
        throwsArgumentError,
        reason: key,
      );
    }
  });

  test('oversized values cannot become accidental content payloads', () {
    expect(
      () => MysticBusinessMetrics.validateDimensions({
        'source': 'x' * 65,
      }),
      throwsArgumentError,
    );
  });

  test('reporter receives only validated aggregate dimensions', () async {
    MysticBusinessEvent? capturedEvent;
    Map<String, String>? capturedDimensions;
    MysticBusinessMetrics.configure(
      reporter: (event, dimensions) {
        capturedEvent = event;
        capturedDimensions = dimensions;
      },
    );

    await MysticBusinessMetrics.record(
      MysticBusinessEvent.mirrorCompleted,
      dimensions: const {'language': 'EN', 'source': 'living_journal'},
    );

    expect(capturedEvent, MysticBusinessEvent.mirrorCompleted);
    expect(capturedDimensions, {
      'language': 'EN',
      'source': 'living_journal',
    });
  });

  test('remote reporter failure never escapes into a product flow', () async {
    MysticBusinessMetrics.configure(
      reporter: (event, dimensions) async {
        throw StateError('analytics unavailable');
      },
    );

    await expectLater(
      MysticBusinessMetrics.record(
        MysticBusinessEvent.mirrorShareStarted,
        dimensions: const {'language': 'TR', 'source': 'living_journal'},
      ),
      completes,
    );
  });
}
