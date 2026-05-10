import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF6BCBFF),
    secondary: Color(0xFFFFD93D),
    tertiary: Color(0xFF6EE7B7),
    surface: Color(0xFFFFF4E6),
    onSurface: Color(0xFF374151),
    outline: Color(0xFFE5E7EB),
  ),
  scaffoldBackgroundColor: const Color(0xFFFFF9F2),
  cardTheme: const CardThemeData(
    color: Color(0xFFFFF4E6),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
    ),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      color: Color(0xFF374151),
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: Color(0xFF374151),
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      color: Color(0xFF374151),
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: Color(0xFF374151),
    ),
    bodyLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xFF374151),
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFF374151),
    ),
  ),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF8CD8FF),
    secondary: Color(0xFFFFE680),
    tertiary: Color(0xFF8BE7C9),
    surface: Color(0xFF1F2937),
    onSurface: Color(0xFFF3F4F6),
  ),
  scaffoldBackgroundColor: const Color(0xFF111827),
);

const categoryAccentColors = [
  Color(0xFFF7B267),
  Color(0xFFFF6B6B),
  Color(0xFF845EC2),
  Color(0xFF4DDFB3),
  Color(0xFF4D96FF),
];
