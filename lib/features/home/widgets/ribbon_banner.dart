import 'package:flutter/material.dart';

import 'outlined_text.dart';

/// Ribbon-shaped title banner: a rounded band in [color] with folded,
/// notched tails peeking out on both sides.
class RibbonBanner extends StatelessWidget {
  const RibbonBanner({
    super.key,
    required this.title,
    required this.color,
    required this.width,
    required this.height,
  });

  final String title;
  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(color);
    final dark = hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
    final light = hsl.withLightness((hsl.lightness + 0.08).clamp(0.0, 1.0)).toColor();

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _RibbonPainter(color: color, dark: dark, light: light),
        child: Padding(
          padding: EdgeInsets.fromLTRB(width * 0.2, height * 0.12, width * 0.2, height * 0.3),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: OutlinedText(
                spans: [(title, Colors.white)],
                style: roundedTextStyle(fontSize: height * 0.48),
                strokeColor: dark,
                strokeWidth: height * 0.08,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RibbonPainter extends CustomPainter {
  _RibbonPainter({required this.color, required this.dark, required this.light});

  final Color color;
  final Color dark;
  final Color light;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final shadow = Paint()
      ..color = Colors.black.withAlpha(45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // Tails: notched flags behind the band, slightly lower.
    final tailTop = h * 0.3;
    final tailBottom = h * 0.95;
    final notch = w * 0.04;
    Path tail(double outer, double inner) => Path()
      ..moveTo(inner, tailTop)
      ..lineTo(outer, tailTop)
      ..lineTo(outer + (inner > outer ? notch : -notch), (tailTop + tailBottom) / 2)
      ..lineTo(outer, tailBottom)
      ..lineTo(inner, tailBottom)
      ..close();
    final tailPaint = Paint()..color = dark;
    for (final path in [tail(0, w * 0.2), tail(w, w * 0.8)]) {
      canvas.drawPath(path.shift(const Offset(0, 3)), shadow);
      canvas.drawPath(path, tailPaint);
    }

    // Main band.
    final band = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.1, 0, w * 0.9, h * 0.78),
      Radius.circular(h * 0.22),
    );
    canvas.drawRRect(band.shift(const Offset(0, 4)), shadow);
    canvas.drawRRect(
      band,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [light, color],
        ).createShader(band.outerRect),
    );
    canvas.drawRRect(
      band.deflate(h * 0.04),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.025
        ..color = Colors.white.withAlpha(90),
    );

    // Little diamonds near the ends of the band.
    final diamond = Paint()..color = Colors.white.withAlpha(120);
    for (final x in [w * 0.16, w * 0.84]) {
      final c = Offset(x, h * 0.39);
      final r = h * 0.06;
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy - r)
          ..lineTo(c.dx + r, c.dy)
          ..lineTo(c.dx, c.dy + r)
          ..lineTo(c.dx - r, c.dy)
          ..close(),
        diamond,
      );
    }
  }

  @override
  bool shouldRepaint(_RibbonPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.dark != dark;
}
