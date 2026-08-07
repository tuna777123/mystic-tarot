import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

class StoreTarotSigil extends StatelessWidget {
  const StoreTarotSigil({
    required this.symbol,
    required this.size,
    super.key,
  });

  final String symbol;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: _StoreTarotSigilPainter(symbol),
    ),
  );
}

class _StoreTarotSigilPainter extends CustomPainter {
  const _StoreTarotSigilPainter(this.symbol);

  final String symbol;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final scale = size.shortestSide;
    final stroke = Paint()
      ..color = MysticColors.gold
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = math.max(1.6, scale * 0.055);

    switch (symbol) {
      case '✶':
      case '✦':
        _drawStar(canvas, center, scale, stroke);
      case '☽':
        _drawCrescent(canvas, center, scale, stroke, opensRight: true);
      case '☾':
        _drawCrescent(canvas, center, scale, stroke, opensRight: false);
      case '♌':
        _drawLeo(canvas, center, scale, stroke);
      case '➶':
        _drawArrow(canvas, center, scale, stroke);
      case '◎':
      case '◉':
        _drawOrbit(canvas, center, scale, stroke);
      default:
        _drawDeterministicMark(canvas, center, scale, stroke, symbol);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double scale, Paint paint) {
    final outer = scale * 0.39;
    final inner = scale * 0.14;
    final path = Path();
    for (var index = 0; index < 16; index++) {
      final radius = index.isEven ? outer : inner;
      final angle = -math.pi / 2 + index * math.pi / 8;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
    canvas.drawCircle(center, scale * 0.055, paint);
  }

  void _drawCrescent(
    Canvas canvas,
    Offset center,
    double scale,
    Paint paint, {
    required bool opensRight,
  }) {
    final radius = scale * 0.34;
    final direction = opensRight ? 1.0 : -1.0;
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..cubicTo(
        center.dx - direction * radius * 0.88,
        center.dy - radius * 0.72,
        center.dx - direction * radius * 0.88,
        center.dy + radius * 0.72,
        center.dx,
        center.dy + radius,
      )
      ..cubicTo(
        center.dx - direction * radius * 0.30,
        center.dy + radius * 0.48,
        center.dx - direction * radius * 0.30,
        center.dy - radius * 0.48,
        center.dx,
        center.dy - radius,
      );
    canvas.drawPath(path, paint);
  }

  void _drawLeo(Canvas canvas, Offset center, double scale, Paint paint) {
    final loopRadius = scale * 0.17;
    final loopCenter = Offset(center.dx - scale * 0.13, center.dy - scale * 0.07);
    canvas.drawCircle(loopCenter, loopRadius, paint);
    final path = Path()
      ..moveTo(loopCenter.dx + loopRadius * 0.75, loopCenter.dy + loopRadius * 0.65)
      ..cubicTo(
        center.dx + scale * 0.18,
        center.dy - scale * 0.02,
        center.dx + scale * 0.13,
        center.dy + scale * 0.25,
        center.dx + scale * 0.30,
        center.dy + scale * 0.27,
      )
      ..cubicTo(
        center.dx + scale * 0.39,
        center.dy + scale * 0.28,
        center.dx + scale * 0.40,
        center.dy + scale * 0.17,
        center.dx + scale * 0.34,
        center.dy + scale * 0.12,
      );
    canvas.drawPath(path, paint);
  }

  void _drawArrow(Canvas canvas, Offset center, double scale, Paint paint) {
    final start = Offset(center.dx - scale * 0.34, center.dy + scale * 0.24);
    final end = Offset(center.dx + scale * 0.31, center.dy - scale * 0.28);
    canvas.drawLine(start, end, paint);
    canvas.drawLine(
      end,
      Offset(end.dx - scale * 0.19, end.dy + scale * 0.02),
      paint,
    );
    canvas.drawLine(
      end,
      Offset(end.dx - scale * 0.03, end.dy + scale * 0.19),
      paint,
    );
    final feather = Offset(center.dx - scale * 0.16, center.dy + scale * 0.10);
    canvas.drawLine(
      feather,
      Offset(feather.dx - scale * 0.19, feather.dy - scale * 0.03),
      paint,
    );
    canvas.drawLine(
      feather,
      Offset(feather.dx - scale * 0.04, feather.dy + scale * 0.18),
      paint,
    );
  }

  void _drawOrbit(Canvas canvas, Offset center, double scale, Paint paint) {
    canvas.drawCircle(center, scale * 0.34, paint);
    canvas.drawCircle(center, scale * 0.14, paint);
    canvas.drawCircle(center, scale * 0.035, paint);
  }

  void _drawDeterministicMark(
    Canvas canvas,
    Offset center,
    double scale,
    Paint paint,
    String value,
  ) {
    final codePoint = value.runes.isEmpty ? 0 : value.runes.first;
    final radius = scale * 0.31;
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + radius, center.dy)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - radius, center.dy)
      ..close();
    canvas.drawPath(path, paint);

    final angle = (codePoint % 360) * math.pi / 180;
    canvas.drawLine(
      center,
      Offset(
        center.dx + math.cos(angle) * radius * 0.82,
        center.dy + math.sin(angle) * radius * 0.82,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _StoreTarotSigilPainter oldDelegate) =>
      oldDelegate.symbol != symbol;
}
