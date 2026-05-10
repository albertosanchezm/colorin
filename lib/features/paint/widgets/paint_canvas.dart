import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/models/models.dart';

// ---------------------------------------------------------------------------
// Public widget
// ---------------------------------------------------------------------------

class PaintCanvas extends StatefulWidget {
  const PaintCanvas({
    super.key,
    required this.composedImage,
    required this.zoneMapRgba,
    required this.zoneMapWidth,
    required this.zoneMapHeight,
    required this.selectedColorHex,
    required this.activeZoneId,
    required this.mode,
    required this.onZoneTapped,
    required this.onStrokeComplete,
  });

  final ui.Image? composedImage;
  final Uint8List? zoneMapRgba;
  final int zoneMapWidth;
  final int zoneMapHeight;
  final String selectedColorHex;
  final int? activeZoneId;
  final DifficultyMode mode;
  final void Function(int zoneId) onZoneTapped;
  final void Function(PaintStroke stroke) onStrokeComplete;

  @override
  State<PaintCanvas> createState() => _PaintCanvasState();
}

class _PaintCanvasState extends State<PaintCanvas> {
  PaintStroke? _previewStroke;
  Size _canvasSize = Size.zero;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        return Listener(
          onPointerDown: _handlePointerDown,
          onPointerMove: _handlePointerMove,
          onPointerUp: _handlePointerUp,
          child: GestureDetector(
            onTapUp: _handleTapUp,
            child: CustomPaint(
              painter: _PaintPainter(
                composedImage: widget.composedImage,
                previewStroke: _previewStroke,
                imageWidth: widget.zoneMapWidth,
                imageHeight: widget.zoneMapHeight,
              ),
              size: Size(constraints.maxWidth, constraints.maxHeight),
            ),
          ),
        );
      },
    );
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.mode == DifficultyMode.advanced) return;
    final zoneId = _zoneIdAt(details.localPosition);
    if (zoneId == null) return;
    widget.onZoneTapped(zoneId);
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (widget.mode == DifficultyMode.simple) return;
    final pt = _toBitmapPoint(event.localPosition);
    if (pt == null) return;
    final zoneId =
        widget.mode == DifficultyMode.medium ? widget.activeZoneId : null;
    setState(() {
      _previewStroke = PaintStroke(
        zoneId: zoneId,
        colorHex: widget.selectedColorHex,
        brushRadiusPx: _brushRadius(),
        points: [pt],
      );
    });
  }

  void _handlePointerMove(PointerMoveEvent event) {
    final stroke = _previewStroke;
    if (stroke == null) return;
    final pt = _toBitmapPoint(event.localPosition);
    if (pt == null) return;
    final last = stroke.points.last;
    final dx = pt.x - last.x;
    final dy = pt.y - last.y;
    if (sqrt(dx * dx + dy * dy) < max(1.0, stroke.brushRadiusPx * 0.18)) return;
    setState(() {
      _previewStroke = stroke.copyWith(points: [...stroke.points, pt]);
    });
  }

  void _handlePointerUp(PointerUpEvent event) {
    final stroke = _previewStroke;
    if (stroke == null || stroke.points.isEmpty) return;
    setState(() => _previewStroke = null);
    widget.onStrokeComplete(stroke);
  }

  PaintPoint? _toBitmapPoint(Offset pos) {
    if (_canvasSize.isEmpty || widget.zoneMapWidth == 0) return null;
    return PaintPoint(
      (pos.dx / _canvasSize.width * (widget.zoneMapWidth - 1))
          .clamp(0.0, (widget.zoneMapWidth - 1).toDouble()),
      (pos.dy / _canvasSize.height * (widget.zoneMapHeight - 1))
          .clamp(0.0, (widget.zoneMapHeight - 1).toDouble()),
    );
  }

  int? _zoneIdAt(Offset pos) {
    final zm = widget.zoneMapRgba;
    if (zm == null || _canvasSize.isEmpty || widget.zoneMapWidth == 0) return null;
    final bx = ((pos.dx / _canvasSize.width) * (widget.zoneMapWidth - 1))
        .round()
        .clamp(0, widget.zoneMapWidth - 1);
    final by = ((pos.dy / _canvasSize.height) * (widget.zoneMapHeight - 1))
        .round()
        .clamp(0, widget.zoneMapHeight - 1);
    final i = (by * widget.zoneMapWidth + bx) * 4;
    final a = zm[i + 3];
    if (a == 0) return null;
    return packArgb(a, zm[i], zm[i + 1], zm[i + 2]);
  }

  double _brushRadius() {
    if (_canvasSize.isEmpty || widget.zoneMapWidth == 0) return 10;
    final scaleX = widget.zoneMapWidth / _canvasSize.width;
    final scaleY = widget.zoneMapHeight / _canvasSize.height;
    return (16.0 * min(scaleX, scaleY)).clamp(4.0, 28.0);
  }
}

