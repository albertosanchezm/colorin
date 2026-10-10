import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/theme.dart';
import '../../catalog/providers/catalog_providers.dart';
import '../widgets/category_card.dart';
import '../widgets/chunky_button.dart';
import '../widgets/meadow_background.dart';
import '../widgets/outlined_text.dart';
import '../widgets/settings_button.dart';

const _titleStroke = Color(0xFF1C5FB8);
const _titleYellow = Color(0xFFFFD23F);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  final _cardKeys = <GlobalKey>[];
  int _selected = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isAvailable(Category category) =>
      ref.read(drawingsProvider(category.id)).isNotEmpty;

  void _select(int index) {
    if (index == _selected) return;
    HapticFeedback.selectionClick();
    setState(() => _selected = index);
    final cardContext = _cardKeys[index].currentContext;
    if (cardContext != null) {
      Scrollable.ensureVisible(
        cardContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _open(Category category) {
    if (_isAvailable(category)) {
      context.push('/drawings/${category.id}');
      return;
    }
    final size = MediaQuery.sizeOf(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          // Float between the cards and ¡Jugar! so it never hides the buttons.
          margin: EdgeInsets.fromLTRB(size.width * 0.25, 0, size.width * 0.25, size.height * 0.28),
          content: Text(
            '¡Muy pronto habrá dibujos de ${category.name}!',
            style: roundedTextStyle(fontSize: 18, weight: 600),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    while (_cardKeys.length < categories.length) {
      _cardKeys.add(GlobalKey());
    }
    if (_selected >= categories.length) _selected = 0;

    return Scaffold(
      body: MeadowBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              // Fit five cards across when possible, never taller than 38% of the screen.
              final cardWidth = min(h * 0.38 * 0.78, w / 5.5);
              final cardHeight = cardWidth / 0.78;

              return Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(height: h * 0.05),
                      SizedBox(
                        height: h * 0.14,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: h * 0.18),
                          child: FittedBox(
                            child: OutlinedText(
                              spans: const [
                                ('¿Qué quieres ', Colors.white),
                                ('colorear hoy?', _titleYellow),
                              ],
                              style: roundedTextStyle(fontSize: 64, weight: 650),
                              strokeColor: _titleStroke,
                              strokeWidth: 12,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        height: cardHeight + h * 0.06,
                        child: categories.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : _CategoryCarousel(
                                controller: _scrollController,
                                categories: categories,
                                cardKeys: _cardKeys,
                                cardWidth: cardWidth,
                                cardHeight: cardHeight,
                                selected: _selected,
                                isAvailable: (c) => ref.watch(drawingsProvider(c.id)).isNotEmpty,
                                onTap: (index) {
                                  if (index == _selected) {
                                    _open(categories[index]);
                                  } else {
                                    _select(index);
                                  }
                                },
                              ),
                      ),
                      SizedBox(height: h * 0.015),
                      _PageDots(
                        count: categories.length,
                        selected: _selected,
                        size: h * 0.022,
                        onTap: _select,
                      ),
                      const Spacer(),
                      ChunkyButton(
                        width: h * 0.5,
                        height: h * 0.12,
                        topColor: const Color(0xFFFFC93C),
                        bottomColor: const Color(0xFFFF9500),
                        edgeColor: const Color(0xFFD9640B),
                        onPressed: () {
                          if (categories.isNotEmpty) _open(categories[_selected]);
                        },
                        child: OutlinedText(
                          spans: const [('¡Jugar!', Colors.white)],
                          style: roundedTextStyle(fontSize: h * 0.065),
                          strokeColor: const Color(0xFFC0550A),
                          strokeWidth: h * 0.01,
                        ),
                      ),
                      SizedBox(height: h * 0.015),
                      ChunkyButton(
                        width: h * 0.38,
                        height: h * 0.075,
                        topColor: const Color(0xFF4A9BFF),
                        bottomColor: const Color(0xFF1F6FE0),
                        edgeColor: const Color(0xFF1450A8),
                        onPressed: () => context.push('/my-drawings'),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.palette_rounded, color: Colors.white, size: h * 0.045),
                            SizedBox(width: h * 0.015),
                            Text('Mis Dibujos', style: roundedTextStyle(fontSize: h * 0.038)),
                          ],
                        ),
                      ),
                      SizedBox(height: h * 0.03),
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

class _CategoryCarousel extends StatelessWidget {
  const _CategoryCarousel({
    required this.controller,
    required this.categories,
    required this.cardKeys,
    required this.cardWidth,
    required this.cardHeight,
    required this.selected,
    required this.isAvailable,
    required this.onTap,
  });

  final ScrollController controller;
  final List<Category> categories;
  final List<GlobalKey> cardKeys;
  final double cardWidth;
  final double cardHeight;
  final int selected;
  final bool Function(Category) isAvailable;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final gap = cardWidth * 0.08;

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = categories.length * (cardWidth + gap) + gap;
        // Center the row when every card fits; otherwise let it scroll.
        final sidePadding = contentWidth < constraints.maxWidth
            ? (constraints.maxWidth - contentWidth) / 2 + gap
            : gap * 2;

        return ListView.builder(
          controller: controller,
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: gap / 2),
              child: Center(
                child: SizedBox(
                  key: cardKeys[index],
                  width: cardWidth,
                  height: cardHeight,
                  child: CategoryCard(
                    category: category,
                    color: categoryColor(
                      category,
                      categoryAccentColors[index % categoryAccentColors.length],
                    ),
                    selected: index == selected,
                    available: isAvailable(category),
                    onTap: () => onTap(index),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.count,
    required this.selected,
    required this.size,
    required this.onTap,
  });

  final int count;
  final int selected;
  final double size;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(size * 0.4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: i == selected ? size * 1.8 : size,
                height: size,
                decoration: BoxDecoration(
                  color: i == selected ? const Color(0xFF2F80ED) : Colors.white.withAlpha(200),
                  borderRadius: BorderRadius.circular(size),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 3)],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
