/// Keeps the earliest retention loop and due Mystic Mirrors visually dominant
/// instead of competing with every discovery surface on Home.
class HomeFocusPolicy {
  const HomeFocusPolicy._();

  /// Focus Home before the user has completed a second reading, and whenever
  /// at least one 24-hour Mystic Mirror is due.
  ///
  /// After the second reading the broader discovery surface returns unless a
  /// Mirror needs attention. This makes breadth progressive rather than hiding
  /// it permanently.
  static bool shouldFocus({
    required int readingCount,
    required int mirrorDueCount,
  }) {
    return mirrorDueCount > 0 || readingCount <= 1;
  }
}
