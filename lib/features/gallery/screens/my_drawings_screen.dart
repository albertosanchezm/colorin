import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/models/models.dart';
import '../../catalog/providers/catalog_providers.dart';

typedef _StartedDrawing = ({Drawing drawing, PaintProgress progress});

/// Drawings the child has started, most recently painted first.
/// Auto-disposed so it is recomputed every time the screen opens.
final _startedDrawingsProvider = Provider.autoDispose<List<_StartedDrawing>>((ref) {
  final progressRepo = ref.watch(paintProgressRepositoryProvider);
  final started = <_StartedDrawing>[];
  for (final category in ref.watch(categoriesProvider)) {
    for (final drawing in ref.watch(drawingsProvider(category.id))) {
      for (final mode in DifficultyMode.values) {
        final progress = progressRepo.loadProgress(drawing.id, mode);
        if (progress == null) continue;
        if (progress.filledZones.isEmpty && progress.strokes.isEmpty) continue;
        started.add((drawing: drawing, progress: progress));
      }
    }
  }
  started.sort((a, b) => b.progress.lastModifiedEpochMs.compareTo(a.progress.lastModifiedEpochMs));
  return started;
});

class MyDrawingsScreen extends ConsumerWidget {
  const MyDrawingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final started = ref.watch(_startedDrawingsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: const Color(0xFF4A9BFF),
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.pop(),
                    color: Colors.white,
                  ),
                  Text(
                    'Mis Dibujos',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: started.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Todavía no has coloreado ningún dibujo.\n¡Pulsa Jugar para empezar!',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 240,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: started.length,
                      itemBuilder: (context, index) {
                        final (:drawing, :progress) = started[index];
                        return _StartedCard(
                          drawing: drawing,
                          mode: progress.mode,
                          onTap: () => context.push('/paint/${drawing.id}/${progress.mode.name}'),
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

class _StartedCard extends StatelessWidget {
  const _StartedCard({required this.drawing, required this.mode, required this.onTap});

  final Drawing drawing;
  final DifficultyMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = switch (mode) {
      DifficultyMode.simple => 'Sencillo',
      DifficultyMode.medium => 'Intermedio',
      DifficultyMode.advanced => 'Avanzado',
    };

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
                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, size: 48),
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
                  Text(label, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
