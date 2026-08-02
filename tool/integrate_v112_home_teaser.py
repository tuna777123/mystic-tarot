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
    "import 'mystic_plus_intelligence_screen.dart';\n",
    "import 'mystic_plus_intelligence_screen.dart';\nimport 'mystic_intelligence_teaser.dart';\n",
)

replace_once(
    "lib/src/app.dart",
    """                _PersonalSignal(
                  intention: intention,
                  records: records,
                  language: language,
                ),
                const SizedBox(height: 14),
                DestinyFlagshipCard(
""",
    """                _PersonalSignal(
                  intention: intention,
                  records: records,
                  language: language,
                ),
                const SizedBox(height: 14),
                MysticIntelligenceTeaser(
                  records: records,
                  language: language,
                  isPlus: isPlus,
                  onOpen: onPremium,
                ),
                const SizedBox(height: 14),
                DestinyFlagshipCard(
""",
)

replace_once(
    "test/v112_revenue_contract_test.dart",
    """    expect(app, contains('MysticPlusIntelligenceScreen('));
    expect(app, contains('isPlus: isPlus'));
""",
    """    expect(app, contains('MysticPlusIntelligenceScreen('));
    expect(app, contains('MysticIntelligenceTeaser('));
    expect(app, contains('onOpen: onPremium'));
    expect(app, contains('isPlus: isPlus'));
""",
)

notes = Path("RELEASE_NOTES.md")
text = notes.read_text(encoding="utf-8")
marker = "- Every Plus entry point now opens the personalized intelligence hub before the official store plans.\n"
addition = "- A personalized home card shows report readiness and a real recurring-symbol preview, making the accumulating value discoverable before a paywall interruption.\n"
if marker not in text:
    raise RuntimeError("Release note insertion marker missing")
if addition not in text:
    text = text.replace(marker, marker + addition, 1)
notes.write_text(text, encoding="utf-8")

Path("tool/integrate_v112_home_teaser.py").unlink(missing_ok=True)
Path(".github/workflows/integrate-v112-home-teaser.yml").unlink(missing_ok=True)
