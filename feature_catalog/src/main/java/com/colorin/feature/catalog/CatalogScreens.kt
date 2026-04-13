package com.colorin.feature.catalog

import android.content.Context
import android.graphics.BitmapFactory
import androidx.compose.foundation.clickable
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items as lazyItems
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items as gridItems
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.colorin.core.model.Category
import com.colorin.core.model.DifficultyMode
import com.colorin.core.model.Drawing

@Composable
fun CategoryListScreen(
    categories: List<Category>,
    onCategoryClick: (Category) -> Unit,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Text(
                text = "Elige una tematica",
                style = MaterialTheme.typography.headlineMedium,
            )
            Text(
                text = "Desliza horizontalmente para ver mas categorias.",
                style = MaterialTheme.typography.bodyMedium,
            )
        }

        BoxWithConstraints(modifier = Modifier.fillMaxSize()) {
            val cardWidth = (maxWidth - 32.dp) / 3
            LazyRow(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(horizontal = 4.dp),
                horizontalArrangement = Arrangement.spacedBy(16.dp),
            ) {
                lazyItems(categories, key = { it.id }) { category ->
                    val backgroundBitmap = remember(category.backgroundAsset) {
                        loadAssetBitmap(context, category.backgroundAsset)
                    }
                    Card(
                        modifier = Modifier
                            .widthIn(min = cardWidth, max = cardWidth)
                            .fillMaxHeight()
                            .clickable { onCategoryClick(category) },
                        colors = CardDefaults.cardColors(
                            containerColor = MaterialTheme.colorScheme.surfaceVariant,
                        ),
                    ) {
                        Box(modifier = Modifier.fillMaxSize()) {
                            if (backgroundBitmap != null) {
                                Image(
                                    bitmap = backgroundBitmap.asImageBitmap(),
                                    contentDescription = category.name,
                                    contentScale = ContentScale.Crop,
                                    modifier = Modifier.fillMaxSize(),
                                )
                            }

                            Box(
                                modifier = Modifier
                                    .fillMaxSize()
                                    .background(Color.White.copy(alpha = 0.72f)),
                            )

                            Column(
                                modifier = Modifier
                                    .fillMaxSize()
                                    .padding(20.dp),
                                verticalArrangement = Arrangement.spacedBy(8.dp),
                            ) {
                                Text(text = category.name, style = MaterialTheme.typography.titleLarge)
                                Text(
                                    text = category.description,
                                    style = MaterialTheme.typography.bodyMedium,
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

private fun loadAssetBitmap(
    context: Context,
    assetPath: String,
) = runCatching {
    context.assets.open(assetPath).use { input ->
        BitmapFactory.decodeStream(input)
    }
}.getOrNull()

@Composable
fun DrawingListScreen(
    category: Category,
    drawings: List<Drawing>,
    onBack: () -> Unit,
    onDrawingClick: (Drawing) -> Unit,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
            TextButton(onClick = onBack) {
                Text("Volver")
            }
            Text(text = category.name, style = MaterialTheme.typography.headlineMedium)
        }

        LazyVerticalGrid(
            modifier = Modifier.fillMaxSize(),
            columns = GridCells.Fixed(3),
            verticalArrangement = Arrangement.spacedBy(12.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            gridItems(drawings, key = { it.id }) { drawing ->
                val previewBitmap = remember(drawing.outlineAsset) {
                    loadAssetBitmap(context, drawing.outlineAsset)
                }
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .aspectRatio(1f)
                        .clickable { onDrawingClick(drawing) },
                ) {
                    Box(modifier = Modifier.fillMaxSize()) {
                        if (previewBitmap != null) {
                            Image(
                                bitmap = previewBitmap.asImageBitmap(),
                                contentDescription = drawing.title,
                                contentScale = ContentScale.Crop,
                                modifier = Modifier.fillMaxSize(),
                            )
                        } else {
                            Box(
                                modifier = Modifier
                                    .fillMaxSize()
                                    .background(MaterialTheme.colorScheme.surfaceVariant),
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun LevelSelectionScreen(
    onBack: () -> Unit,
    onLevelClick: (DifficultyMode) -> Unit,
    modifier: Modifier = Modifier,
) {
    val levelCards = listOf(
        Triple(
            DifficultyMode.SIMPLE,
            "FACIL",
            "Ideal para ninos de hasta 5 anos. Solo hay que hacer click y se autocolorea.",
        ),
        Triple(
            DifficultyMode.MEDIUM,
            "INTERMEDIO",
            "Ideal para ninos que ya controlan mejor el dedo. Se colorea dentro de una zona concreta.",
        ),
        Triple(
            DifficultyMode.ADVANCED,
            "AVANZADO",
            "Pensado para ninos mayores. Permite colorear libremente con mas precision.",
        ),
    )

    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        TextButton(onClick = onBack) {
            Text("Volver")
        }

        Text(
            text = "Elige un nivel",
            style = MaterialTheme.typography.headlineMedium,
        )

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f),
            horizontalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            levelCards.forEach { (mode, title, description) ->
                Card(
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxHeight()
                        .widthIn(min = 180.dp)
                        .clickable { onLevelClick(mode) },
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surfaceVariant,
                    ),
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(20.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp),
                    ) {
                        Text(
                            text = title,
                            style = MaterialTheme.typography.titleLarge,
                        )
                        Text(
                            text = description,
                            style = MaterialTheme.typography.bodyMedium,
                        )
                    }
                }
            }
        }
    }
}
