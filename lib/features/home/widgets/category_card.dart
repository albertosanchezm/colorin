import 'package:flutter/material.dart';

import '../../../core/models/models.dart';
import 'outlined_text.dart';

Color categoryColor(Category category, Color fallback) {
  final hex = category.colorHex;
  if (hex == null) return fallback;
  return Color(int.parse(hex.replaceFirst('#', ''), radix: 16) | 0xFF000000);
}

/// Picture card for one category on the home carousel: illustration on top,
/// colored name band at the bottom, and a "¡Pronto!" badge when the category
/// has no drawings yet.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.color,
    required this.selected,
    required this.available,
    required this.onTap,
  });

  final Category category;
  final Color color;
  final bool selected;
  final bool available;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final radius = width * 0.11;
        final border = width * 0.03;
        final bandHeight = constraints.maxHeight * 0.2;

        return Semantics(
          button: true,
          selected: selected,
          label: available ? category.name : '${category.name}, próximamente',
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedScale(
              scale: selected ? 1.06 : 1,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: selected ? const Color(0xFFFFD23F) : Colors.white,
                    width: border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: selected ? const Color(0xAAFFD23F) : Colors.black.withAlpha(45),
                      blurRadius: selected ? 18 : 8,
                      spreadRadius: selected ? 2 : 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius - border),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        bottom: bandHeight * 0.6,
                        child: Image.asset(
                          'assets/${category.backgroundAsset}',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => ColoredBox(color: color.withAlpha(90)),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: bandHeight,
                        child: _NameBand(name: category.name, color: color),
                      ),
                      if (!available)
                        Positioned(
                          top: width * 0.05,
                          right: width * 0.05,
                          child: _SoonBadge(size: width),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NameBand extends StatelessWidget {
  const _NameBand({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final dark = HSLColor.fromColor(color).withLightness(
      (HSLColor.fromColor(color).lightness - 0.18).clamp(0.0, 1.0),
    ).toColor();

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final diamond = Transform.rotate(
          angle: 0.785,
          child: Container(width: h * 0.13, height: h * 0.13, color: Colors.white.withAlpha(150)),
        );

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, dark],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: h * 0.18),
            child: Row(
              children: [
                diamond,
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: h * 0.1),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: OutlinedText(
                        spans: [(name, Colors.white)],
                        style: roundedTextStyle(fontSize: h * 0.55),
                        strokeColor: dark,
                        strokeWidth: h * 0.08,
                      ),
                    ),
                  ),
                ),
                diamond,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SoonBadge extends StatelessWidget {
  const _SoonBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size * 0.05, vertical: size * 0.015),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD23F),
        borderRadius: BorderRadius.circular(size),
        border: Border.all(color: Colors.white, width: size * 0.012),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 4)],
      ),
      child: Text(
        '¡Pronto!',
        style: roundedTextStyle(
          fontSize: size * 0.075,
          color: const Color(0xFF8A4B00),
          weight: 600,
        ),
      ),
    );
  }
}
