package com.colorin.app

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.colorin.core.model.Category
import com.colorin.core.model.DifficultyMode
import com.colorin.core.model.Drawing
import com.colorin.core.ui.ColorinTheme
import com.colorin.feature.catalog.CategoryListScreen
import com.colorin.feature.catalog.DrawingListScreen
import com.colorin.feature.catalog.LevelSelectionScreen
import com.colorin.feature.paint.PaintEditorScreen

@Composable
fun ColorinApp(
    container: AppContainer,
    modifier: Modifier = Modifier,
) {
    val navController = rememberNavController()
    val catalogRepository = remember(container) { container.catalogRepository }
    val paintProgressRepository = remember(container) { container.paintProgressRepository }

    ColorinTheme {
        NavHost(
            navController = navController,
            startDestination = "categories",
            modifier = modifier,
        ) {
            composable("categories") {
                CategoryListScreen(
                    categories = catalogRepository.getCategories(),
                    onCategoryClick = { category: Category ->
                        navController.navigate("drawings/${category.id}")
                    },
                )
            }

            composable(
                route = "drawings/{categoryId}",
                arguments = listOf(navArgument("categoryId") { type = NavType.StringType }),
            ) { entry ->
                val categoryId = entry.arguments?.getString("categoryId").orEmpty()
                val category = catalogRepository.getCategories().firstOrNull { it.id == categoryId } ?: return@composable
                DrawingListScreen(
                    category = category,
                    drawings = catalogRepository.getDrawings(categoryId),
                    onBack = { navController.popBackStack() },
                    onDrawingClick = { drawing: Drawing ->
                        navController.navigate("levels/${drawing.id}")
                    },
                )
            }

            composable(
                route = "levels/{drawingId}",
                arguments = listOf(navArgument("drawingId") { type = NavType.StringType }),
            ) { entry ->
                val drawingId = entry.arguments?.getString("drawingId").orEmpty()
                val drawing = catalogRepository.getDrawing(drawingId) ?: return@composable
                LevelSelectionScreen(
                    onBack = { navController.popBackStack() },
                    onLevelClick = { mode ->
                        navController.navigate("paint/${drawing.id}/${mode.name}")
                    },
                )
            }

            composable(
                route = "paint/{drawingId}/{mode}",
                arguments = listOf(
                    navArgument("drawingId") { type = NavType.StringType },
                    navArgument("mode") { type = NavType.StringType },
                ),
            ) { entry ->
                val drawingId = entry.arguments?.getString("drawingId").orEmpty()
                val modeName = entry.arguments?.getString("mode").orEmpty()
                val drawing = catalogRepository.getDrawing(drawingId) ?: return@composable
                val mode = runCatching { DifficultyMode.valueOf(modeName) }.getOrDefault(DifficultyMode.SIMPLE)
                val palette = catalogRepository.getPalette()
                val viewModel: PaintViewModel = viewModel(
                    key = "paint_${drawing.id}_${mode.name}",
                    factory = PaintViewModel.factory(
                        drawing = drawing,
                        mode = mode,
                        palette = palette,
                        repository = paintProgressRepository,
                    ),
                )

                PaintEditorScreen(
                    drawing = drawing,
                    palette = palette,
                    selectedColorHex = viewModel.state.selectedColorHex,
                    filledZones = viewModel.state.filledZones,
                    canUndo = viewModel.state.canUndo,
                    canRedo = viewModel.state.canRedo,
                    onBack = { navController.popBackStack() },
                    onClear = viewModel::clearDrawing,
                    onUndo = viewModel::undo,
                    onRedo = viewModel::redo,
                    onColorSelected = viewModel::selectColor,
                    onZoneTapped = viewModel::fillZone,
                )
            }
        }
    }
}
