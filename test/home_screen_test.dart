import 'package:colorin/app/providers.dart';
import 'package:colorin/core/data/catalog_repository.dart';
import 'package:colorin/core/data/paint_progress_repository.dart';
import 'package:colorin/core/models/models.dart';
import 'package:colorin/features/home/screens/home_screen.dart';
import 'package:colorin/features/home/widgets/category_card.dart';
import 'package:colorin/features/home/widgets/chunky_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCatalog implements CatalogRepository {
  static const _dino = Drawing(
    id: 'dinosaurs_1',
    categoryId: 'dinosaurs',
    title: 'Dino',
    outlineAsset: 'dinosaurs/dinosaurs-easy-1.png',
    zoneMapAsset: 'dinosaurs/dinosaurs-easy-1_zonemap.png',
    difficultyTags: {DifficultyMode.simple},
  );

  @override
  List<Category> getCategories() => const [
        Category(
          id: 'dinosaurs',
          name: 'Dinosaurios',
          description: '',
          backgroundAsset: 'home/dinosaurs.png',
          assetsDirectory: 'dinosaurs',
          order: 0,
        ),
        Category(
          id: 'cars',
          name: 'Coches',
          description: '',
          backgroundAsset: 'home/cars.png',
          assetsDirectory: 'cars',
          order: 1,
        ),
      ];

  @override
  List<Drawing> getDrawings(String categoryId) => categoryId == 'dinosaurs' ? [_dino] : [];

  @override
  Drawing? getDrawing(String drawingId) => drawingId == _dino.id ? _dino : null;

  @override
  List<PaletteColor> getPalette() => const [];
}

class _FakeProgress implements PaintProgressRepository {
  @override
  PaintProgress? loadProgress(String drawingId, DifficultyMode mode) => null;

  @override
  void saveProgress(PaintProgress progress) {}
}

void main() {
  testWidgets('home shows categories and announces ones without drawings', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogRepositoryProvider.overrideWithValue(_FakeCatalog()),
          paintProgressRepositoryProvider.overrideWithValue(_FakeProgress()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('Dinosaurios', findRichText: true), findsWidgets);
    expect(find.text('Coches', findRichText: true), findsWidgets);
    expect(find.text('¡Pronto!'), findsOneWidget);

    // Select "Coches" and press ¡Jugar!.
    await tester.tap(find.byType(CategoryCard).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ChunkyButton).first);
    await tester.pump();

    expect(find.text('¡Muy pronto habrá dibujos de Coches!'), findsOneWidget);
  });
}
