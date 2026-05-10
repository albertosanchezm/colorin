import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/models.dart';

abstract class CatalogRepository {
  List<Category> getCategories();
  List<Drawing> getDrawings(String categoryId);
  Drawing? getDrawing(String drawingId);
  List<PaletteColor> getPalette();
}

class FlutterCatalogRepository implements CatalogRepository {
  FlutterCatalogRepository._(this._categories, this._drawings);

  final List<Category> _categories;
  final List<Drawing> _drawings;

  static const _palette = [
    PaletteColor(id: 'red', hex: '#FF6B6B', order: 0),
    PaletteColor(id: 'orange', hex: '#F7B267', order: 1),
    PaletteColor(id: 'yellow', hex: '#FFD93D', order: 2),
    PaletteColor(id: 'green', hex: '#6BCB77', order: 3),
    PaletteColor(id: 'mint', hex: '#4DDFB3', order: 4),
    PaletteColor(id: 'blue', hex: '#4D96FF', order: 5),
    PaletteColor(id: 'navy', hex: '#355CDE', order: 6),
    PaletteColor(id: 'purple', hex: '#845EC2', order: 7),
    PaletteColor(id: 'pink', hex: '#FF8FAB', order: 8),
    PaletteColor(id: 'brown', hex: '#B08968', order: 9),
    PaletteColor(id: 'gray', hex: '#ADB5BD', order: 10),
    PaletteColor(id: 'black', hex: '#343A40', order: 11),
  ];

  static Future<FlutterCatalogRepository> create() async {
    final categories = await _loadCategories();
    final drawings = await _loadDrawings(categories);
    return FlutterCatalogRepository._(categories, drawings);
  }

  @override
  List<Category> getCategories() => _categories;

  @override
  List<Drawing> getDrawings(String categoryId) =>
      _drawings.where((d) => d.categoryId == categoryId).toList()
        ..sort((a, b) => a.title.compareTo(b.title));

  @override
  Drawing? getDrawing(String drawingId) =>
      _drawings.where((d) => d.id == drawingId).firstOrNull;

  @override
  List<PaletteColor> getPalette() => _palette;

  static Future<List<Category>> _loadCategories() async {
    try {
      final json = await rootBundle.loadString('assets/catalog/categories.json');
      final items = jsonDecode(json) as List<dynamic>;
      final categories = items.indexed.map((entry) {
        final index = entry.$1;
        final item = entry.$2 as Map<String, dynamic>;
        final assetsDir = item['assetsDirectory'] as String;
        return Category(
          id: (item['id'] as String?) ?? assetsDir,
          name: item['title'] as String,
          description: item['description'] as String,
          backgroundAsset: item['image'] as String,
          assetsDirectory: assetsDir,
          order: (item['order'] as int?) ?? index,
        );
      }).toList();
      categories.sort((a, b) => a.order.compareTo(b.order));
      return categories;
    } catch (_) {
      return [
        const Category(
          id: 'dinosaurs',
          name: 'Dinosaurios',
          description: 'Explora dibujos de dinosaurios',
          backgroundAsset: 'dinosaurs/dinosaurs-easy-1.png',
          assetsDirectory: 'dinosaurs',
          order: 0,
        ),
      ];
    }
  }

  static Future<List<Drawing>> _loadDrawings(List<Category> categories) async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final allKeys = manifest.listAssets().toSet();
    final drawings = <Drawing>[];

    for (final category in categories) {
      final prefix = 'assets/${category.assetsDirectory}/';
      final outlineFiles = allKeys.where((k) {
        if (!k.startsWith(prefix)) return false;
        final name = k.substring(prefix.length).toLowerCase();
        return (name.endsWith('.png') || name.endsWith('.jpg') || name.endsWith('.jpeg')) &&
            !name.endsWith('_zonemap.png');
      }).toList();

      for (final outlinePath in outlineFiles) {
        final basePath = outlinePath.substring(0, outlinePath.lastIndexOf('.'));
        final zoneMapPath = '${basePath}_zonemap.png';
        if (!allKeys.contains(zoneMapPath)) continue;

        final fileName = outlinePath.split('/').last;
        final baseName = fileName.substring(0, fileName.lastIndexOf('.'));
        final title = baseName
            .replaceAll('-', ' ')
            .replaceAll('_', ' ')
            .split(' ')
            .where((t) => t.isNotEmpty)
            .map((t) => t[0].toUpperCase() + t.substring(1))
            .join(' ');

        // Strip the 'assets/' prefix for storage in Drawing (consistent with Android)
        final outlineAsset = outlinePath.substring('assets/'.length);
        final zoneMapAsset = zoneMapPath.substring('assets/'.length);

        drawings.add(Drawing(
          id: '${category.id}_$baseName',
          categoryId: category.id,
          title: title,
          outlineAsset: outlineAsset,
          zoneMapAsset: zoneMapAsset,
          difficultyTags: DifficultyMode.values.toSet(),
        ));
      }
    }

    drawings.sort((a, b) => a.title.compareTo(b.title));
    return drawings;
  }
}
