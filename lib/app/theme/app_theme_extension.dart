import 'dart:ui';
import 'package:flutter/material.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final double spacing;
  final double borderRadius;
  final String fontPrimary;
  final String fontSecondary;

  const AppThemeExtension({
    required this.spacing,
    required this.borderRadius,
    required this.fontPrimary,
    required this.fontSecondary,
  });

  @override
  AppThemeExtension copyWith({
    double? spacing,
    double? borderRadius,
    String? fontPrimary,
    String? fontSecondary,
  }) {
    return AppThemeExtension(
      spacing: spacing ?? this.spacing,
      borderRadius: borderRadius ?? this.borderRadius,
      fontPrimary: fontPrimary ?? this.fontPrimary,
      fontSecondary: fontSecondary ?? this.fontSecondary,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      spacing: lerpDouble(spacing, other.spacing, t)!,
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
      fontPrimary: fontPrimary,
      fontSecondary: fontSecondary,
    );
  }
}
