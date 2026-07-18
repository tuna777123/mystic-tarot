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
  const TarotCardFace({this.drawn, this.selected = false, this.width = 116, this.height = 184, super.key});
  final DrawnCard? drawn;
  final bool selected;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final faceUp = drawn != null;
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
        gradient: LinearGradient(colors: faceUp ? [const Color(0xFF3B2868), const Color(0xFF151128)] : [const Color(0xFF251B44), const Color(0xFF0E0B1A)]),
        border: Border.all(color: selected ? MysticColors.gold : MysticColors.lavender.withValues(alpha: .45), width: selected ? 2.5 : 1),
        boxShadow: [BoxShadow(color: selected ? MysticColors.gold.withValues(alpha: .3) : Colors.black38, blurRadius: selected ? 24 : 10)],
      ),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(11), border: Border.all(color: MysticColors.gold.withValues(alpha: .55))),
        child: faceUp ? _face() : const Center(child: Text('☾\n✦', textAlign: TextAlign.center, style: TextStyle(fontSize: 34, height: 1.15, color: MysticColors.gold))),
      ),
      ),
    );
  }

  Widget _face() => Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Text(drawn!.card.number, style: const TextStyle(color: MysticColors.gold, fontSize: 12)),
        Transform.rotate(angle: drawn!.reversed ? 3.14159 : 0, child: Text(drawn!.card.symbol, style: const TextStyle(color: MysticColors.gold, fontSize: 42))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: Text(drawn!.card.name.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Arial', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: .8))),
        if (drawn!.reversed) const Text('REVERSED', style: TextStyle(fontFamily: 'Arial', color: MysticColors.lavender, fontSize: 8, letterSpacing: 1)),
      ]);
}
