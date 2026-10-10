import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/theme.dart';
import '../../home/widgets/category_card.dart';
import '../../home/widgets/chunky_button.dart';
import '../../home/widgets/meadow_background.dart';
import '../../home/widgets/outlined_text.dart';
import '../../home/widgets/ribbon_banner.dart';
import '../../home/widgets/settings_button.dart';
import '../providers/catalog_providers.dart';

/// Second level: every drawing of a category, each tagged with how
/// intricate its shapes are.
class DrawingListScreen extends ConsumerWidget {
  const DrawingListScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawings = ref.watch(drawingsProvider(categoryId));
    final categories = ref.watch(categoriesProvider);
    final index = categories.indexWhere((c) => c.id == categoryId);
    final category = index >= 0 ? categories[index] : null;
    final color = category == null
        ? categoryAccentColors.first
        : categoryColor(category, categoryAccentColors[index % categoryAccentColors.length]);

    return Scaffold(
      body: MeadowBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              final columns = w / h > 1.25 ? 4 : 3;

              return Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(height: h * 0.03),
                      RibbonBanner(
                        title: category?.name ?? categoryId,
                        color: color,
                        width: h * 0.85,
                        height: h * 0.17,
                      ),
                      SizedBox(height: h * 0.02),
                      Expanded(
                        child: drawings.isEmpty
                            ? Center(
                                child: OutlinedText(
                                  spans: const [('¡Muy pronto habrá dibujos aquí!', Colors.white)],
                                  style: roundedTextStyle(fontSize: h * 0.06),
                                  strokeColor: const Color(0xFF1C5FB8),
                                  strokeWidth: h * 0.012,
                                ),
                              )
                            : _DrawingGrid(
                                drawings: drawings,
                                columns: columns,
                                horizontalPadding: w * 0.07,
                                gap: w * 0.022,
                              ),
                      ),
                      SizedBox(height: h * 0.02),
                      ChunkyButton(
                        width: h * 0.46,
                        height: h * 0.11,
                        topColor: const Color(0xFFFFDB4D),
                        bottomColor: const Color(0xFFFFB300),
                        edgeColor: const Color(0xFFD98C00),
                        onPressed: () => context.pop(),
                        child: OutlinedText(
                          spans: const [('Volver', Colors.white)],
                          style: roundedTextStyle(fontSize: h * 0.06),
                          strokeColor: const Color(0xFFB86E00),
                          strokeWidth: h * 0.01,
                        ),
                      ),
                      SizedBox(height: h * 0.04),
                    ],
                  ),
                  Positioned(
                    top: h * 0.03,
                    right: h * 0.04,
                    child: SettingsButton(size: h * 0.11),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Fixed-size cards in rows, centered so a category with only a few
/// drawings still looks balanced; scrolls when there are many.
class _DrawingGrid extends StatelessWidget {
  const _DrawingGrid({
    required this.drawings,
    required this.columns,
    required this.horizontalPadding,
    required this.gap,
  });

  final List<Drawing> drawings;
  final int columns;
  final double horizontalPadding;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth - horizontalPadding * 2;
        final cardWidth = (available - gap * (columns - 1)) / columns;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: gap),
          child: SizedBox(
            width: available,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final drawing in drawings)
                  SizedBox(
                    width: cardWidth,
                    height: cardWidth / 1.35,
                    child: _DrawingCard(
                      drawing: drawing,
                      onTap: () => context.push('/levels/${drawing.id}'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DrawingCard extends StatelessWidget {
  const _DrawingCard({required this.drawing, required this.onTap});

  final Drawing drawing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final radius = width * 0.07;
        final border = width * 0.025;

        return Semantics(
          button: true,
          label: '${drawing.title}, ${_complexityLabel(drawing.complexity)}',
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: Colors.white, width: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(45),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius - border),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/${drawing.outlineAsset}',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported_outlined, size: 48),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: _ComplexityBadge(
                        complexity: drawing.complexity,
                        size: width,
                        cornerRadius: radius - border,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

String _complexityLabel(DrawingComplexity complexity) => switch (complexity) {
      DrawingComplexity.easy => 'Fácil',
      DrawingComplexity.medium => 'Medio',
      DrawingComplexity.hard => 'Difícil',
    };

class _ComplexityBadge extends StatelessWidget {
  const _ComplexityBadge({
    required this.complexity,
    required this.size,
    required this.cornerRadius,
  });

  final DrawingComplexity complexity;
  final double size;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    final color = switch (complexity) {
      DrawingComplexity.easy => const Color(0xFF5DBB3F),
      DrawingComplexity.medium => const Color(0xFFFF8A1F),
      DrawingComplexity.hard => const Color(0xFFE53935),
    };

    return Container(
      padding: EdgeInsets.fromLTRB(size * 0.05, size * 0.018, size * 0.05, size * 0.022),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(cornerRadius),
          bottomRight: Radius.circular(size * 0.04),
        ),
      ),
      child: Text(
        _complexityLabel(complexity).toUpperCase(),
        style: roundedTextStyle(fontSize: size * 0.07),
      ),
    );
  }
}
