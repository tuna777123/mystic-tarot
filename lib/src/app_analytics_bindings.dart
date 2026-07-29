import 'app_analytics.dart';
import 'models.dart';

/// Small, UI-facing adapter for launch-critical product analytics.
///
/// Screens call these methods instead of constructing event payloads directly.
/// This keeps metadata stable, coarse and free of journal/question text.
final class MysticAnalyticsBindings {
  const MysticAnalyticsBindings({MysticAnalytics? analytics})
      : _analytics = analytics ?? MysticAnalytics.instance;

  final MysticAnalytics _analytics;

  Future<void> onboardingCompleted({
    required String language,
    required String intention,
  }) =>
      _analytics.track(
        MysticAnalyticsEvent.onboardingCompleted,
        properties: {
          'language': language,
          'intention': intention,
        },
      );

  Future<void> readingStarted(ReadingKind kind) => _analytics.track(
        MysticAnalyticsEvent.readingStarted,
        properties: {
          'reading_kind': kind.name,
          'card_count': kind.cardCount,
        },
      );

  Future<void> readingCompleted(
    ReadingRecord record, {
    required Duration elapsed,
  }) =>
      _analytics.track(
        MysticAnalyticsEvent.readingCompleted,
        properties: {
          'reading_kind': record.kind.name,
          'card_count': record.cards.length,
          'duration_seconds': elapsed.inSeconds,
        },
      );

  Future<void> journalViewed({required int savedReadingCount}) =>
      _analytics.track(
        MysticAnalyticsEvent.journalViewed,
        properties: {
          'saved_reading_count': savedReadingCount,
        },
      );

  Future<void> premiumViewed({required String source}) => _analytics.track(
        MysticAnalyticsEvent.premiumViewed,
        properties: {
          'source': source,
        },
      );

  Future<void> purchaseStarted({
    required String source,
    required String plan,
  }) =>
      _analytics.track(
        MysticAnalyticsEvent.purchaseStarted,
        properties: {
          'source': source,
          'plan': plan,
        },
      );

  Future<void> purchaseCompleted({
    required String source,
    required String plan,
    required bool restored,
  }) =>
      _analytics.track(
        MysticAnalyticsEvent.purchaseCompleted,
        properties: {
          'source': source,
          'plan': plan,
          'restored': restored,
        },
      );

  Future<void> purchaseRestored({required String source}) => _analytics.track(
        MysticAnalyticsEvent.purchaseRestored,
        properties: {
          'source': source,
        },
      );
}
