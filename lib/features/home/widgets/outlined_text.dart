import 'package:flutter/material.dart';

/// Rounded, chunky text style used across the home screen.
TextStyle roundedTextStyle({
  required double fontSize,
  Color color = Colors.white,
  double weight = 700,
}) {
  return TextStyle(
    fontFamily: 'Fredoka',
    fontSize: fontSize,
    color: color,
    fontWeight: FontWeight.values[((weight / 100).round() - 1).clamp(0, 8)],
    fontVariations: [FontVariation('wght', weight)],
    height: 1.1,
  );
}

/// Text painted twice: a thick stroke underneath and the fill on top,
/// giving the sticker-like outline of the home screen titles.
class OutlinedText extends StatelessWidget {
  const OutlinedText({
    super.key,
    required this.spans,
    required this.style,
    required this.strokeColor,
    this.strokeWidth = 6,
    this.textAlign = TextAlign.center,
  });

  /// Pairs of (text, fill color).
  final List<(String, Color)> spans;
  final TextStyle style;
  final Color strokeColor;
  final double strokeWidth;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..color = strokeColor;

    return Stack(
      children: [
        Text.rich(
          TextSpan(
            children: [
              for (final (text, _) in spans)
                TextSpan(text: text, style: style.copyWith(foreground: stroke, color: null)),
            ],
          ),
          textAlign: textAlign,
        ),
        Text.rich(
          TextSpan(
            children: [
              for (final (text, color) in spans)
                TextSpan(text: text, style: style.copyWith(color: color)),
            ],
          ),
          textAlign: textAlign,
        ),
      ],
    );
  }
}
