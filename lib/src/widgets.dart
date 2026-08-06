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

class _MysticBackgroundState extends State<MysticBackground>
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
        colors: const [Color(0xFF3B226B), Color(0xFF17112D), MysticColors.ink],
        stops: const [0, .47, 1],
      ),
    ),
    child: Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _StarlightPainter(progress)),
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

class _StarlightPainter extends CustomPainter {
  const _StarlightPainter(this.progress);
  final double progress;

  static const stars = <Offset>[
    Offset(.08, .11),
    Offset(.22, .25),
    Offset(.46, .08),
    Offset(.73, .18),
    Offset(.91, .09),
    Offset(.84, .38),
    Offset(.13, .53),
    Offset(.62, .62),
    Offset(.94, .72),
    Offset(.35, .84),
    Offset(.72, .93),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < stars.length; i++) {
      final phase = (progress + i * .13) % 1;
      final opacity = .12 + .42 * (phase < .5 ? phase * 2 : (1 - phase) * 2);
      final point = Offset(stars[i].dx * size.width, stars[i].dy * size.height);
      canvas.drawCircle(
        point,
        i % 3 == 0 ? 1.6 : 1,
        Paint()..color = MysticColors.gold.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarlightPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class GoldButton extends StatelessWidget {
  const GoldButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });
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
            icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
            label: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            style: FilledButton.styleFrom(
              foregroundColor: MysticColors.ink,
              backgroundColor: MysticColors.gold,
              disabledBackgroundColor: MysticColors.gold.withValues(alpha: .25),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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

class TarotCardFace extends StatelessWidget {
  const TarotCardFace({
    this.drawn,
    this.displayName,
    this.reversedLabel = 'REVERSED',
    this.selected = false,
    this.style = DeckStyle.midnight,
    this.width = 116,
    this.height = 184,
    super.key,
  });
  final DrawnCard? drawn;
  final String? displayName;
  final String reversedLabel;
  final bool selected;
  final DeckStyle style;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final faceUp = drawn != null;
    final accent = _accent;
    final animationsDisabled =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = animationsDisabled
        ? Duration.zero
        : const Duration(milliseconds: 320);
    final card = AnimatedContainer(
      duration: duration,
      width: width,
      height: height,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: faceUp ? _faceColors : _backColors),
        border: Border.all(
          color: selected ? accent : accent.withValues(alpha: .48),
          width: selected ? 2.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: selected ? accent.withValues(alpha: .34) : Colors.black38,
            blurRadius: selected ? 24 : 10,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: accent.withValues(alpha: .58)),
        ),
        child: faceUp
            ? _face(accent)
            : Center(
                child: Text(
                  '${style.symbol}\n✦',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 34, height: 1.15, color: accent),
                ),
              ),
      ),
    );
    if (animationsDisabled) return card;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: selected ? 1.055 : 1),
      duration: duration,
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: card,
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
    final seed = card.name.codeUnits.fold<int>(
      17,
      (value, unit) => value * 31 + unit,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                card.number,
                style: TextStyle(
                  fontFamily: 'Arial',
                  color: accent,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                drawn!.reversed ? 'R' : '✦',
                style: TextStyle(
                  fontFamily: 'Arial',
                  color: accent.withValues(alpha: .75),
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Transform.rotate(
              angle: drawn!.reversed ? pi : 0,
              child: CustomPaint(
                painter: _ArcanaArtworkPainter(
                  seed: seed,
                  accent: accent,
                  cardName: card.name,
                ),
                child: Center(
                  child: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF120D1D).withValues(alpha: .62),
                      border: Border.all(color: accent.withValues(alpha: .36)),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: .16),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    child: Text(
                      card.symbol,
                      style: TextStyle(color: accent, fontSize: 21),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            displayName ?? card.name.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: width >= 100 ? 9 : 7.5,
              height: 1.05,
              fontWeight: FontWeight.w800,
              letterSpacing: .42,
            ),
          ),
          if (drawn!.reversed)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                reversedLabel.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Arial',
                  color: accent.withValues(alpha: .88),
                  fontSize: width >= 100 ? 6.8 : 5.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .65,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ArcanaArtworkPainter extends CustomPainter {
  const _ArcanaArtworkPainter({
    required this.seed,
    required this.accent,
    required this.cardName,
  });
  final int seed;
  final Color accent;
  final String cardName;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * .38;
    final faint = Paint()
      ..color = accent.withValues(alpha: .12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8;
    final line = Paint()
      ..color = accent.withValues(alpha: .34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .75;
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [accent.withValues(alpha: .16), Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.35));
    canvas.drawCircle(center, radius * 1.35, glow);
    canvas.drawCircle(center, radius, faint);
    canvas.drawCircle(center, radius * .72, faint);
    final rays = 7 + seed.abs() % 6;
    for (var i = 0; i < rays; i++) {
      final angle = (i / rays) * pi * 2 + (seed % 19) * .017;
      final inner = center + Offset(cos(angle), sin(angle)) * radius * .54;
      final outer =
          center +
          Offset(cos(angle), sin(angle)) * radius * (i.isEven ? 1.18 : .98);
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
      canvas.drawCircle(
        points[i],
        i.isEven ? 1.6 : 1.05,
        Paint()..color = accent.withValues(alpha: i.isEven ? .8 : .5),
      );
    }
    final archRect = Rect.fromCenter(
      center: Offset(center.dx, size.height * .58),
      width: radius * 1.7,
      height: radius * 1.9,
    );
    canvas.drawArc(archRect, pi, pi, false, line);
    _drawCardMotif(canvas, size, center, radius);
  }

  void _drawCardMotif(Canvas canvas, Size size, Offset center, double radius) {
    final name = cardName.toLowerCase();
    final strong = Paint()
      ..color = accent.withValues(alpha: .62)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..strokeCap = StrokeCap.round;
    final softFill = Paint()
      ..color = accent.withValues(alpha: .12)
      ..style = PaintingStyle.fill;
    final upper = Offset(center.dx, size.height * .34);
    final lower = Offset(center.dx, size.height * .68);

    if (name.contains('sun')) {
      canvas.drawCircle(upper, radius * .28, softFill);
      canvas.drawCircle(upper, radius * .22, strong);
      for (var i = 0; i < 12; i++) {
        final angle = i * pi / 6;
        canvas.drawLine(
          upper + Offset(cos(angle), sin(angle)) * radius * .31,
          upper + Offset(cos(angle), sin(angle)) * radius * .45,
          strong,
        );
      }
      _drawHorizon(canvas, size, lower, strong);
      return;
    }
    if (name.contains('moon')) {
      canvas.drawCircle(upper, radius * .3, softFill);
      canvas.drawArc(
        Rect.fromCircle(center: upper, radius: radius * .27),
        -.9,
        pi * 1.55,
        false,
        strong,
      );
      canvas.drawLine(
        Offset(size.width * .28, lower.dy),
        Offset(size.width * .28, lower.dy - radius * .38),
        strong,
      );
      canvas.drawLine(
        Offset(size.width * .72, lower.dy),
        Offset(size.width * .72, lower.dy - radius * .38),
        strong,
      );
      _drawHorizon(canvas, size, lower, strong);
      return;
    }
    if (name.contains('star')) {
      _drawStar(canvas, upper, radius * .38, strong, softFill);
      _drawHorizon(canvas, size, lower, strong);
      return;
    }
    if (name.contains('tower')) {
      final tower = Rect.fromCenter(
        center: lower,
        width: radius * .66,
        height: radius * 1.15,
      );
      canvas.drawRect(tower, softFill);
      canvas.drawRect(tower, strong);
      final bolt = Path()
        ..moveTo(size.width * .65, size.height * .22)
        ..lineTo(size.width * .49, size.height * .42)
        ..lineTo(size.width * .6, size.height * .42)
        ..lineTo(size.width * .43, size.height * .61);
      canvas.drawPath(bolt, strong);
      return;
    }
    if (name.contains('lovers')) {
      canvas.drawCircle(
        Offset(center.dx - radius * .32, upper.dy),
        radius * .16,
        strong,
      );
      canvas.drawCircle(
        Offset(center.dx + radius * .32, upper.dy),
        radius * .16,
        strong,
      );
      canvas.drawArc(
        Rect.fromCenter(
          center: lower,
          width: radius * 1.25,
          height: radius * 1.1,
        ),
        pi,
        pi,
        false,
        strong,
      );
      return;
    }
    if (name.contains('world')) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radius * 1.15,
          height: radius * 1.65,
        ),
        strong,
      );
      _drawStar(canvas, center, radius * .24, strong, softFill);
      return;
    }
    if (name.contains('wands')) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(-.22);
      canvas.drawLine(
        Offset(0, -radius * .75),
        Offset(0, radius * .75),
        strong,
      );
      canvas.drawCircle(Offset.zero, radius * .18, softFill);
      canvas.restore();
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(center.dx, size.height * .28),
          width: radius * .4,
          height: radius * .55,
        ),
        .15,
        pi * 1.4,
        false,
        strong,
      );
      return;
    }
    if (name.contains('cups')) {
      final cup = Path()
        ..moveTo(center.dx - radius * .43, upper.dy)
        ..quadraticBezierTo(
          center.dx - radius * .34,
          center.dy,
          center.dx,
          center.dy + radius * .08,
        )
        ..quadraticBezierTo(
          center.dx + radius * .34,
          center.dy,
          center.dx + radius * .43,
          upper.dy,
        );
      canvas.drawPath(cup, strong);
      canvas.drawLine(
        Offset(center.dx, center.dy + radius * .08),
        Offset(center.dx, lower.dy),
        strong,
      );
      canvas.drawLine(
        Offset(center.dx - radius * .27, lower.dy),
        Offset(center.dx + radius * .27, lower.dy),
        strong,
      );
      return;
    }
    if (name.contains('swords')) {
      canvas.drawLine(
        Offset(center.dx, size.height * .24),
        Offset(center.dx, size.height * .75),
        strong,
      );
      canvas.drawLine(
        Offset(center.dx - radius * .32, size.height * .63),
        Offset(center.dx + radius * .32, size.height * .63),
        strong,
      );
      final tip = Path()
        ..moveTo(center.dx, size.height * .18)
        ..lineTo(center.dx - radius * .09, size.height * .29)
        ..lineTo(center.dx + radius * .09, size.height * .29)
        ..close();
      canvas.drawPath(tip, softFill);
      canvas.drawPath(tip, strong);
      return;
    }
    if (name.contains('pentacles')) {
      canvas.drawCircle(center, radius * .48, softFill);
      canvas.drawCircle(center, radius * .48, strong);
      _drawStar(
        canvas,
        center,
        radius * .4,
        strong,
        Paint()..color = Colors.transparent,
      );
      return;
    }

    _drawStar(canvas, upper, radius * .28, strong, softFill);
    final path = Path()
      ..moveTo(size.width * .27, lower.dy)
      ..quadraticBezierTo(
        center.dx,
        lower.dy - radius * .38,
        size.width * .73,
        lower.dy,
      );
    canvas.drawPath(path, strong);
  }

  void _drawHorizon(Canvas canvas, Size size, Offset center, Paint paint) {
    final path = Path()
      ..moveTo(size.width * .18, center.dy)
      ..quadraticBezierTo(
        size.width * .36,
        center.dy - 9,
        size.width * .5,
        center.dy,
      )
      ..quadraticBezierTo(
        size.width * .66,
        center.dy + 9,
        size.width * .82,
        center.dy,
      );
    canvas.drawPath(path, paint);
  }

  void _drawStar(
    Canvas canvas,
    Offset center,
    double radius,
    Paint line,
    Paint fill,
  ) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final pointRadius = i.isEven ? radius : radius * .42;
      final angle = -pi / 2 + i * pi / 5;
      final point = center + Offset(cos(angle), sin(angle)) * pointRadius;
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _ArcanaArtworkPainter oldDelegate) =>
      oldDelegate.seed != seed ||
      oldDelegate.accent != accent ||
      oldDelegate.cardName != cardName;
}
