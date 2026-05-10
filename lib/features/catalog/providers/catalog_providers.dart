import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/models/models.dart';

final categoriesProvider = Provider<List<Category>>((ref) {
  return ref.watch(catalogRepositoryProvider).getCategories();
});

final drawingsProvider = Provider.family<List<Drawing>, String>((ref, categoryId) {
  return ref.watch(catalogRepositoryProvider).getDrawings(categoryId);
});

final drawingProvider = Provider.family<Drawing?, String>((ref, drawingId) {
  return ref.watch(catalogRepositoryProvider).getDrawing(drawingId);
});

final paletteProvider = Provider<List<PaletteColor>>((ref) {
  return ref.watch(catalogRepositoryProvider).getPalette();
});
