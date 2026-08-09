import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/business_metrics.dart';

void main() {
  tearDown(MysticBusinessMetrics.configure);

  test('allow-listed coarse dimensions and values are accepted', () {
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

  test('private content cannot hide inside an approved dimension value', () {
    expect(
      () => MysticBusinessMetrics.validateDimensions({
        'source': 'my private question',
      }),
      throwsArgumentError,
    );
    expect(
      () => MysticBusinessMetrics.validateDimensions({
        'language': 'secret diary text',
      }),
      throwsArgumentError,
    );
  });

  test('unknown coarse vocabulary values are rejected', () {
    expect(
      () => MysticBusinessMetrics.validateDimensions({
        'reading_kind': 'invented_spread',
      }),
      throwsArgumentError,
    );
    expect(
      () => MysticBusinessMetrics.validateDimensions({
        'ad_format': 'rewarded_video',
      }),
      throwsArgumentError,
    );
  });

  test('oversized values cannot become accidental content payloads', () {
    expect(
      () => MysticBusinessMetrics.validateDimensions({'source': 'x' * 65}),
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
    expect(capturedDimensions, {'language': 'EN', 'source': 'living_journal'});
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
