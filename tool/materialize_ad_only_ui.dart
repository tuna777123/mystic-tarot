import 'dart:io';

void main() => materializeAdOnlyUi();

/// Removes the final user-visible paid-tier remnants from historical source
/// before every verified build. The migration is deterministic, idempotent and
/// fails closed if a known source anchor disappears unexpectedly.
void materializeAdOnlyUi() {
  final app = File('lib/src/app.dart');
  final intelligence = File('lib/src/mystic_plus_intelligence_screen.dart');
  if (!app.existsSync() || !intelligence.existsSync()) {
    throw StateError('Mystic Tarot UI source files are missing.');
  }

  var appSource = app.readAsStringSync();
  appSource = _replaceRequired(
    appSource,
    '''                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: MysticColors.gold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'PLUS',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            color: MysticColors.ink,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .7,
                          ),
                        ),
                      ),''',
    '''                      const Icon(
                        Icons.lock_open_rounded,
                        color: MysticColors.gold,
                        size: 18,
                      ),''',
    'deep-reading paid badge',
  );
  appSource = appSource.replaceAll("'PLUS'", "'OPEN'");
  appSource = _replaceRequired(
    appSource,
    "'\${kind.cardCount}-card premium spread'",
    "'\${kind.cardCount}-card deep spread'",
    'English premium-spread copy',
  );
  appSource = _replaceRequired(
    appSource,
    "'\${kind.cardCount} kartlık premium açılım'",
    "'\${kind.cardCount} kartlık derin açılım'",
    'Turkish premium-spread copy',
  );
  appSource = _replaceRequired(
    appSource,
    "mysticText(language, 'PLUS ACTIVE', 'PLUS ETKİN')",
    "mysticText(language, 'ALL OPEN', 'HEPSİ AÇIK')",
    'active paid-tier label',
  );
  appSource = _replaceRequired(
    appSource,
    "mysticText(language, 'VIEW PLUS', 'PLUS’I GÖR')",
    "mysticText(language, 'ALL OPEN', 'HEPSİ AÇIK')",
    'paid-tier action label',
  );
  appSource = _replaceRequired(
    appSource,
    "'Free deep readings used'",
    "'Deep readings stay open'",
    'English exhausted-reading copy',
  );
  appSource = _replaceRequired(
    appSource,
    "'Ücretsiz derin okumalar kullanıldı'",
    "'Derin okumalar açık kalır'",
    'Turkish exhausted-reading copy',
  );
  _rejectLegacyUserCopy(appSource, 'lib/src/app.dart');
  app.writeAsStringSync(appSource);

  var intelligenceSource = intelligence.readAsStringSync();
  intelligenceSource = _replaceRequired(
    intelligenceSource,
    '''        const Spacer(),
        const Text(
          'MYSTIC INTELLIGENCE',
          style: TextStyle(
            color: MysticColors.gold,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
          ),
        ),
        const Spacer(),''',
    '''        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: const Text(
              'MYSTIC INTELLIGENCE',
              style: TextStyle(
                color: MysticColors.gold,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),''',
    'responsive Intelligence header',
  );
  intelligenceSource = _replaceRequired(
    intelligenceSource,
    'Preview the intelligence layer that connects premium spreads across time.',
    'Explore the intelligence layer that connects deep spreads across time.',
    'English Intelligence paid-tier copy',
  );
  intelligenceSource = _replaceRequired(
    intelligenceSource,
    'Previsualiza la capa de inteligencia que conecta las tiradas premium con el tiempo.',
    'Explora la capa de inteligencia que conecta las tiradas profundas con el tiempo.',
    'Spanish Intelligence paid-tier copy',
  );
  intelligenceSource = _replaceRequired(
    intelligenceSource,
    'Découvrez la couche d’intelligence qui relie les tirages premium dans le temps.',
    'Découvrez la couche d’intelligence qui relie les tirages approfondis dans le temps.',
    'French Intelligence paid-tier copy',
  );
  intelligenceSource = _replaceRequired(
    intelligenceSource,
    'Veja a camada de inteligência que conecta tiragens premium ao longo do tempo.',
    'Veja a camada de inteligência que conecta tiragens profundas ao longo do tempo.',
    'Portuguese Intelligence paid-tier copy',
  );
  intelligenceSource = _replaceRequired(
    intelligenceSource,
    'Premium açılımları zaman içinde birbirine bağlayan intelligence katmanını önizle.',
    'Derin açılımları zaman içinde birbirine bağlayan intelligence katmanını keşfet.',
    'Turkish Intelligence paid-tier copy',
  );
  _rejectLegacyUserCopy(
    intelligenceSource,
    'lib/src/mystic_plus_intelligence_screen.dart',
  );
  intelligence.writeAsStringSync(intelligenceSource);

  stdout.writeln(
    'Advertising-only UI materialized: paid-tier user copy removed and narrow-screen header hardened.',
  );
}

String _replaceRequired(
  String source,
  String oldValue,
  String newValue,
  String label,
) {
  if (source.contains(oldValue)) {
    return source.replaceAll(oldValue, newValue);
  }
  if (source.contains(newValue)) return source;
  throw StateError(
    'Unable to materialize $label: expected source anchor missing.',
  );
}

void _rejectLegacyUserCopy(String source, String path) {
  const forbidden = <String>[
    "'PLUS'",
    'PLUS ACTIVE',
    'PLUS ETKİN',
    'VIEW PLUS',
    'PLUS’I GÖR',
    'premium spread',
    'premium açılım',
    'tiradas premium',
    'tirages premium',
    'tiragens premium',
    'Mystic Plus',
    'Manage subscription',
    'View plan and manage subscription',
  ];
  for (final token in forbidden) {
    if (source.toLowerCase().contains(token.toLowerCase())) {
      throw StateError('Legacy paid-tier user copy remains in $path: $token');
    }
  }
}
