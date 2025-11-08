import 'package:flutter/material.dart';

// Soft, beautiful background color
const Color softBackgroundColor = Color(0xFFF5F7FA); // Very light blue-gray
const Color cardBackgroundColor = Color(0xFFFFFFFF);
const Color primaryColor = Color(0xFF6366F1); // Indigo
const Color secondaryColor = Color(0xFF8B5CF6); // Purple

final lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  primaryColor: primaryColor,
  colorScheme: ColorScheme.light(
    primary: primaryColor,
    secondary: secondaryColor,
    surface: cardBackgroundColor,
    background: softBackgroundColor,
  ),
  scaffoldBackgroundColor: softBackgroundColor,
  cardColor: cardBackgroundColor,
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: cardBackgroundColor,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Color(0xFF1F2937)),
    bodyLarge: TextStyle(color: Color(0xFF111827)),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: softBackgroundColor,
    elevation: 0,
    foregroundColor: const Color(0xFF111827),
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  primaryColor: primaryColor,
  colorScheme: ColorScheme.dark(
    primary: primaryColor,
    secondary: secondaryColor,
    surface: const Color(0xFF1F2937),
    background: const Color(0xFF111827),
  ),
  scaffoldBackgroundColor: const Color(0xFF111827),
  cardColor: const Color(0xFF1F2937),
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: const Color(0xFF1F2937),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Color(0xFFE5E7EB)),
    bodyLarge: TextStyle(color: Color(0xFFF9FAFB)),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF111827),
    elevation: 0,
    foregroundColor: Color(0xFFF9FAFB),
  ),
);
