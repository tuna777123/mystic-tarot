class KotlinPluginAuditFailure implements Exception {
  const KotlinPluginAuditFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

Set<String> parseLegacyKotlinPluginWarnings(String buildLog) {
  final pattern = RegExp(
    r'WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin \(KGP\):\s*([^\r\n]+)',
  );
  return {
    for (final match in pattern.allMatches(buildLog))
      for (final plugin in match.group(1)!.split(','))
        if (plugin.trim().isNotEmpty) plugin.trim(),
  };
}

KotlinPluginAuditResult auditLegacyKotlinPlugins({
  required String buildLog,
  required Set<String> allowedBlockers,
}) {
  final detected = parseLegacyKotlinPluginWarnings(buildLog);
  final unexpected = detected.difference(allowedBlockers);
  if (unexpected.isNotEmpty) {
    final names = unexpected.toList()..sort();
    throw KotlinPluginAuditFailure(
      'Unexpected plugins still apply the legacy Kotlin Gradle Plugin: '
      '${names.join(', ')}.',
    );
  }

  return KotlinPluginAuditResult(
    detectedBlockers: detected,
    resolvedBlockers: allowedBlockers.difference(detected),
  );
}

class KotlinPluginAuditResult {
  const KotlinPluginAuditResult({
    required this.detectedBlockers,
    required this.resolvedBlockers,
  });

  final Set<String> detectedBlockers;
  final Set<String> resolvedBlockers;

  String formatReport() {
    String sortedOrNone(Set<String> values) {
      if (values.isEmpty) return 'none';
      final sorted = values.toList()..sort();
      return sorted.join(', ');
    }

    return '''# Built-in Kotlin Compatibility Audit

- Result: **PASS**
- Remaining upstream KGP blockers: `${sortedOrNone(detectedBlockers)}`
- Allowed blockers already resolved: `${sortedOrNone(resolvedBlockers)}`

Any plugin outside the reviewed allowlist fails the Android release workflow.
''';
  }
}
