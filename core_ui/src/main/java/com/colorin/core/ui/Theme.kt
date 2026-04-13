package com.colorin.core.ui

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.ColorScheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val LightColors: ColorScheme = lightColorScheme(
    primary = Color(0xFF1F6FEB),
    secondary = Color(0xFFF7B267),
    tertiary = Color(0xFF6BCB77),
    background = Color(0xFFFFFBF2),
    surface = Color(0xFFFFFFFF),
)

private val DarkColors: ColorScheme = darkColorScheme(
    primary = Color(0xFF8CB4FF),
    secondary = Color(0xFFFFD08A),
    tertiary = Color(0xFF8DE39B),
)

@Composable
fun ColorinTheme(
    content: @Composable () -> Unit,
) {
    MaterialTheme(
        colorScheme = if (isSystemInDarkTheme()) DarkColors else LightColors,
        content = content,
    )
}
