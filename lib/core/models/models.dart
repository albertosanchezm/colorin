class Category {
  final String id;
  final String name;
  final String description;
  final String backgroundAsset;
  final String assetsDirectory;
  final int order;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.backgroundAsset,
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

  const Drawing({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.outlineAsset,
    required this.zoneMapAsset,
    required this.difficultyTags,
  });
}

enum DifficultyMode { simple, medium, advanced }

class PaletteColor {
  final String id;
  final String hex;
  final int order;

  const PaletteColor({required this.id, required this.hex, required this.order});
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

  PaintStroke copyWith({
    int? zoneId,
    String? colorHex,
    double? brushRadiusPx,
    List<PaintPoint>? points,
    bool clearZoneId = false,
  }) =>
      PaintStroke(
        zoneId: clearZoneId ? null : (zoneId ?? this.zoneId),
        colorHex: colorHex ?? this.colorHex,
        brushRadiusPx: brushRadiusPx ?? this.brushRadiusPx,
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
