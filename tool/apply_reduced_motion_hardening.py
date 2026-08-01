from pathlib import Path


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"Expected exactly one match in {path}, found {count}")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


widgets = Path("lib/src/widgets.dart")
replace_once(
    widgets,
    """class _MysticBackgroundState extends State<MysticBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-.72 + .08 * _controller.value, -.86),
              radius: 1.55,
              colors: const [Color(0xFF3B226B), Color(0xFF17112D), MysticColors.ink],
              stops: const [0, .47, 1],
            ),
          ),
          child: Stack(children: [
            Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _StarlightPainter(_controller.value)))),
            SafeArea(child: widget.child),
          ]),
        ),
      );
}
""",
    """class _MysticBackgroundState extends State<MysticBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  );
  bool _animationsDisabled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animationsDisabled =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    _animationsDisabled = animationsDisabled;
    if (animationsDisabled) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _background(double progress) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-.72 + .08 * progress, -.86),
            radius: 1.55,
            colors: const [
              Color(0xFF3B226B),
              Color(0xFF17112D),
              MysticColors.ink,
            ],
            stops: const [0, .47, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _StarlightPainter(progress),
                ),
              ),
            ),
            SafeArea(child: widget.child),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (_animationsDisabled) return _background(0);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => _background(_controller.value),
    );
  }
}
""",
)

Path("test/reduced_motion_test.dart").write_text(
    """import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/widgets.dart';

void main() {
  Widget app({required bool disableAnimations}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: disableAnimations),
          child: const MysticBackground(
            child: Scaffold(body: Text('Mystic')),
          ),
        ),
      );

  testWidgets('Mystic background honors the reduce-motion preference', (
    tester,
  ) async {
    await tester.pumpWidget(app(disableAnimations: true));

    expect(find.byType(AnimatedBuilder), findsNothing);
    expect(find.text('Mystic'), findsOneWidget);

    await tester.pump(const Duration(seconds: 13));
    expect(find.byType(AnimatedBuilder), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Mystic background responds when motion preference changes', (
    tester,
  ) async {
    await tester.pumpWidget(app(disableAnimations: false));
    expect(find.byType(AnimatedBuilder), findsOneWidget);

    await tester.pumpWidget(app(disableAnimations: true));
    await tester.pump();
    expect(find.byType(AnimatedBuilder), findsNothing);

    await tester.pumpWidget(app(disableAnimations: false));
    await tester.pump();
    expect(find.byType(AnimatedBuilder), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
""",
    encoding="utf-8",
)
