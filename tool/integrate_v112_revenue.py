from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    file = Path(path)
    text = file.read_text(encoding="utf-8")
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f"Expected exactly one match in {path}, found {count}")
    file.write_text(text.replace(old, new, 1), encoding="utf-8")


replace_once(
    "lib/src/app.dart",
    "import 'premium_value_screen.dart';\n",
    "import 'mystic_plus_intelligence_screen.dart';\n",
)

replace_once(
    "lib/src/app.dart",
    """  void _showPremium({String source = 'organic'}) {
    final storeScreen = StoreReadyPremiumScreen(
      source: source,
      language: language,
      subscriptionStore: subscriptionStore,
    );
    if (isPlus) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (_) => storeScreen),
      );
      return;
    }
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (_) => PremiumValueScreen(
          source: source,
          language: language,
          onContinue: () => navigatorKey.currentState!.push(
            MaterialPageRoute(builder: (_) => storeScreen),
          ),
        ),
      ),
    );
  }
""",
    """  void _showPremium({String source = 'organic'}) {
    final storeScreen = StoreReadyPremiumScreen(
      source: source,
      language: language,
      subscriptionStore: subscriptionStore,
    );
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (_) => MysticPlusIntelligenceScreen(
          source: source,
          language: language,
          isPlus: isPlus,
          onContinue: () => navigatorKey.currentState!.push(
            MaterialPageRoute(builder: (_) => storeScreen),
          ),
        ),
      ),
    );
  }
""",
)

replace_once(
    "lib/src/store_ready_premium_screen.dart",
    """        child: Column(
          children: [
            _benefit(
              Icons.all_inclusive,
""",
    """        child: Column(
          children: [
            _benefit(
              Icons.insights_outlined,
              t(
                en: 'A fresh private intelligence report every seven days',
                es: 'Un nuevo informe privado de inteligencia cada siete días',
                fr: 'Un nouveau rapport privé d’intelligence tous les sept jours',
                pt: 'Um novo relatório privado de inteligência a cada sete dias',
                tr: 'Her yedi günde yenilenen özel intelligence raporu',
                it: 'Un nuovo report privato ogni sette giorni',
                de: 'Ein neuer privater Intelligence-Bericht alle sieben Tage',
              ),
            ),
            _benefit(
              Icons.all_inclusive,
""",
)

replace_once(
    "pubspec.yaml",
    "version: 1.11.0+17",
    "version: 1.12.0+18",
)

release_notes = Path("RELEASE_NOTES.md")
current_notes = release_notes.read_text(encoding="utf-8")
heading = "# Mystic Tarot 1.12.0 — Revenue Intelligence\n"
if heading not in current_notes:
    release_notes.write_text(
        """# Mystic Tarot 1.12.0 — Revenue Intelligence

Mystic Plus now sells an accumulating personal outcome instead of only removing limits.

## New premium value

- A private seven-day Mystic Intelligence report calculated entirely on the device.
- Free users receive a personalized preview built from their own saved readings before seeing plans.
- Plus members unlock recurring-card evidence, dominant reading focus, Mirror completion and shift rates, emotional direction, and a transparent next-practice prompt.
- The report becomes meaningful after three saved readings and refreshes from the latest seven-day window.
- All insight copy is descriptive and explicitly avoids prediction, diagnosis, or certainty claims.

## Conversion and trust

- Every Plus entry point now opens the personalized intelligence hub before the official store plans.
- Existing members can revisit their full report from the Plus entry point and then manage the verified subscription.
- The official checkout still uses localized App Store or Google Play prices and trusted RevenueCat entitlement verification.
- The report reads only the versioned local Journal and Mystic Mirror stores; no private journal text is uploaded.

## Launch languages

English, Turkish, neutral international Spanish, French, and Brazilian Portuguese ship with the complete report and purchase journey.

---

"""
        + current_notes,
        encoding="utf-8",
    )

replace_once(
    "STORE_RELEASE.md",
    "- Mystic Plus unlocks unlimited deep readings, premium spreads, and unlimited Oracle Dialogue follow-ups.",
    "- Mystic Plus unlocks a private seven-day intelligence report, unlimited deep readings, premium spreads, and unlimited Oracle Dialogue follow-ups.",
)

for listing in [
    "docs/STORE_LISTING_TR.md",
    "docs/STORE_LISTING_ES.md",
    "docs/STORE_LISTING_FR.md",
    "docs/STORE_LISTING_PT_BR.md",
]:
    path = Path(listing)
    text = path.read_text(encoding="utf-8")
    text = text.replace("1.11.0", "1.12.0")
    markers = {
        "docs/STORE_LISTING_TR.md": "## Sürüm notları — 1.12.0\n\n",
        "docs/STORE_LISTING_ES.md": "## Notas de la versión — 1.12.0\n\n",
        "docs/STORE_LISTING_FR.md": "## Notes de version — 1.12.0\n\n",
        "docs/STORE_LISTING_PT_BR.md": "## Notas da versão — 1.12.0\n\n",
    }
    bullets = {
        "docs/STORE_LISTING_TR.md": "- Cihazda hesaplanan kişisel 7 günlük Mystic Intelligence raporu\n",
        "docs/STORE_LISTING_ES.md": "- Informe personal Mystic Intelligence de 7 días calculado en el dispositivo\n",
        "docs/STORE_LISTING_FR.md": "- Rapport personnel Mystic Intelligence sur 7 jours calculé sur l’appareil\n",
        "docs/STORE_LISTING_PT_BR.md": "- Relatório pessoal Mystic Intelligence de 7 dias calculado no dispositivo\n",
    }
    marker = markers[listing]
    if marker not in text:
        raise RuntimeError(f"Release marker missing in {listing}")
    if bullets[listing] not in text:
        text = text.replace(marker, marker + bullets[listing], 1)
    path.write_text(text, encoding="utf-8")

# Keep the integration mechanism out of the release diff.
Path("tool/integrate_v112_revenue.py").unlink(missing_ok=True)
Path(".github/workflows/integrate-v112-revenue.yml").unlink(missing_ok=True)
