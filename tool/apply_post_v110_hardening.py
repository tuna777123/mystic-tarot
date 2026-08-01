from pathlib import Path


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"Expected exactly one match in {path}, found {count}")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


app = Path("lib/src/app.dart")
replace_once(
    app,
    "import 'dart:convert';\n",
    "import 'dart:async';\nimport 'dart:convert';\n",
)
replace_once(
    app,
    """class _PremiumReadingPreviewState extends State<PremiumReadingPreview> {
  bool revealed = false;
  late final DrawnCard previewCard;

  @override
  void initState() {
    super.initState();
    final seed = DateTime.now().day + widget.kind.index * 13;
    previewCard = DrawnCard(tarotDeck[seed % tarotDeck.length], seed.isOdd);
    Future<void>.delayed(const Duration(milliseconds: 850), () {
      if (mounted) setState(() => revealed = true);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
""",
    """class _PremiumReadingPreviewState extends State<PremiumReadingPreview> {
  bool revealed = false;
  late final DrawnCard previewCard;
  Timer? _revealTimer;

  @override
  void initState() {
    super.initState();
    final seed = DateTime.now().day + widget.kind.index * 13;
    previewCard = DrawnCard(tarotDeck[seed % tarotDeck.length], seed.isOdd);
    _revealTimer = Timer(const Duration(milliseconds: 850), () {
      if (mounted) setState(() => revealed = true);
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
""",
)

widgets = Path("lib/src/widgets.dart")
replace_once(
    widgets,
    """class GoldButton extends StatelessWidget {
  const GoldButton({required this.label, required this.onPressed, this.icon, super.key});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
          label: Text(label),
          style: FilledButton.styleFrom(
            foregroundColor: MysticColors.ink,
            backgroundColor: MysticColors.gold,
            disabledBackgroundColor: MysticColors.gold.withValues(alpha: .25),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
      );
}
""",
    """class GoldButton extends StatelessWidget {
  const GoldButton({required this.label, required this.onPressed, this.icon, super.key});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        enabled: onPressed != null,
        label: label,
        onTap: onPressed,
        child: ExcludeSemantics(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onPressed,
                icon: icon == null
                    ? const SizedBox.shrink()
                    : Icon(icon, size: 18),
                label: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                style: FilledButton.styleFrom(
                  foregroundColor: MysticColors.ink,
                  backgroundColor: MysticColors.gold,
                  disabledBackgroundColor:
                      MysticColors.gold.withValues(alpha: .25),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
""",
)

Path("test/post_v110_hardening_test.dart").write_text(
    """import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/app.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/widgets.dart';

void main() {
  testWidgets('premium preview cancels its reveal timer when dismissed', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PremiumReadingPreview(
          kind: ReadingKind.compatibility,
          deckStyle: DeckStyle.midnight,
          language: MysticLanguage.english,
          onUnlock: () {},
        ),
      ),
    );
    await tester.pump();

    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('gold action supports long localized labels on narrow phones', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);

    const label =
        'Débloquer la lecture complète de compatibilité amoureuse';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: GoldButton(
              label: label,
              icon: Icons.auto_awesome,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel(label), findsOneWidget);
    expect(find.text(label), findsOneWidget);
    expect(tester.getSize(find.byType(GoldButton)).height, greaterThanOrEqualTo(56));
    expect(tester.takeException(), isNull);
  });
}
""",
    encoding="utf-8",
)
