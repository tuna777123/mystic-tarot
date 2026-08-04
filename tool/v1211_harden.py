from pathlib import Path

root = Path('.')


def replace_once(path: str, old: str, new: str) -> None:
    file = root / path
    source = file.read_text(encoding='utf-8')
    if old not in source:
        raise SystemExit(f'Missing expected source in {path}: {old[:80]!r}')
    file.write_text(source.replace(old, new, 1), encoding='utf-8')


# App-lock language must follow Mystic's selected language, not the device locale.
replace_once(
    'lib/src/app_lock_gate.dart',
    "import 'package:flutter/material.dart';\nimport 'package:flutter/services.dart';",
    "import 'package:flutter/material.dart';\nimport 'package:flutter/services.dart';\nimport 'package:flutter_localizations/flutter_localizations.dart';",
)
replace_once(
    'lib/src/app_lock_gate.dart',
    "import 'app_lock.dart';\nimport 'theme.dart';",
    "import 'app_lock.dart';\nimport 'app_locale.dart';\nimport 'theme.dart';",
)
replace_once(
    'lib/src/app_lock_gate.dart',
    "    this.authenticator,\n    this.promptDelay = const Duration(seconds: 6),",
    "    this.authenticator,\n    this.languageCodeLoader,\n    this.promptDelay = const Duration(seconds: 6),",
)
replace_once(
    'lib/src/app_lock_gate.dart',
    "  final AppLockAuthenticator? authenticator;\n  final Duration promptDelay;",
    "  final AppLockAuthenticator? authenticator;\n  final Future<String> Function()? languageCodeLoader;\n  final Duration promptDelay;",
)
replace_once(
    'lib/src/app_lock_gate.dart',
    "  String get _languageCode =>\n      WidgetsBinding.instance.platformDispatcher.locale.languageCode;",
    "  String _languageCode = 'en';",
)
replace_once(
    'lib/src/app_lock_gate.dart',
    "  Future<void> _initialize() async {\n",
    "  Future<String> _safeLanguageCode() async {\n    try {\n      final loader = widget.languageCodeLoader;\n      final code = loader == null\n          ? await loadPersistedMysticLanguageCode()\n          : await loader();\n      final normalized = code.trim();\n      return normalized.isEmpty ? 'en' : normalized;\n    } catch (_) {\n      return 'en';\n    }\n  }\n\n  Future<void> _refreshLanguage() async {\n    final code = await _safeLanguageCode();\n    if (!mounted || code == _languageCode) return;\n    setState(() => _languageCode = code);\n  }\n\n  Future<void> _initialize() async {\n",
)
replace_once(
    'lib/src/app_lock_gate.dart',
    "    try {\n      final state = await _service.loadState();",
    "    try {\n      final languageCode = await _safeLanguageCode();\n      final state = await _service.loadState();",
)
replace_once(
    'lib/src/app_lock_gate.dart',
    "      setState(() {\n        _state = state;",
    "      setState(() {\n        _languageCode = languageCode;\n        _state = state;",
)
replace_once(
    'lib/src/app_lock_gate.dart',
    "        _promptTimer = Timer(widget.promptDelay, () {\n          if (mounted && _mode == _AppLockMode.unlocked) {",
    "        _promptTimer = Timer(widget.promptDelay, () async {\n          await _refreshLanguage();\n          if (mounted && _mode == _AppLockMode.unlocked) {",
)
replace_once(
    'lib/src/app_lock_gate.dart',
    "    if (_mode == _AppLockMode.unlocked) {\n      setState(() => _mode = _AppLockMode.locked);\n      if ((_state?.biometricsEnabled ?? false) && _biometricAvailable) {\n        WidgetsBinding.instance.addPostFrameCallback((_) => _useBiometrics());\n      }\n    }\n  }\n\n  Future<void> _dismissPrompt() async {",
    "    if (_mode == _AppLockMode.unlocked) {\n      unawaited(_lockAfterBackground());\n    }\n  }\n\n  Future<void> _lockAfterBackground() async {\n    await _refreshLanguage();\n    if (!mounted || _mode != _AppLockMode.unlocked) return;\n    setState(() => _mode = _AppLockMode.locked);\n    if ((_state?.biometricsEnabled ?? false) && _biometricAvailable) {\n      WidgetsBinding.instance.addPostFrameCallback((_) => _useBiometrics());\n    }\n  }\n\n  Future<void> _dismissPrompt() async {",
)
replace_once(
    'lib/src/app_lock_gate.dart',
    "                  onPressed: () => setState(() {\n                    _mode = lockEnabled\n                        ? _AppLockMode.locked\n                        : _AppLockMode.setup;\n                  }),",
    "                  onPressed: () async {\n                    await _refreshLanguage();\n                    if (!mounted) return;\n                    setState(() {\n                      _mode = lockEnabled\n                          ? _AppLockMode.locked\n                          : _AppLockMode.setup;\n                    });\n                  },",
)
replace_once(
    'lib/src/app_lock_gate.dart',
    "  Widget _standalone(Widget home) => MaterialApp(\n        title: 'Mystic Tarot',\n        debugShowCheckedModeBanner: false,\n        theme: buildMysticTheme(),\n        home: home,\n      );",
    "  Widget _standalone(Widget home) => MaterialApp(\n        title: 'Mystic Tarot',\n        debugShowCheckedModeBanner: false,\n        locale: mysticLocaleFromCode(_languageCode),\n        localizationsDelegates: GlobalMaterialLocalizations.delegates,\n        supportedLocales: mysticSupportedLocales,\n        theme: buildMysticTheme(),\n        home: home,\n      );",
)

