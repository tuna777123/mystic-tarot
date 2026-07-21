import 'dart:math';

import 'package:flutter/material.dart';

import 'models.dart';
import 'theme.dart';

class MysticBackground extends StatefulWidget {
  const MysticBackground({required this.child, super.key});
  final Widget child;

  @override
  State<MysticBackground> createState() => _MysticBackgroundState();
}

class _MysticBackgroundState extends State<MysticBackground> with SingleTickerProviderStateMixin {
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

class _StarlightPainter extends CustomPainter {
  const _StarlightPainter(this.progress);
  final double progress;

  static const stars = <Offset>[
    Offset(.08, .11), Offset(.22, .25), Offset(.46, .08), Offset(.73, .18), Offset(.91, .09),
    Offset(.84, .38), Offset(.13, .53), Offset(.62, .62), Offset(.94, .72), Offset(.35, .84), Offset(.72, .93),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < stars.length; i++) {
      final phase = (progress + i * .13) % 1;
      final opacity = .12 + .42 * (phase < .5 ? phase * 2 : (1 - phase) * 2);
      final point = Offset(stars[i].dx * size.width, stars[i].dy * size.height);
      canvas.drawCircle(point, i % 3 == 0 ? 1.6 : 1, Paint()..color = MysticColors.gold.withValues(alpha: opacity));
    }
  }

  @override
  bool shouldRepaint(covariant _StarlightPainter oldDelegate) => oldDelegate.progress != progress;
}

class GoldButton extends StatelessWidget {
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

class TarotCardFace extends StatelessWidget {
  const TarotCardFace({this.drawn, this.selected = false, this.style = DeckStyle.midnight, this.width = 116, this.height = 184, super.key});
  final DrawnCard? drawn;
  final bool selected;
  final DeckStyle style;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final faceUp = drawn != null;
    final accent = _accent;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: selected ? 1.055 : 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      width: width,
      height: height,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: faceUp ? _faceColors : _backColors),
        border: Border.all(color: selected ? accent : accent.withValues(alpha: .48), width: selected ? 2.5 : 1),
        boxShadow: [BoxShadow(color: selected ? accent.withValues(alpha: .34) : Colors.black38, blurRadius: selected ? 24 : 10)],
      ),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(11), border: Border.all(color: accent.withValues(alpha: .58))),
        child: faceUp ? _face(accent) : Center(child: Text('${style.symbol}\n✦', textAlign: TextAlign.center, style: TextStyle(fontSize: 34, height: 1.15, color: accent))),
      ),
      ),
    );
  }

  Color get _accent {
    switch (style) {
      case DeckStyle.solarGold:
        return const Color(0xFFFFD76A);
      case DeckStyle.bloodMoon:
        return const Color(0xFFFF8090);
      case DeckStyle.midnight:
        return MysticColors.gold;
    }
  }

  List<Color> get _backColors {
    switch (style) {
      case DeckStyle.solarGold:
        return const [Color(0xFF4A3512), Color(0xFF171006)];
      case DeckStyle.bloodMoon:
        return const [Color(0xFF48151F), Color(0xFF160A0D)];
      case DeckStyle.midnight:
        return const [Color(0xFF251B44), Color(0xFF0E0B1A)];
    }
  }

  List<Color> get _faceColors {
    switch (style) {
      case DeckStyle.solarGold:
        return const [Color(0xFF6C4D16), Color(0xFF1A1208)];
      case DeckStyle.bloodMoon:
        return const [Color(0xFF67202C), Color(0xFF1B0A0F)];
      case DeckStyle.midnight:
        return const [Color(0xFF3B2868), Color(0xFF151128)];
    }
  }

  Widget _face(Color accent) {
    final card = drawn!.card;
    final seed = card.name.codeUnits.fold<int>(17, (value, unit) => value * 31 + unit);
    return Padding(padding: const EdgeInsets.fromLTRB(4, 4, 4, 5), child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(card.number, style: TextStyle(fontFamily: 'Arial', color: accent, fontSize: 8, fontWeight: FontWeight.bold)), Text(drawn!.reversed ? 'R' : '✦', style: TextStyle(fontFamily: 'Arial', color: accent.withValues(alpha: .75), fontSize: 7, fontWeight: FontWeight.w900))]),
      const SizedBox(height: 2),
      Expanded(child: Transform.rotate(angle: drawn!.reversed ? pi : 0, child: CustomPaint(painter: _ArcanaArtworkPainter(seed: seed, accent: accent), child: Center(child: Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF120D1D).withValues(alpha: .72), border: Border.all(color: accent.withValues(alpha: .45)), boxShadow: [BoxShadow(color: accent.withValues(alpha: .15), blurRadius: 16)]), child: Text(card.symbol, style: TextStyle(color: accent, fontSize: 27))))))),
      const SizedBox(height: 3),
      Text(card.name.toUpperCase(), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Arial', fontSize: 7.5, height: 1.05, fontWeight: FontWeight.w800, letterSpacing: .55)),
      if (drawn!.reversed) Padding(padding: const EdgeInsets.only(top: 2), child: Text('REVERSED', style: TextStyle(fontFamily: 'Arial', color: accent.withValues(alpha: .82), fontSize: 5.5, fontWeight: FontWeight.w900, letterSpacing: .75))),
    ]));
  }
}

class _ArcanaArtworkPainter extends CustomPainter {
  const _ArcanaArtworkPainter({required this.seed, required this.accent});
  final int seed;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * .38;
    final faint = Paint()..color = accent.withValues(alpha: .12)..style = PaintingStyle.stroke..strokeWidth = .8;
    final line = Paint()..color = accent.withValues(alpha: .34)..style = PaintingStyle.stroke..strokeWidth = .75;
    final glow = Paint()..shader = RadialGradient(colors: [accent.withValues(alpha: .16), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: radius * 1.35));
    canvas.drawCircle(center, radius * 1.35, glow);
    canvas.drawCircle(center, radius, faint);
    canvas.drawCircle(center, radius * .72, faint);
    final rays = 7 + seed.abs() % 6;
    for (var i = 0; i < rays; i++) {
      final angle = (i / rays) * pi * 2 + (seed % 19) * .017;
      final inner = center + Offset(cos(angle), sin(angle)) * radius * .54;
      final outer = center + Offset(cos(angle), sin(angle)) * radius * (i.isEven ? 1.18 : .98);
      canvas.drawLine(inner, outer, faint);
    }
    final points = <Offset>[];
    for (var i = 0; i < 6; i++) {
      final x = ((seed.abs() ~/ (i + 1) + i * 37) % 91) / 100 + .045;
      final y = ((seed.abs() ~/ (i + 3) + i * 53) % 87) / 100 + .065;
      points.add(Offset(x * size.width, y * size.height));
    }
    for (var i = 1; i < points.length; i++) {
      canvas.drawLine(points[i - 1], points[i], line);
    }
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], i.isEven ? 1.6 : 1.05, Paint()..color = accent.withValues(alpha: i.isEven ? .8 : .5));
    }
    final archRect = Rect.fromCenter(center: Offset(center.dx, size.height * .58), width: radius * 1.7, height: radius * 1.9);
    canvas.drawArc(archRect, pi, pi, false, line);
  }

  @override
  bool shouldRepaint(covariant _ArcanaArtworkPainter oldDelegate) => oldDelegate.seed != seed || oldDelegate.accent != accent;
}
