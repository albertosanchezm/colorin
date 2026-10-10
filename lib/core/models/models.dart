class Category {
  final String id;
  final String name;
  final String description;
  final String backgroundAsset;
  final String? colorHex;
  final String assetsDirectory;
  final int order;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.backgroundAsset,
    this.colorHex,
    required this.assetsDirectory,
    required this.order,
  });
}

class Drawing {
  final String id;
  final String categoryId;
  final String title;
  final String outlineAsset;
  final String zoneMapAsset;
  final Set<DifficultyMode> difficultyTags;
  final DrawingComplexity complexity;

  const Drawing({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.outlineAsset,
    required this.zoneMapAsset,
    required this.difficultyTags,
    this.complexity = DrawingComplexity.easy,
  });
}

enum DifficultyMode { simple, medium, advanced }

/// How intricate a drawing's shapes are. Unrelated to [DifficultyMode],
/// which is how the child colors it.
enum DrawingComplexity { easy, medium, hard }

class PaletteColor {
  final String id;
  final String hex;

  const PaletteColor({required this.id, required this.hex});
}

class PaintPoint {
  final double x;
  final double y;
  const PaintPoint(this.x, this.y);
}

class PaintStroke {
  final int? zoneId;
  final String colorHex;
  final double brushRadiusPx;
  final List<PaintPoint> points;

  const PaintStroke({
    this.zoneId,
    required this.colorHex,
    required this.brushRadiusPx,
    required this.points,
  });

  PaintStroke copyWith({List<PaintPoint>? points}) => PaintStroke(
        zoneId: zoneId,
        colorHex: colorHex,
        brushRadiusPx: brushRadiusPx,
        points: points ?? this.points,
      );
}

class PaintProgress {
  final String drawingId;
  final DifficultyMode mode;
  final Map<int, String> filledZones;
  final List<PaintStroke> strokes;
  final int lastModifiedEpochMs;

  const PaintProgress({
    required this.drawingId,
    required this.mode,
    required this.filledZones,
    this.strokes = const [],
    required this.lastModifiedEpochMs,
  });
}
