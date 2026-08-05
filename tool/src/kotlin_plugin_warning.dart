class KotlinPluginWarningSnapshot {
  const KotlinPluginWarningSnapshot({
    required this.warningPresent,
    required this.plugins,
  });

  static const warningPrefix =
      'WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP):';

  final bool warningPresent;
  final Set<String> plugins;

  static KotlinPluginWarningSnapshot parse(String source) {
    final normalized = source.replaceAll(
      RegExp(r'\x1B\[[0-?]*[ -/]*[@-~]'),
      '',
    );
    final warningPresent = normalized.contains(warningPrefix);
    final pattern = RegExp(
      '${RegExp.escape(warningPrefix)}\\s*([^\\r\\n]+)',
    );
    final matches = pattern.allMatches(normalized).toList(growable: false);

    if (warningPresent && matches.isEmpty) {
      throw const FormatException(
        'Flutter reported legacy Kotlin plugin usage, but the plugin list '
        'could not be parsed.',
      );
    }

    final plugins = <String>{};
    for (final match in matches) {
      final pluginList = match.group(1);
      if (pluginList == null) {
        continue;
      }
      plugins.addAll(
        pluginList
            .split(',')
            .map((plugin) => plugin.trim())
            .where((plugin) => plugin.isNotEmpty),
      );
    }

    if (warningPresent && plugins.isEmpty) {
      throw const FormatException(
        'Flutter reported legacy Kotlin plugin usage without any plugin names.',
      );
    }

    return KotlinPluginWarningSnapshot(
      warningPresent: warningPresent,
      plugins: Set<String>.unmodifiable(plugins),
    );
  }

  Set<String> unexpectedPlugins(Set<String> allowedPlugins) {
    return plugins.difference(allowedPlugins);
  }
}
