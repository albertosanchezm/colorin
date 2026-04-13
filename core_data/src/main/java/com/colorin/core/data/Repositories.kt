package com.colorin.core.data

import android.content.Context
import android.content.SharedPreferences
import com.colorin.core.model.Category
import com.colorin.core.model.DifficultyMode
import com.colorin.core.model.Drawing
import com.colorin.core.model.DrawingCanvasSpec
import com.colorin.core.model.PaintProgress
import com.colorin.core.model.PaletteColor
import org.json.JSONArray

interface CatalogRepository {
    fun getCategories(): List<Category>
    fun getDrawings(categoryId: String): List<Drawing>
    fun getDrawing(drawingId: String): Drawing?
    fun getPalette(): List<PaletteColor>
}

interface PaintProgressRepository {
    fun loadProgress(drawingId: String, mode: DifficultyMode): PaintProgress?
    fun saveProgress(progress: PaintProgress)
    fun clearProgress(drawingId: String, mode: DifficultyMode)
}

class AssetCatalogRepository(
    context: Context,
) : CatalogRepository {
    private val categories = loadCategories(context)
    private val drawings = loadDrawings(context, categories)

    private val palette = listOf(
        PaletteColor("red", "#FF6B6B", 0, true),
        PaletteColor("orange", "#F7B267", 1, true),
        PaletteColor("yellow", "#FFD93D", 2, true),
        PaletteColor("green", "#6BCB77", 3, true),
        PaletteColor("mint", "#4DDFB3", 4, true),
        PaletteColor("blue", "#4D96FF", 5, true),
        PaletteColor("navy", "#355CDE", 6, true),
        PaletteColor("purple", "#845EC2", 7, true),
        PaletteColor("pink", "#FF8FAB", 8, true),
        PaletteColor("brown", "#B08968", 9, true),
        PaletteColor("gray", "#ADB5BD", 10, true),
        PaletteColor("black", "#343A40", 11, true),
    )

    override fun getCategories(): List<Category> = categories.sortedBy { it.order }

    override fun getDrawings(categoryId: String): List<Drawing> =
        drawings.filter { it.categoryId == categoryId }.sortedBy { it.title }

    override fun getDrawing(drawingId: String): Drawing? = drawings.firstOrNull { it.id == drawingId }

    override fun getPalette(): List<PaletteColor> = palette.sortedBy { it.order }

    private fun loadCategories(context: Context): List<Category> = runCatching {
        val json = context.assets.open("catalog/categories.json").bufferedReader().use { it.readText() }
        val items = JSONArray(json)
        buildList {
            for (index in 0 until items.length()) {
                val item = items.getJSONObject(index)
                add(
                    Category(
                        id = item.optString("id", item.getString("assetsDirectory")),
                        name = item.getString("title"),
                        description = item.getString("description"),
                        backgroundAsset = item.getString("image"),
                        assetsDirectory = item.getString("assetsDirectory"),
                        order = item.optInt("order", index),
                    ),
                )
            }
        }.sortedBy { it.order }
    }.getOrElse {
        listOf(
            Category("dinosaurs", "Dinosaurios", "Explora dibujos de dinosaurios", "dinosaurs/dinosaurs-easy-1.png", "dinosaurs", 0),
        )
    }

    private fun loadDrawings(
        context: Context,
        categories: List<Category>,
    ): List<Drawing> {
        val assetManager = context.assets
        return categories.flatMap { category ->
            val files = runCatching { assetManager.list(category.assetsDirectory)?.toList().orEmpty() }
                .getOrDefault(emptyList())
            val fileSet = files.toSet()

            files
                .filter { file ->
                    val normalized = file.lowercase()
                    (normalized.endsWith(".png") || normalized.endsWith(".jpg") || normalized.endsWith(".jpeg")) &&
                        !normalized.endsWith("_zonemap.png")
                }
                .mapNotNull { file ->
                    val baseName = file.substringBeforeLast(".")
                    val zoneMapFile = "${baseName}_zonemap.png"
                    if (zoneMapFile !in fileSet) {
                        return@mapNotNull null
                    }

                    Drawing(
                        id = "${category.id}_$baseName",
                        categoryId = category.id,
                        title = baseName
                            .replace("-", " ")
                            .replace("_", " ")
                            .split(" ")
                            .filter { it.isNotBlank() }
                            .joinToString(" ") { token ->
                                token.replaceFirstChar { if (it.isLowerCase()) it.titlecase() else it.toString() }
                            },
                        outlineAsset = "${category.assetsDirectory}/$file",
                        zoneMapAsset = "${category.assetsDirectory}/$zoneMapFile",
                        difficultyTags = setOf(DifficultyMode.SIMPLE),
                        canvasSpec = DrawingCanvasSpec(1, 1),
                    )
                }
        }.sortedBy { it.title }
    }
}

class SharedPreferencesPaintProgressRepository(
    context: Context,
) : PaintProgressRepository {
    private val preferences: SharedPreferences =
        context.getSharedPreferences("colorin_paint_progress", Context.MODE_PRIVATE)

    override fun loadProgress(drawingId: String, mode: DifficultyMode): PaintProgress? {
        val serialized = preferences.getString(progressKey(drawingId, mode), null) ?: return null
        val timestamp = preferences.getLong(timestampKey(drawingId, mode), 0L)
        val filledZones = serialized.split("|")
            .filter { it.contains("=") }
            .associate { entry ->
                val parts = entry.split("=")
                parts[0].toInt() to parts[1]
            }
        return PaintProgress(drawingId, mode, filledZones, timestamp)
    }

    override fun saveProgress(progress: PaintProgress) {
        val serialized = progress.filledZones.entries
            .sortedBy { it.key }
            .joinToString(separator = "|") { "${it.key}=${it.value}" }
        preferences.edit()
            .putString(progressKey(progress.drawingId, progress.mode), serialized)
            .putLong(timestampKey(progress.drawingId, progress.mode), progress.lastModifiedEpochMs)
            .apply()
    }

    override fun clearProgress(drawingId: String, mode: DifficultyMode) {
        preferences.edit()
            .remove(progressKey(drawingId, mode))
            .remove(timestampKey(drawingId, mode))
            .apply()
    }

    private fun progressKey(drawingId: String, mode: DifficultyMode): String =
        "progress_${drawingId}_${mode.name.lowercase()}"

    private fun timestampKey(drawingId: String, mode: DifficultyMode): String =
        "progress_${drawingId}_${mode.name.lowercase()}_timestamp"
}
