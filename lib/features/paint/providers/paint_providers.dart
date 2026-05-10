import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/models/models.dart';
import 'paint_notifier.dart';

final paintEditorProvider = StateNotifierProvider.family<PaintEditorNotifier, PaintEditorState,
    (String drawingId, DifficultyMode mode)>(
  (ref, args) {
    final (drawingId, mode) = args;
    final repo = ref.read(paintProgressRepositoryProvider);
    final savedProgress = repo.loadProgress(drawingId, mode);
    return PaintEditorNotifier(
      repository: repo,
      drawingId: drawingId,
      mode: mode,
      savedProgress: savedProgress,
    );
  },
);
