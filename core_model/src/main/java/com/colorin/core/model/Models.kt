package com.colorin.core.model

data class Category(
    val id: String,
    val name: String,
    val description: String,
    val backgroundAsset: String,
    val assetsDirectory: String,
    val order: Int,
)

data class Drawing(
    val id: String,
    val categoryId: String,
    val title: String,
    val outlineAsset: String,
    val zoneMapAsset: String,
    val difficultyTags: Set<DifficultyMode>,
    val canvasSpec: DrawingCanvasSpec,
)

data class PaintSession(
    val id: String,
    val drawingId: String,
    val mode: DifficultyMode,
    val lastModifiedEpochMs: Long,
    val snapshotPath: String?,
    val actionsPath: String?,
)

data class PaletteColor(
    val id: String,
    val hex: String,
    val order: Int,
    val isDefault: Boolean,
)

data class DrawingCanvasSpec(
    val columns: Int,
    val rows: Int,
)

data class PaintProgress(
    val drawingId: String,
    val mode: DifficultyMode,
    val filledZones: Map<Int, String>,
    val lastModifiedEpochMs: Long,
)

enum class DifficultyMode {
    SIMPLE,
    MEDIUM,
    ADVANCED,
}
