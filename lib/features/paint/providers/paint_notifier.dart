import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/paint_progress_repository.dart';
import '../../../core/models/models.dart';

class PaintEditorState {
  const PaintEditorState({
    this.selectedColorHex = '#FF6B6B',
    this.filledZones = const {},
    this.strokes = const [],
    this.activeZoneId,
    this.canUndo = false,
    this.canRedo = false,
  });

  final String selectedColorHex;
  final Map<int, String> filledZones;
  final List<PaintStroke> strokes;
  final int? activeZoneId;
  final bool canUndo;
  final bool canRedo;

  PaintEditorState copyWith({
    String? selectedColorHex,
    Map<int, String>? filledZones,
    List<PaintStroke>? strokes,
    int? activeZoneId,
    bool clearActiveZone = false,
    bool? canUndo,
    bool? canRedo,
  }) =>
      PaintEditorState(
        selectedColorHex: selectedColorHex ?? this.selectedColorHex,
        filledZones: filledZones ?? this.filledZones,
        strokes: strokes ?? this.strokes,
        activeZoneId: clearActiveZone ? null : (activeZoneId ?? this.activeZoneId),
        canUndo: canUndo ?? this.canUndo,
        canRedo: canRedo ?? this.canRedo,
      );
}

class _Snapshot {
  const _Snapshot(this.filledZones, this.strokes);
  final Map<int, String> filledZones;
  final List<PaintStroke> strokes;
}

class PaintEditorNotifier extends StateNotifier<PaintEditorState> {
  PaintEditorNotifier({
    required this.repository,
    required this.drawingId,
    required this.mode,
    PaintProgress? savedProgress,
  }) : super(PaintEditorState(
          filledZones: savedProgress?.filledZones ?? const {},
          strokes: savedProgress?.strokes ?? const [],
        )) {
    _refreshUndoRedo();
  }

  final PaintProgressRepository repository;
  final String drawingId;
  final DifficultyMode mode;

  final _undoStack = ListQueue<_Snapshot>();
  final _redoStack = ListQueue<_Snapshot>();
  static const _maxHistory = 12;

  void selectColor(String hex) {
    state = state.copyWith(selectedColorHex: hex);
  }

  void fillZone(int zoneId) {
    _snapshot();
    final zones = Map<int, String>.from(state.filledZones)..[zoneId] = state.selectedColorHex;
    state = state.copyWith(filledZones: zones);
    _refreshUndoRedo();
    _save();
  }

  void selectZone(int zoneId) {
    state = state.copyWith(activeZoneId: zoneId);
  }

  void addStroke(PaintStroke stroke) {
    _snapshot();
    state = state.copyWith(strokes: [...state.strokes, stroke]);
    _refreshUndoRedo();
    _save();
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    _pushRedoSnapshot();
    final prev = _undoStack.removeLast();
    state = state.copyWith(filledZones: prev.filledZones, strokes: prev.strokes);
    _refreshUndoRedo();
    _save();
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    _pushUndoSnapshot();
    final next = _redoStack.removeLast();
    state = state.copyWith(filledZones: next.filledZones, strokes: next.strokes);
    _refreshUndoRedo();
    _save();
  }

  void clearDrawing() {
    _snapshot();
    state = state.copyWith(
      filledZones: const {},
      strokes: const [],
      clearActiveZone: true,
    );
    _refreshUndoRedo();
    _save();
  }

  void _snapshot() {
    _pushUndoSnapshot();
    _redoStack.clear();
  }

  void _pushUndoSnapshot() {
    _undoStack.addLast(_Snapshot(
      Map.unmodifiable(state.filledZones),
      List.unmodifiable(state.strokes),
    ));
    if (_undoStack.length > _maxHistory) _undoStack.removeFirst();
  }

  void _pushRedoSnapshot() {
    _redoStack.addLast(_Snapshot(
      Map.unmodifiable(state.filledZones),
      List.unmodifiable(state.strokes),
    ));
    if (_redoStack.length > _maxHistory) _redoStack.removeFirst();
  }

  void _refreshUndoRedo() {
    state = state.copyWith(
      canUndo: _undoStack.isNotEmpty,
      canRedo: _redoStack.isNotEmpty,
    );
  }

  void _save() {
    repository.saveProgress(PaintProgress(
      drawingId: drawingId,
      mode: mode,
      filledZones: state.filledZones,
      strokes: state.strokes,
      lastModifiedEpochMs: DateTime.now().millisecondsSinceEpoch,
    ));
  }
}