// ---------------------------------------------------------------------------
// CustomPainter
// ---------------------------------------------------------------------------

class _PaintPainter extends CustomPainter {
  _PaintPainter({
    required this.composedImage,
    required this.previewStroke,
    required this.imageWidth,
    required this.imageHeight,
  });

  final ui.Image? composedImage;
  final PaintStroke? previewStroke;
  final int imageWidth;
  final int imageHeight;

  @override
  void paint(Canvas canvas, Size size) {
    if (composedImage != null) {
      final src = Rect.fromLTWH(
          0, 0, composedImage!.width.toDouble(), composedImage!.height.toDouble());
      canvas.drawImageRect(
          composedImage!, src, Offset.zero & size, Paint());
    } else {
      canvas.drawRect(
          Offset.zero & size, Paint()..color = const Color(0xFFFFF8E7));
    }
    if (previewStroke != null && imageWidth > 0) {
      _drawPreview(canvas, size, previewStroke!);
    }
  }

  void _drawPreview(Canvas canvas, Size size, PaintStroke stroke) {
    if (stroke.points.isEmpty) return;
    final color = hexToFlutterColor(stroke.colorHex);
    final scaleX = size.width / imageWidth;
    final scaleY = size.height / imageHeight;
    final radius = stroke.brushRadiusPx * min(scaleX, scaleY);
    final paint = Paint()..color = color;
    for (final pt in stroke.points) {
      canvas.drawCircle(Offset(pt.x * scaleX, pt.y * scaleY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_PaintPainter old) =>
      old.composedImage != composedImage || old.previewStroke != previewStroke;
}

// ---------------------------------------------------------------------------
// Bitmap composition (pure pixel manipulation — runs on main thread)
// ---------------------------------------------------------------------------

Future<ui.Image> composePaintImage({
  required Uint8List outlineRgba,
  required Uint8List zoneMapRgba,
  required int width,
  required int height,
  required Map<int, String> filledZones,
  required List<PaintStroke> strokes,
  int? activeZoneId,
}) async {
  final pixels = _buildPixelBuffer(
    outlineRgba: outlineRgba,
    zoneMapRgba: zoneMapRgba,
    width: width,
    height: height,
    filledZones: filledZones,
    strokes: strokes,
    activeZoneId: activeZoneId,
  );

  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    pixels, width, height, ui.PixelFormat.rgba8888, completer.complete,
  );
  return completer.future;
}

Uint8List _buildPixelBuffer({
  required Uint8List outlineRgba,
  required Uint8List zoneMapRgba,
  required int width,
  required int height,
  required Map<int, String> filledZones,
  required List<PaintStroke> strokes,
  int? activeZoneId,
}) {
  final output = Uint8List(width * height * 4);
  const defaultFillArgb = 0xFFFFF8E7;
  // ARGB: alpha=28, r=107, g=203, b=255
  const activeTintArgb = (28 << 24) | (107 << 16) | (203 << 8) | 255;

  final cache = <String, int>{};
  int getArgb(String hex) => cache.putIfAbsent(hex, () => parseHexArgb(hex));

  // 1. Zone fill base
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final zmi = (y * width + x) * 4;
      final zmA = zoneMapRgba[zmi + 3];
      final int fill;
      if (zmA == 0) {
        fill = 0xFFFFFFFF;
      } else {
        final zoneId = packArgb(zmA, zoneMapRgba[zmi], zoneMapRgba[zmi + 1], zoneMapRgba[zmi + 2]);
        var base = filledZones[zoneId] != null ? getArgb(filledZones[zoneId]!) : defaultFillArgb;
        if (activeZoneId != null && zoneId == activeZoneId) {
          base = blendArgb(base, activeTintArgb);
        }
        fill = base;
      }
      writeRgba(output, zmi, fill);
    }
  }

  // 2. Strokes
  for (final stroke in strokes) {
    _applyStroke(output, zoneMapRgba, width, height, stroke, getArgb);
  }

