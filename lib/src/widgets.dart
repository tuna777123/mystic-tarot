import 'package:flutter/material.dart';

import 'models.dart';
import 'theme.dart';

class MysticBackground extends StatelessWidget {
  const MysticBackground({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment(-.7, -.8), radius: 1.5, colors: [Color(0xFF32205D), MysticColors.ink]),
        ),
        child: Stack(children: [
          const Positioned(top: 70, right: 28, child: Text('✦', style: TextStyle(color: MysticColors.gold, fontSize: 18))),
          const Positioned(top: 135, left: 32, child: Text('·', style: TextStyle(color: MysticColors.lavender, fontSize: 28))),
          SafeArea(child: child),
        ]),
      );
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
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
    );
  }

  Widget _face() => Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Text(drawn!.card.number, style: const TextStyle(color: MysticColors.gold, fontSize: 12)),
        Transform.rotate(angle: drawn!.reversed ? 3.14159 : 0, child: Text(drawn!.card.symbol, style: const TextStyle(color: MysticColors.gold, fontSize: 42))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: Text(drawn!.card.name.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Arial', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: .8))),
        if (drawn!.reversed) const Text('REVERSED', style: TextStyle(fontFamily: 'Arial', color: MysticColors.lavender, fontSize: 8, letterSpacing: 1)),
      ]);
}
