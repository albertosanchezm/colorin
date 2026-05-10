import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../catalog/providers/catalog_providers.dart';
import '../providers/paint_notifier.dart';
import '../providers/paint_providers.dart';
import '../widgets/paint_canvas.dart';

class PaintEditorScreen extends ConsumerStatefulWidget {
  const PaintEditorScreen({
    super.key,
    required this.drawingId,
    required this.mode,
  });

  final String drawingId;
  final DifficultyMode mode;

  @override
  ConsumerState<PaintEditorScreen> createState() => _PaintEditorScreenState();
}

class _PaintEditorScreenState extends ConsumerState<PaintEditorScreen> {
  Uint8List? _outlineRgba;
  Uint8List? _zoneMapRgba;
  int _imgWidth = 0;
  int _imgHeight = 0;
  ui.Image? _composedImage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  @override
  void dispose() {
    _composedImage?.dispose();
    super.dispose();
  }

  Future<void> _loadAssets() async {
    final drawing = ref.read(drawingProvider(widget.drawingId));
    if (drawing == null) return;

    final (outRgba, outW, outH) = await _loadImageRgba('assets/${drawing.outlineAsset}');
    final (zmRgba, zmW, zmH) = await _loadImageRgba('assets/${drawing.zoneMapAsset}');

    if (!mounted) return;
    _outlineRgba = outRgba;
    _zoneMapRgba = zmRgba;
    _imgWidth = outW < zmW ? outW : zmW;
    _imgHeight = outH < zmH ? outH : zmH;

    await _recompose();
    if (mounted) setState(() => _loading = false);
  }

  Future<(Uint8List, int, int)> _loadImageRgba(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final img = frame.image;
    final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    final w = img.width;
    final h = img.height;
    img.dispose();
    return (byteData!.buffer.asUint8List(), w, h);
  }

  Future<void> _recompose() async {
    final outline = _outlineRgba;
    final zoneMap = _zoneMapRgba;
    if (outline == null || zoneMap == null || _imgWidth == 0) return;

    final state = ref.read(paintEditorProvider((widget.drawingId, widget.mode)));
    final image = await composePaintImage(
      outlineRgba: outline,
      zoneMapRgba: zoneMap,
      width: _imgWidth,
      height: _imgHeight,
      filledZones: state.filledZones,
      strokes: state.strokes,
      activeZoneId: state.activeZoneId,
    );

    if (mounted) {
      setState(() {
        _composedImage?.dispose();
        _composedImage = image;
      });
    }
  }

  void _onZoneTapped(int zoneId) {
    final notifier = ref.read(paintEditorProvider((widget.drawingId, widget.mode)).notifier);
    if (widget.mode == DifficultyMode.simple) {
      notifier.fillZone(zoneId);
    } else {
      notifier.selectZone(zoneId);
    }
    _recompose();
  }

