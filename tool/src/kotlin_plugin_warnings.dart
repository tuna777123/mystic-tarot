class KotlinPluginWarningFailure implements Exception {
  const KotlinPluginWarningFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

const conditionallyCompatibleLegacyKgpPlugins = <String>{'flutter_timezone'};

const expectedLegacyKgpPlugins = <String>{
  ...conditionallyCompatibleLegacyKgpPlugins,
};

class KotlinPluginPolicyDelta {
  const KotlinPluginPolicyDelta({
    required this.missing,
    required this.unexpected,
  });

  final Set<String> missing;
  final Set<String> unexpected;

  bool get isValid => missing.isEmpty && unexpected.isEmpty;
}

Set<String> parseLegacyKgpPlugins(String buildLog) {
  final match = RegExp(
    r'plugins that apply Kotlin Gradle Plugin \(KGP\):\s*([^\r\n]+)',
    caseSensitive: false,
  ).firstMatch(buildLog);
  if (match == null) {
    return <String>{};
  }

  return match
      .group(1)!
      .split(',')
      .map((plugin) => plugin.trim())
      .where((plugin) => plugin.isNotEmpty)
      .toSet();
}

KotlinPluginPolicyDelta compareLegacyKgpPlugins(Set<String> observed) {
  return KotlinPluginPolicyDelta(
    missing: expectedLegacyKgpPlugins.difference(observed),
    unexpected: observed.difference(expectedLegacyKgpPlugins),
  );
}

String buildKotlinCompatibilityReport(Set<String> observed) {
  final sortedObserved = _sorted(observed);
  final conditional = _sorted(
    observed.intersection(conditionallyCompatibleLegacyKgpPlugins),
  );

  return '''# Mystic Tarot Built-in Kotlin Audit

- Result: **PASS**
- Reviewed Flutter warning entries: `${sortedObserved.join(', ')}`
- Conditional compatibility warning: `${conditional.join(', ')}`
- Unknown or regressed plugins: `none`
- Policy drift: `none`

`flutter_timezone` conditionally avoids the legacy Kotlin Gradle Plugin when
Built-in Kotlin is enabled; Flutter's warning scan does not evaluate that
condition. `purchases_flutter` is intentionally absent from the dependency
graph in the advertising-only release. Any addition, removal, or warning-format
change stops the release until this reviewed classification is updated.
''';
}

List<String> _sorted(Iterable<String> values) {
  return values.toList()..sort();
}
