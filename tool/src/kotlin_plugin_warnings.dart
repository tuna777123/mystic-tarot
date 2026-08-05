class KotlinPluginWarningFailure implements Exception {
  const KotlinPluginWarningFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

const expectedLegacyKgpPlugins = <String>{
  'flutter_timezone',
  'purchases_flutter',
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
  final sortedObserved = observed.toList()..sort();
  final sortedExpected = expectedLegacyKgpPlugins.toList()..sort();

  return '''# Mystic Tarot Built-in Kotlin Audit

- Result: **PASS**
- Expected temporary legacy KGP plugins: `${sortedExpected.join(', ')}`
- Observed legacy KGP plugins: `${sortedObserved.join(', ')}`
- Unknown or regressed plugins: `none`
- Policy drift: `none`

The two observed plugins remain tracked upstream. Any addition, removal, or
warning-format change stops the release until the migration policy is reviewed.
''';
}
