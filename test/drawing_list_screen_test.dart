import 'package:colorin/app/providers.dart';
import 'package:colorin/core/data/catalog_repository.dart';
import 'package:colorin/core/models/models.dart';
import 'package:colorin/features/catalog/screens/drawing_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Drawing _drawing(String id, DrawingComplexity complexity) => Drawing(
      id: id,
      categoryId: 'castles',
      title: id,
      outlineAsset: 'castles/$id.png',
      zoneMapAsset: 'castles/${id}_zonemap.png',
      difficultyTags: const {DifficultyMode.simple},
      complexity: complexity,
    );

class _FakeCatalog implements CatalogRepository {
  final _drawings = [
    _drawing('a', DrawingComplexity.easy),
    _drawing('b', DrawingComplexity.medium),
    _drawing('c', DrawingComplexity.hard),
    _drawing('d', DrawingComplexity.hard),
  ];

  @override
  List<Category> getCategories() => const [
        Category(
          id: 'castles',
          name: 'Castillos',
          description: '',
          backgroundAsset: 'home/castles.png',
          assetsDirectory: 'castles',
          order: 0,
        ),
      ];

  @override
  List<Drawing> getDrawings(String categoryId) => _drawings;

  @override
  Drawing? getDrawing(String drawingId) => null;

  @override
  List<PaletteColor> getPalette() => const [];
}

void main() {
  testWidgets('drawing list shows the category banner and a complexity tag per drawing',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [catalogRepositoryProvider.overrideWithValue(_FakeCatalog())],
        child: const MaterialApp(home: DrawingListScreen(categoryId: 'castles')),
      ),
    );

    expect(find.text('Castillos', findRichText: true), findsWidgets);
    expect(find.text('FÁCIL'), findsOneWidget);
    expect(find.text('MEDIO'), findsOneWidget);
    expect(find.text('DIFÍCIL'), findsNWidgets(2));
    expect(find.text('Volver', findRichText: true), findsWidgets);
  });
}