# The primary app shell must localize native Material controls as well as custom copy.
replace_once(
    'lib/src/app.dart',
    "import 'package:flutter/material.dart';\nimport 'package:flutter/services.dart';",
    "import 'package:flutter/material.dart';\nimport 'package:flutter/services.dart';\nimport 'package:flutter_localizations/flutter_localizations.dart';",
)
replace_once(
    'lib/src/app.dart',
    "import 'app_language.dart';\nimport 'daily_practice.dart';",
    "import 'app_language.dart';\nimport 'app_locale.dart';\nimport 'daily_practice.dart';",
)
replace_once(
    'lib/src/app.dart',
    "    title: 'Mystic Tarot',\n    navigatorKey: navigatorKey,\n    debugShowCheckedModeBanner: false,\n    theme: buildMysticTheme(),",
    "    title: 'Mystic Tarot',\n    navigatorKey: navigatorKey,\n    debugShowCheckedModeBanner: false,\n    locale: mysticLocale(language),\n    localizationsDelegates: GlobalMaterialLocalizations.delegates,\n    supportedLocales: mysticSupportedLocales,\n    theme: buildMysticTheme(),",
)

# Add Flutter's official native localization delegates and bump the patch release.
replace_once(
    'pubspec.yaml',
    'version: 1.21.0+27',
    'version: 1.21.1+28',
)
replace_once(
    'pubspec.yaml',
    "  flutter:\n    sdk: flutter\n  audioplayers:",
    "  flutter:\n    sdk: flutter\n  flutter_localizations:\n    sdk: flutter\n  audioplayers:",
)

# Make formatting and whitespace release gates permanent.
replace_once(
    '.github/workflows/flutter-ci.yml',
    "      - name: Analyze\n        run: flutter analyze\n",
    "      - name: Verify formatting\n        run: dart format --output=none --set-exit-if-changed lib test tool\n\n      - name: Verify clean diff\n        run: git diff --check\n\n      - name: Analyze\n        run: flutter analyze --fatal-infos\n",
)

notes = root / 'RELEASE_NOTES.md'
source = notes.read_text(encoding='utf-8')
section = """# Mystic Tarot 1.21.1 — Prelaunch Hardening\n\n- App-lock, PIN, biometric, and native Material controls now follow the language selected inside Mystic rather than leaking the device language.\n- Background/resume relocking refreshes the selected language and preserves the configured grace period.\n- CI now rejects unformatted Dart and whitespace defects.\n- A macOS/Xcode gate builds the unsigned iOS release before store submission.\n- Version `1.21.1+28`.\n\n"""
if not source.startswith('# Mystic Tarot 1.21.1'):
    notes.write_text(section + source, encoding='utf-8')

store = root / 'STORE_RELEASE.md'
source = store.read_text(encoding='utf-8')
marker = 'This is the canonical launch handoff for App Store Connect, Google Play Console, and RevenueCat.\n'
addition = marker + '\nCurrent verified source version: `1.21.1+28`. Android, web, and unsigned iOS release builds must pass before signing and submission.\n'
if 'Current verified source version: `1.21.1+28`.' not in source:
    if marker not in source:
        raise SystemExit('Missing STORE_RELEASE introduction')
    store.write_text(source.replace(marker, addition, 1), encoding='utf-8')

# The one-time patch machinery must never enter the release tree.
(root / 'tool/v1211_harden.py').unlink(missing_ok=True)
(root / 'tool/v1211_trigger.txt').unlink(missing_ok=True)
