import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../providers/catalog_providers.dart';

class DrawingListScreen extends ConsumerWidget {
  const DrawingListScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawings = ref.watch(drawingsProvider(categoryId));
    final categories = ref.watch(categoriesProvider);
    final category = categories.where((c) => c.id == categoryId).firstOrNull;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(title: category?.name ?? categoryId),
            Expanded(
              child: drawings.isEmpty
                  ? const Center(
                      child: Text('No hay dibujos disponibles.'),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 280,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: drawings.length,
                      itemBuilder: (context, index) {
                        final drawing = drawings[index];
                        return _DrawingCard(
                          drawing: drawing,
                          onTap: () => context.push('/levels/${drawing.id}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFD93D),
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
            color: const Color(0xFF374151),
          ),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawingCard extends StatelessWidget {
  const _DrawingCard({required this.drawing, required this.onTap});

  final Drawing drawing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.asset(
                'assets/${drawing.outlineAsset}',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0xFFF3F4F6),
                  child: Icon(Icons.image_not_supported_outlined, size: 48),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drawing.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: drawing.difficultyTags.map((mode) => _DifficultyChip(mode: mode)).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({required this.mode});
  final DifficultyMode mode;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (mode) {
      DifficultyMode.simple => ('Sencillo', const Color(0xFF6BCB77)),
      DifficultyMode.medium => ('Medio', const Color(0xFFF7B267)),
      DifficultyMode.advanced => ('Avanzado', const Color(0xFFFF6B6B)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(120), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
