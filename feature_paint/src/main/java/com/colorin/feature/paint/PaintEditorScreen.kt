package com.colorin.feature.paint

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color.parseColor
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.Alignment
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.colorin.core.model.Drawing
import com.colorin.core.model.PaletteColor
import kotlin.math.roundToInt

@Composable
fun PaintEditorScreen(
    drawing: Drawing,
    palette: List<PaletteColor>,
    selectedColorHex: String,
    filledZones: Map<Int, String>,
    canUndo: Boolean,
    canRedo: Boolean,
    onBack: () -> Unit,
    onClear: () -> Unit,
    onUndo: () -> Unit,
    onRedo: () -> Unit,
    onColorSelected: (String) -> Unit,
    onZoneTapped: (Int) -> Unit,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current
    val outlineBitmap = remember(drawing.outlineAsset) {
        loadAssetBitmap(context, drawing.outlineAsset)
    }
    val zoneMapBitmap = remember(drawing.zoneMapAsset) {
        loadAssetBitmap(context, drawing.zoneMapAsset)
    }
    val composedBitmap = remember(outlineBitmap, zoneMapBitmap, filledZones) {
        composePaintBitmap(
            outlineBitmap = outlineBitmap,
            zoneMapBitmap = zoneMapBitmap,
            filledZones = filledZones,
        )
    }

    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(horizontal = 12.dp, vertical = 8.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            IconButton(onClick = onBack) {
                Text("<", style = MaterialTheme.typography.headlineSmall)
            }
        }

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f),
            horizontalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            Card(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxHeight(),
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(Color.White)
                        .padding(16.dp),
                ) {
                    if (composedBitmap != null && zoneMapBitmap != null) {
                        BoxWithConstraints(
                            modifier = Modifier.fillMaxSize(),
                        ) {
                            val imageAspectRatio = composedBitmap.width.toFloat() / composedBitmap.height.toFloat()
                            val containerAspectRatio = constraints.maxWidth.toFloat() / constraints.maxHeight.toFloat()
                            val canvasModifier = if (imageAspectRatio > containerAspectRatio) {
                                Modifier
                                    .fillMaxWidth()
                                    .aspectRatio(imageAspectRatio)
                            } else {
                                Modifier
                                    .fillMaxHeight()
                                    .aspectRatio(imageAspectRatio)
                            }

                            Box(
                                modifier = Modifier.fillMaxSize(),
                            ) {
                                Canvas(
                                    modifier = canvasModifier
                                        .align(androidx.compose.ui.Alignment.Center)
                                        .border(2.dp, MaterialTheme.colorScheme.outline, MaterialTheme.shapes.large)
                                        .background(Color.White)
                                        .pointerInput(zoneMapBitmap) {
                                            detectTapGestures { offset ->
                                                val zoneId = zoneIdAtPoint(
                                                    offset = offset,
                                                    canvasWidth = size.width.toFloat(),
                                                    canvasHeight = size.height.toFloat(),
                                                    bitmap = zoneMapBitmap,
                                                )
                                                if (zoneId != null) {
                                                    onZoneTapped(zoneId)
                                                }
                                            }
                                        },
                                ) {
                                    drawImage(
                                        image = composedBitmap.asImageBitmap(),
                                        dstSize = IntSize(size.width.roundToInt(), size.height.roundToInt()),
                                    )
                                }
                            }
                        }
                    } else {
                        Text(
                            text = "No se pudieron cargar los assets del dibujo.",
                            style = MaterialTheme.typography.bodyMedium,
                        )
                    }
                }
            }

            Card(
                modifier = Modifier
                    .width(132.dp)
                    .fillMaxHeight(),
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(10.dp),
                    verticalArrangement = Arrangement.SpaceBetween,
                    horizontalAlignment = Alignment.CenterHorizontally,
                ) {
                    Column(
                        modifier = Modifier.fillMaxWidth(),
                        verticalArrangement = Arrangement.spacedBy(10.dp),
                    ) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceEvenly,
                        ) {
                            ActionIconButton(
                                label = "↶",
                                enabled = canUndo,
                                onClick = onUndo,
                            )
                            ActionIconButton(
                                label = "↷",
                                enabled = canRedo,
                                onClick = onRedo,
                            )
                        }

                        Column(
                            modifier = Modifier.fillMaxWidth(),
                            verticalArrangement = Arrangement.spacedBy(8.dp),
                        ) {
                            palette.chunked(2).forEach { rowColors ->
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceEvenly,
                                ) {
                                    rowColors.forEach { color ->
                                        val isSelected = color.hex == selectedColorHex
                                        Box(
                                            modifier = Modifier
                                                .padding(4.dp)
                                                .size(if (isSelected) 46.dp else 40.dp)
                                                .border(
                                                    width = if (isSelected) 3.dp else 1.dp,
                                                    color = if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outline,
                                                    shape = MaterialTheme.shapes.small,
                                                )
                                                .background(Color(parseColor(color.hex)), MaterialTheme.shapes.small)
                                                .pointerInput(color.hex) {
                                                    detectTapGestures { onColorSelected(color.hex) }
                                                },
                                        )
                                    }
                                    if (rowColors.size == 1) {
                                        Box(modifier = Modifier.size(40.dp))
                                    }
                                }
                            }
                        }
                    }

                    OutlinedButton(
                        onClick = onClear,
                        modifier = Modifier.fillMaxWidth(),
                    ) {
                        Text("Limpiar")
                    }
                }
            }
        }
    }
}

