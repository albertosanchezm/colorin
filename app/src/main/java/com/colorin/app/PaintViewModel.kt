package com.colorin.app

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.colorin.core.data.PaintProgressRepository
import com.colorin.core.model.DifficultyMode
import com.colorin.core.model.Drawing
import com.colorin.core.model.PaintProgress
import com.colorin.core.model.PaletteColor

data class PaintEditorState(
    val selectedColorHex: String,
    val filledZones: Map<Int, String>,
    val canUndo: Boolean,
    val canRedo: Boolean,
)

private data class PaintAction(
    val zoneId: Int,
    val previousColorHex: String?,
    val newColorHex: String,
)

class PaintViewModel(
    private val drawing: Drawing,
    private val mode: DifficultyMode,
    palette: List<PaletteColor>,
    private val repository: PaintProgressRepository,
) : ViewModel() {
    var state by mutableStateOf(
        PaintEditorState(
            selectedColorHex = palette.firstOrNull()?.hex ?: "#4D96FF",
            filledZones = emptyMap(),
            canUndo = false,
            canRedo = false,
        ),
    )
        private set

    private val undoStack = ArrayDeque<PaintAction>()
    private val redoStack = ArrayDeque<PaintAction>()

    fun selectColor(colorHex: String) {
        state = state.copy(selectedColorHex = colorHex)
    }

    fun fillZone(zoneId: Int) {
        val previousColorHex = state.filledZones[zoneId]
        if (previousColorHex == state.selectedColorHex) {
            return
        }

        val updated = state.filledZones.toMutableMap().apply {
            put(zoneId, state.selectedColorHex)
        }
        undoStack.addLast(
            PaintAction(
                zoneId = zoneId,
                previousColorHex = previousColorHex,
                newColorHex = state.selectedColorHex,
            ),
        )
        while (undoStack.size > 5) {
            undoStack.removeFirst()
        }
        redoStack.clear()
        updateFilledZones(updated)
    }

    fun undo() {
        val action = undoStack.removeLastOrNull() ?: return
        val updated = state.filledZones.toMutableMap().apply {
            if (action.previousColorHex == null) {
                remove(action.zoneId)
            } else {
                put(action.zoneId, action.previousColorHex)
            }
        }
        redoStack.addLast(action)
        updateFilledZones(updated)
    }

    fun redo() {
        val action = redoStack.removeLastOrNull() ?: return
        val updated = state.filledZones.toMutableMap().apply {
            put(action.zoneId, action.newColorHex)
        }
        undoStack.addLast(action)
        while (undoStack.size > 5) {
            undoStack.removeFirst()
        }
        updateFilledZones(updated)
    }

    fun clearDrawing() {
        undoStack.clear()
        redoStack.clear()
        state = state.copy(
            filledZones = emptyMap(),
            canUndo = false,
            canRedo = false,
        )
        repository.clearProgress(drawing.id, mode)
    }

    private fun updateFilledZones(filledZones: Map<Int, String>) {
        state = state.copy(
            filledZones = filledZones,
            canUndo = undoStack.isNotEmpty(),
            canRedo = redoStack.isNotEmpty(),
        )
        repository.saveProgress(
            PaintProgress(
                drawingId = drawing.id,
                mode = mode,
                filledZones = filledZones,
                lastModifiedEpochMs = System.currentTimeMillis(),
            ),
        )
    }

    companion object {
        fun factory(
            drawing: Drawing,
            mode: DifficultyMode,
            palette: List<PaletteColor>,
            repository: PaintProgressRepository,
        ): ViewModelProvider.Factory = object : ViewModelProvider.Factory {
            @Suppress("UNCHECKED_CAST")
            override fun <T : ViewModel> create(modelClass: Class<T>): T {
                return PaintViewModel(
                    drawing = drawing,
                    mode = mode,
                    palette = palette,
                    repository = repository,
                ) as T
            }
        }
    }
}
