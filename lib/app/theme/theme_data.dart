import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_theme_extension.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.backgroundLight,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    background: AppColors.backgroundLight,
    surface: AppColors.surfaceLight,
    error: AppColors.error,
    onPrimary: AppColors.onPrimary,
    onSecondary: AppColors.onSecondary,
    onBackground: AppColors.onBackgroundLight,
    onSurface: AppColors.onSurfaceLight,
    onError: AppColors.onError,
  ),
  extensions: const [
    AppThemeExtension(
      spacing: 16,
      borderRadius: 12,
      fontPrimary: 'SaintRegus',
      fontSecondary: 'Campton',
    )
  ],
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceLight,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.backgroundDark,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    error: AppColors.error,
    onPrimary: AppColors.onPrimary,
    onSecondary: AppColors.onSecondary,
    onBackground: AppColors.onBackgroundDark,
    onSurface: AppColors.onSurfaceDark,
    onError: AppColors.onError,
  ),
  extensions: const [
    AppThemeExtension(
      spacing: 16,
      borderRadius: 12,
      fontPrimary: 'SaintRegus',
      fontSecondary: 'Campton',
    )
  ],
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceDark,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
);
