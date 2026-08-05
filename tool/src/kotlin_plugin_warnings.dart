class KotlinPluginWarningFailure implements Exception {
  const KotlinPluginWarningFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

const allowedLegacyKgpPlugins = <String>{
  'flutter_timezone',
  'purchases_flutter',
};

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

Set<String> findUnexpectedLegacyKgpPlugins(Set<String> plugins) {
  return plugins.difference(allowedLegacyKgpPlugins);
}

String buildKotlinCompatibilityReport(Set<String> plugins) {
  final sortedPlugins = plugins.toList()..sort();
  final String status;
  if (sortedPlugins.isEmpty) {
    status = 'All packaged Flutter plugins use Built-in Kotlin.';
  } else {
    status = 'Known upstream migration blockers remain: '
        '${sortedPlugins.join(', ')}.';
  }

  return '''# Mystic Tarot Built-in Kotlin Audit

- Result: **PASS**
- Legacy KGP plugins: `${sortedPlugins.isEmpty ? 'none' : sortedPlugins.join(', ')}`
- Policy: `share_plus and any unknown plugin must not apply KGP`

$status
''';
}