  void _onStrokeComplete(PaintStroke stroke) {
    ref.read(paintEditorProvider((widget.drawingId, widget.mode)).notifier).addStroke(stroke);
    _recompose();
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(paintEditorProvider((widget.drawingId, widget.mode)));
    final drawing = ref.watch(drawingProvider(widget.drawingId));
    final palette = ref.watch(paletteProvider);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 500;
            return isWide
                ? _WideLayout(
                    drawing: drawing,
                    mode: widget.mode,
                    editorState: editorState,
                    palette: palette,
                    composedImage: _composedImage,
                    zoneMapRgba: _zoneMapRgba,
                    imgWidth: _imgWidth,
                    imgHeight: _imgHeight,
                    onZoneTapped: _onZoneTapped,
                    onStrokeComplete: _onStrokeComplete,
                    onColorSelected: (hex) {
                      ref.read(paintEditorProvider((widget.drawingId, widget.mode)).notifier)
                          .selectColor(hex);
                    },
                    onUndo: () {
                      ref.read(paintEditorProvider((widget.drawingId, widget.mode)).notifier).undo();
                      _recompose();
                    },
                    onRedo: () {
                      ref.read(paintEditorProvider((widget.drawingId, widget.mode)).notifier).redo();
                      _recompose();
                    },
                    onClear: () {
                      ref.read(paintEditorProvider((widget.drawingId, widget.mode)).notifier)
                          .clearDrawing();
                      _recompose();
                    },
                    onBack: () => context.pop(),
                  )
                : _NarrowLayout(
                    drawing: drawing,
                    mode: widget.mode,
                    editorState: editorState,
                    palette: palette,
                    composedImage: _composedImage,
                    zoneMapRgba: _zoneMapRgba,
                    imgWidth: _imgWidth,
                    imgHeight: _imgHeight,
                    onZoneTapped: _onZoneTapped,
                    onStrokeComplete: _onStrokeComplete,
                    onColorSelected: (hex) {
                      ref.read(paintEditorProvider((widget.drawingId, widget.mode)).notifier)
                          .selectColor(hex);
                    },
                    onUndo: () {
                      ref.read(paintEditorProvider((widget.drawingId, widget.mode)).notifier).undo();
                      _recompose();
                    },
                    onRedo: () {
                      ref.read(paintEditorProvider((widget.drawingId, widget.mode)).notifier).redo();
                      _recompose();
                    },
                    onClear: () {
                      ref.read(paintEditorProvider((widget.drawingId, widget.mode)).notifier)
                          .clearDrawing();
                      _recompose();
                    },
                    onBack: () => context.pop(),
                  );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Wide layout: canvas left | controls right
// ---------------------------------------------------------------------------

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.drawing,
    required this.mode,
    required this.editorState,
    required this.palette,
    required this.composedImage,
    required this.zoneMapRgba,
    required this.imgWidth,
    required this.imgHeight,
    required this.onZoneTapped,
    required this.onStrokeComplete,
    required this.onColorSelected,
    required this.onUndo,
    required this.onRedo,
    required this.onClear,
    required this.onBack,
  });

  final Drawing? drawing;
  final DifficultyMode mode;
  final PaintEditorState editorState;
  final List<PaletteColor> palette;
  final ui.Image? composedImage;
  final Uint8List? zoneMapRgba;
  final int imgWidth;
  final int imgHeight;
  final void Function(int) onZoneTapped;
  final void Function(PaintStroke) onStrokeComplete;
  final void Function(String) onColorSelected;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onClear;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Card(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: PaintCanvas(
                  composedImage: composedImage,
                  zoneMapRgba: zoneMapRgba,
                  zoneMapWidth: imgWidth,
                  zoneMapHeight: imgHeight,
                  selectedColorHex: editorState.selectedColorHex,
                  activeZoneId: editorState.activeZoneId,
                  mode: mode,
                  onZoneTapped: onZoneTapped,
                  onStrokeComplete: onStrokeComplete,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 200,
          child: _ControlsPanel(
            drawing: drawing,
            mode: mode,
            editorState: editorState,
            palette: palette,
            colorsPerRow: 3,
            onColorSelected: onColorSelected,
            onUndo: onUndo,
            onRedo: onRedo,
            onClear: onClear,
            onBack: onBack,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Narrow layout: header + canvas + controls stacked
// ---------------------------------------------------------------------------

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({
    required this.drawing,
    required this.mode,
    required this.editorState,
    required this.palette,
    required this.composedImage,
    required this.zoneMapRgba,
    required this.imgWidth,
    required this.imgHeight,
    required this.onZoneTapped,
    required this.onStrokeComplete,
    required this.onColorSelected,
    required this.onUndo,
    required this.onRedo,
    required this.onClear,
    required this.onBack,
  });

  final Drawing? drawing;
  final DifficultyMode mode;
  final PaintEditorState editorState;
  final List<PaletteColor> palette;
  final ui.Image? composedImage;
  final Uint8List? zoneMapRgba;
  final int imgWidth;
  final int imgHeight;
  final void Function(int) onZoneTapped;
  final void Function(PaintStroke) onStrokeComplete;
  final void Function(String) onColorSelected;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onClear;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EditorHeader(drawing: drawing, editorState: editorState, onBack: onBack),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Card(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: PaintCanvas(
                  composedImage: composedImage,
                  zoneMapRgba: zoneMapRgba,
                  zoneMapWidth: imgWidth,
                  zoneMapHeight: imgHeight,
                  selectedColorHex: editorState.selectedColorHex,
                  activeZoneId: editorState.activeZoneId,
                  mode: mode,
                  onZoneTapped: onZoneTapped,
                  onStrokeComplete: onStrokeComplete,
                ),
              ),
            ),
          ),
        ),
        _PaletteBar(
          palette: palette,
          selectedHex: editorState.selectedColorHex,
          colorsPerRow: 4,
          canUndo: editorState.canUndo,
          canRedo: editorState.canRedo,
          onColorSelected: onColorSelected,
          onUndo: onUndo,
          onRedo: onRedo,
          onClear: onClear,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Editor header
// ---------------------------------------------------------------------------

class _EditorHeader extends StatelessWidget {
  const _EditorHeader({required this.drawing, required this.editorState, required this.onBack});
  final Drawing? drawing;
  final PaintEditorState editorState;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: onBack,
          ),
          Expanded(
            child: Text(
              drawing?.title ?? '',
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: hexToFlutterColor(editorState.selectedColorHex),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black26, width: 2),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Controls panel (sidebar in wide layout)
// ---------------------------------------------------------------------------

class _ControlsPanel extends StatelessWidget {
  const _ControlsPanel({
    required this.drawing,
    required this.mode,
    required this.editorState,
    required this.palette,
    required this.colorsPerRow,
    required this.onColorSelected,
    required this.onUndo,
    required this.onRedo,
    required this.onClear,
    required this.onBack,
  });

  final Drawing? drawing;
  final DifficultyMode mode;
  final PaintEditorState editorState;
  final List<PaletteColor> palette;
  final int colorsPerRow;
  final void Function(String) onColorSelected;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onClear;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(0, 8, 8, 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: onBack,
                  iconSize: 20,
                ),
                Expanded(
                  child: Text(
                    drawing?.title ?? '',
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              _modeLabel(mode, editorState.activeZoneId),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Text(
              _controlsHint(mode, editorState.activeZoneId),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
              maxLines: 3,
            ),
            const Divider(height: 16),
            Expanded(
              child: _ColorGrid(
                palette: palette,
                selectedHex: editorState.selectedColorHex,
                colorsPerRow: colorsPerRow,
                onSelected: onColorSelected,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _IconBtn(
                  icon: Icons.undo_rounded,
                  enabled: editorState.canUndo,
                  onTap: onUndo,
                ),
                _IconBtn(
                  icon: Icons.redo_rounded,
                  enabled: editorState.canRedo,
                  onTap: onRedo,
                ),
                _IconBtn(
                  icon: Icons.delete_outline_rounded,
                  enabled: true,
                  onTap: onClear,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Palette bar (bottom in narrow layout)
// ---------------------------------------------------------------------------

class _PaletteBar extends StatelessWidget {
  const _PaletteBar({
    required this.palette,
    required this.selectedHex,
    required this.colorsPerRow,
    required this.canUndo,
    required this.canRedo,
    required this.onColorSelected,
    required this.onUndo,
    required this.onRedo,
    required this.onClear,
  });

  final List<PaletteColor> palette;
  final String selectedHex;
  final int colorsPerRow;
  final bool canUndo;
  final bool canRedo;
  final void Function(String) onColorSelected;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: _ColorGrid(
                palette: palette,
                selectedHex: selectedHex,
                colorsPerRow: colorsPerRow,
                onSelected: onColorSelected,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _IconBtn(icon: Icons.undo_rounded, enabled: canUndo, onTap: onUndo),
                _IconBtn(icon: Icons.redo_rounded, enabled: canRedo, onTap: onRedo),
                _IconBtn(
                    icon: Icons.delete_outline_rounded,
                    enabled: true,
                    onTap: onClear,
                    color: Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Color grid
// ---------------------------------------------------------------------------

class _ColorGrid extends StatelessWidget {
  const _ColorGrid({
    required this.palette,
    required this.selectedHex,
    required this.colorsPerRow,
    required this.onSelected,
  });

  final List<PaletteColor> palette;
  final String selectedHex;
  final int colorsPerRow;
  final void Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < palette.length; i += colorsPerRow) {
      final rowItems = palette.skip(i).take(colorsPerRow).toList();
      rows.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: rowItems.map((c) {
          final selected = c.hex.toLowerCase() == selectedHex.toLowerCase();
          return GestureDetector(
            onTap: () => onSelected(c.hex),
            child: Container(
              margin: const EdgeInsets.all(3),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: hexToFlutterColor(c.hex),
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? Colors.black : Colors.black26,
                  width: selected ? 3 : 1.5,
                ),
                boxShadow: selected
                    ? [BoxShadow(color: Colors.black.withAlpha(60), blurRadius: 4, spreadRadius: 1)]
                    : null,
              ),
            ),
          );
        }).toList(),
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}

// ---------------------------------------------------------------------------
// Small icon button
// ---------------------------------------------------------------------------

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: enabled ? onTap : null,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      iconSize: 22,
    );
  }
}

// ---------------------------------------------------------------------------
// Mode text helpers
// ---------------------------------------------------------------------------

String _modeLabel(DifficultyMode mode, int? activeZoneId) => switch (mode) {
      DifficultyMode.simple => 'Modo sencillo',
      DifficultyMode.medium =>
        activeZoneId == null ? 'Modo intermedio' : 'Zona activa seleccionada',
      DifficultyMode.advanced => 'Modo avanzado',
    };

String _controlsHint(DifficultyMode mode, int? activeZoneId) => switch (mode) {
      DifficultyMode.simple => 'Elige un color y toca la zona que quieras rellenar.',
      DifficultyMode.medium => activeZoneId == null
          ? 'Primero toca una zona para activarla, luego arrastra para pintar dentro.'
          : 'Tu pincel está recortado a la zona activa.',
      DifficultyMode.advanced => 'Arrastra el dedo sobre el lienzo para pintar libremente.',
    };