  // 3. Outline on top
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final i = (y * width + x) * 4;
      final outA = outlineRgba[i + 3];
      if (outA == 0) continue;
      final outR = outlineRgba[i];
      final outG = outlineRgba[i + 1];
      final outB = outlineRgba[i + 2];
      if ((outR + outG + outB) ~/ 3 < 210) {
        output[i] = outR;
        output[i + 1] = outG;
        output[i + 2] = outB;
        output[i + 3] = outA;
      }
    }
  }

  return output;
}

void _applyStroke(
  Uint8List output,
  Uint8List zoneMap,
  int width,
  int height,
  PaintStroke stroke,
  int Function(String) getArgb,
) {
  if (stroke.points.isEmpty) return;
  final color = getArgb(stroke.colorHex);
  final radius = stroke.brushRadiusPx.clamp(1.0, double.infinity);

  _stampCircle(output, zoneMap, width, height, stroke.zoneId, stroke.points.first, radius, color);

  for (var i = 1; i < stroke.points.length; i++) {
    final prev = stroke.points[i - 1];
    final curr = stroke.points[i];
    final dx = curr.x - prev.x;
    final dy = curr.y - prev.y;
    final dist = sqrt(dx * dx + dy * dy);
    final steps = (dist / max(1.0, radius * 0.45)).ceil().clamp(1, 4096);
    for (var step = 1; step <= steps; step++) {
      final t = step / steps;
      _stampCircle(
        output, zoneMap, width, height, stroke.zoneId,
        PaintPoint(prev.x + dx * t, prev.y + dy * t),
        radius, color,
      );
    }
  }
}

void _stampCircle(
  Uint8List output,
  Uint8List zoneMap,
  int width,
  int height,
  int? zoneId,
  PaintPoint center,
  double radius,
  int color,
) {
  final minX = (center.x - radius).round().clamp(0, width - 1);
  final maxX = (center.x + radius).round().clamp(0, width - 1);
  final minY = (center.y - radius).round().clamp(0, height - 1);
  final maxY = (center.y + radius).round().clamp(0, height - 1);
  final r2 = radius * radius;

  for (var y = minY; y <= maxY; y++) {
    for (var x = minX; x <= maxX; x++) {
      final dx = x - center.x;
      final dy = y - center.y;
      if (dx * dx + dy * dy > r2) continue;
      if (zoneId != null) {
        final zmi = (y * width + x) * 4;
        if (packArgb(zoneMap[zmi + 3], zoneMap[zmi], zoneMap[zmi + 1], zoneMap[zmi + 2]) != zoneId) {
          continue;
        }
      }
      writeRgba(output, (y * width + x) * 4, color);
    }
  }
}

// ---------------------------------------------------------------------------
// Color utilities (package-internal, used by canvas and editor screen)
// ---------------------------------------------------------------------------

int packArgb(int a, int r, int g, int b) =>
    ((a & 0xFF) << 24) | ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF);

int parseHexArgb(String hex) {
  final h = hex.startsWith('#') ? hex.substring(1) : hex;
  return int.parse(h.length == 6 ? 'FF$h' : h, radix: 16);
}

void writeRgba(Uint8List buf, int i, int argb) {
  buf[i] = (argb >> 16) & 0xFF;
  buf[i + 1] = (argb >> 8) & 0xFF;
  buf[i + 2] = argb & 0xFF;
  buf[i + 3] = (argb >> 24) & 0xFF;
}

int blendArgb(int base, int overlay) {
  final oa = ((overlay >> 24) & 0xFF) / 255.0;
  final ia = 1.0 - oa;
  return packArgb(
    255,
    ((((base >> 16) & 0xFF) * ia) + (((overlay >> 16) & 0xFF) * oa)).round().clamp(0, 255),
    ((((base >> 8) & 0xFF) * ia) + (((overlay >> 8) & 0xFF) * oa)).round().clamp(0, 255),
    (((base & 0xFF) * ia) + ((overlay & 0xFF) * oa)).round().clamp(0, 255),
  );
}

Color hexToFlutterColor(String hex) {
  final argb = parseHexArgb(hex);
  return Color(
    ((argb >> 24) & 0xFF) << 24 |
    ((argb >> 16) & 0xFF) << 16 |
    ((argb >> 8) & 0xFF) << 8 |
    (argb & 0xFF),
  );
}
