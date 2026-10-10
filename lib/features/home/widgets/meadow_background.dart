import 'dart:math';

import 'package:flutter/material.dart';

/// Sky with clouds over rolling green hills, drawn in code so it scales to
/// any screen without shipping a large background image.
class MeadowBackground extends StatelessWidget {
  const MeadowBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MeadowPainter(),
      child: child,
    );
  }
}

class _MeadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3E9BF0), Color(0xFF8CCBFA), Color(0xFFCDEBFF)],
          stops: [0, 0.35, 0.55],
        ).createShader(Offset.zero & size),
    );

    // Clouds.
    final cloud = Paint()..color = Colors.white.withAlpha(235);
    final cloudShade = Paint()..color = const Color(0xFFDDEFFF);
    void drawCloud(double cx, double cy, double s) {
      for (final (dx, dy, r) in const [
        (-1.2, 0.25, 0.45),
        (-0.55, -0.1, 0.62),
        (0.15, -0.3, 0.75),
        (0.85, 0.0, 0.58),
        (1.35, 0.3, 0.4),
      ]) {
        canvas.drawCircle(Offset(cx + dx * s, cy + dy * s + s * 0.08), r * s, cloudShade);
      }
      for (final (dx, dy, r) in const [
        (-1.2, 0.25, 0.45),
        (-0.55, -0.1, 0.62),
        (0.15, -0.3, 0.75),
        (0.85, 0.0, 0.58),
        (1.35, 0.3, 0.4),
      ]) {
        canvas.drawCircle(Offset(cx + dx * s, cy + dy * s), r * s, cloud);
      }
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(cx - 1.6 * s, cy + 0.1 * s, cx + 1.75 * s, cy + 0.7 * s),
          Radius.circular(0.3 * s),
        ),
        cloud,
      );
    }

    drawCloud(w * 0.08, h * 0.07, h * 0.06);
    drawCloud(w * 0.9, h * 0.18, h * 0.07);
    drawCloud(w * 0.27, h * 0.27, h * 0.045);
    drawCloud(w * 0.62, h * 0.26, h * 0.04);
    drawCloud(w * 0.97, h * 0.06, h * 0.05);
    drawCloud(w * 0.02, h * 0.3, h * 0.05);

    // Distant hills.
    final farHills = Path()
      ..moveTo(0, h * 0.42)
      ..cubicTo(w * 0.15, h * 0.33, w * 0.3, h * 0.36, w * 0.42, h * 0.4)
      ..cubicTo(w * 0.55, h * 0.44, w * 0.7, h * 0.32, w * 0.85, h * 0.36)
      ..cubicTo(w * 0.93, h * 0.38, w * 0.97, h * 0.37, w, h * 0.35)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(farHills, Paint()..color = const Color(0xFF7CC95A));

    // Meadow.
    final meadow = Path()
      ..moveTo(0, h * 0.5)
      ..cubicTo(w * 0.2, h * 0.43, w * 0.4, h * 0.5, w * 0.55, h * 0.47)
      ..cubicTo(w * 0.72, h * 0.44, w * 0.85, h * 0.5, w, h * 0.46)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      meadow,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA6DD5B), Color(0xFF6CC046), Color(0xFF3F9A35)],
        ).createShader(Rect.fromLTRB(0, h * 0.45, w, h)),
    );

    // Flowers scattered on the lower meadow (fixed seed: same every frame).
    final random = Random(7);
    const petalColors = [Color(0xFFFFF3B0), Color(0xFFFFFFFF), Color(0xFFFFB3C7)];
    for (var i = 0; i < 28; i++) {
      final x = random.nextDouble() * w;
      final y = h * (0.62 + random.nextDouble() * 0.36);
      final r = h * (0.006 + random.nextDouble() * 0.006);
      final petal = Paint()..color = petalColors[i % petalColors.length];
      for (var p = 0; p < 5; p++) {
        final a = p * 2 * pi / 5;
        canvas.drawCircle(Offset(x + cos(a) * r, y + sin(a) * r * 0.7), r * 0.75, petal);
      }
      canvas.drawCircle(Offset(x, y), r * 0.55, Paint()..color = const Color(0xFFFFC233));
    }
  }

  @override
  bool shouldRepaint(_MeadowPainter oldDelegate) => false;
}