@Composable
private fun ActionIconButton(
    label: String,
    enabled: Boolean,
    onClick: () -> Unit,
) {
    Card(
        colors = CardDefaults.cardColors(
            containerColor = if (enabled) {
                MaterialTheme.colorScheme.surfaceVariant
            } else {
                MaterialTheme.colorScheme.surface
            },
        ),
    ) {
        IconButton(
            onClick = onClick,
            enabled = enabled,
        ) {
            Text(
                text = label,
                style = MaterialTheme.typography.titleLarge,
                color = if (enabled) {
                    MaterialTheme.colorScheme.onSurface
                } else {
                    MaterialTheme.colorScheme.outline
                },
            )
        }
    }
}

private fun loadAssetBitmap(
    context: Context,
    assetPath: String,
): Bitmap? = runCatching {
    context.assets.open(assetPath).use { input ->
        BitmapFactory.decodeStream(input)
    }
}.getOrNull()

private fun composePaintBitmap(
    outlineBitmap: Bitmap?,
    zoneMapBitmap: Bitmap?,
    filledZones: Map<Int, String>,
): Bitmap? {
    if (outlineBitmap == null || zoneMapBitmap == null) {
        return null
    }

    val width = minOf(outlineBitmap.width, zoneMapBitmap.width)
    val height = minOf(outlineBitmap.height, zoneMapBitmap.height)
    val output = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
    val defaultColor = parseColor("#FFF8E7")

    for (y in 0 until height) {
        for (x in 0 until width) {
            val zonePixel = zoneMapBitmap.getPixel(x, y)
            val outlinePixel = outlineBitmap.getPixel(x, y)
            val outlineAlpha = android.graphics.Color.alpha(outlinePixel)
            val outlineBrightness = (
                android.graphics.Color.red(outlinePixel) +
                    android.graphics.Color.green(outlinePixel) +
                    android.graphics.Color.blue(outlinePixel)
                ) / 3

            val outputPixel = when {
                outlineAlpha > 0 && outlineBrightness < 210 -> outlinePixel
                android.graphics.Color.alpha(zonePixel) == 0 -> android.graphics.Color.WHITE
                else -> {
                    val fillHex = filledZones[zonePixel]
                    if (fillHex != null) parseColor(fillHex) else defaultColor
                }
            }

            output.setPixel(x, y, outputPixel)
        }
    }

    return output
}

private fun zoneIdAtPoint(
    offset: Offset,
    canvasWidth: Float,
    canvasHeight: Float,
    bitmap: Bitmap,
): Int? {
    if (canvasWidth <= 0f || canvasHeight <= 0f) {
        return null
    }

    val x = ((offset.x / canvasWidth) * bitmap.width)
        .roundToInt()
        .coerceIn(0, bitmap.width - 1)
    val y = ((offset.y / canvasHeight) * bitmap.height)
        .roundToInt()
        .coerceIn(0, bitmap.height - 1)
    val zonePixel = bitmap.getPixel(x, y)

    return if (android.graphics.Color.alpha(zonePixel) == 0) null else zonePixel
}
