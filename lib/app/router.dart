import 'package:go_router/go_router.dart';

import '../core/models/models.dart';
import '../features/catalog/screens/category_list_screen.dart';
import '../features/catalog/screens/drawing_list_screen.dart';
import '../features/catalog/screens/level_selection_screen.dart';
import '../features/paint/screens/paint_editor_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const CategoryListScreen(),
    ),
    GoRoute(
      path: '/drawings/:categoryId',
      builder: (_, state) => DrawingListScreen(
        categoryId: state.pathParameters['categoryId']!,
      ),
    ),
    GoRoute(
      path: '/levels/:drawingId',
      builder: (_, state) => LevelSelectionScreen(
        drawingId: state.pathParameters['drawingId']!,
      ),
    ),
    GoRoute(
      path: '/paint/:drawingId/:mode',
      builder: (_, state) => PaintEditorScreen(
        drawingId: state.pathParameters['drawingId']!,
        mode: DifficultyMode.values.byName(state.pathParameters['mode']!),
      ),
    ),
  ],
);
