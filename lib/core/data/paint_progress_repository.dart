import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

abstract class PaintProgressRepository {
  PaintProgress? loadProgress(String drawingId, DifficultyMode mode);
  void saveProgress(PaintProgress progress);
  void clearProgress(String drawingId, DifficultyMode mode);
}

class SharedPrefsPaintProgressRepository implements PaintProgressRepository {
  SharedPrefsPaintProgressRepository(this._prefs);

  final SharedPreferences _prefs;

  @override
  PaintProgress? loadProgress(String drawingId, DifficultyMode mode) {
    final serialized = _prefs.getString(_progressKey(drawingId, mode));
    if (serialized == null) return null;
    try {
      final root = jsonDecode(serialized) as Map<String, dynamic>;
      final filledZonesJson = root['filledZones'] as Map<String, dynamic>? ?? {};
      final filledZones = filledZonesJson.map((k, v) => MapEntry(int.parse(k), v as String));

      final strokesJson = root['strokes'] as List<dynamic>? ?? [];
      final strokes = strokesJson.map((s) {
        final sm = s as Map<String, dynamic>;
        final pointsJson = sm['points'] as List<dynamic>? ?? [];
        final points = pointsJson.map((p) {
          final pm = p as Map<String, dynamic>;
          return PaintPoint(
            (pm['x'] as num).toDouble(),
            (pm['y'] as num).toDouble(),
          );
        }).toList();
        return PaintStroke(
          zoneId: sm['zoneId'] as int?,
          colorHex: sm['colorHex'] as String? ?? '#4D96FF',
          brushRadiusPx: (sm['brushRadiusPx'] as num? ?? 12).toDouble(),
          points: points,
        );
      }).where((s) => s.points.isNotEmpty).toList();

      return PaintProgress(
        drawingId: drawingId,
        mode: mode,
        filledZones: filledZones,
        strokes: strokes,
        lastModifiedEpochMs:
            root['lastModifiedEpochMs'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  void saveProgress(PaintProgress progress) {
    final serialized = jsonEncode({
      'drawingId': progress.drawingId,
      'mode': progress.mode.name,
      'lastModifiedEpochMs': progress.lastModifiedEpochMs,
      'filledZones': Map.fromEntries(
        progress.filledZones.entries.map((e) => MapEntry(e.key.toString(), e.value)),
      ),
      'strokes': progress.strokes.map((s) => {
        'zoneId': s.zoneId,
        'colorHex': s.colorHex,
        'brushRadiusPx': s.brushRadiusPx,
        'points': s.points.map((p) => {'x': p.x, 'y': p.y}).toList(),
      }).toList(),
    });
    _prefs.setString(_progressKey(progress.drawingId, progress.mode), serialized);
  }

  @override
  void clearProgress(String drawingId, DifficultyMode mode) {
    _prefs.remove(_progressKey(drawingId, mode));
  }

  String _progressKey(String drawingId, DifficultyMode mode) =>
      'progress_${drawingId}_${mode.name}';
}
