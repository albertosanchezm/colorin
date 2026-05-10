import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../providers/catalog_providers.dart';

class LevelSelectionScreen extends ConsumerWidget {
  const LevelSelectionScreen({super.key, required this.drawingId});

  final String drawingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawing = ref.watch(drawingProvider(drawingId));

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(title: drawing?.title ?? drawingId),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: DifficultyMode.values.map((mode) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _ModeCard(
                          mode: mode,
                          onTap: () => context.push('/paint/$drawingId/${mode.name}'),
                        ),
                      ),
                    );
                  }).toList(),
                ),
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

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.mode, required this.onTap});

  final DifficultyMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, title, description, color) = switch (mode) {
      DifficultyMode.simple => (
          Icons.touch_app_rounded,
          'Sencillo',
          'Toca una zona y se rellena completa',
          const Color(0xFF6BCB77),
        ),
      DifficultyMode.medium => (
          Icons.gesture_rounded,
          'Intermedio',
          'Toca zona, arrastra dentro del borde',
          const Color(0xFFF7B267),
        ),
      DifficultyMode.advanced => (
          Icons.brush_rounded,
          'Avanzado',
          'Arrastra libremente sobre el lienzo',
          const Color(0xFFFF6B6B),
        ),
    };

    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: color.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
