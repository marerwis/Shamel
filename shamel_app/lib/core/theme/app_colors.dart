import 'package:flutter/material.dart';

/// Shamel Design System Colors - Extracted from Stitch designs
class AppColors {
  AppColors._();

  // ─── Primary ───
  static const Color primary = Color(0xFF00236F);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1E3A8A);
  static const Color onPrimaryContainer = Color(0xFF90A8FF);

  // ─── Secondary ───
  static const Color secondary = Color(0xFF006A61);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF86F2E4);
  static const Color onSecondaryContainer = Color(0xFF006F66);

  // ─── Tertiary ───
  static const Color tertiary = Color(0xFF4B1C00);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF6E2C00);
  static const Color onTertiaryContainer = Color(0xFFF39461);

  // ─── Error ───
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // ─── Surface ───
  static const Color surface = Color(0xFFFAF8FF);
  static const Color surfaceDim = Color(0xFFDAD9E1);
  static const Color surfaceBright = Color(0xFFFAF8FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF4F3FA);
  static const Color surfaceContainer = Color(0xFFEEEDF4);
  static const Color surfaceContainerHigh = Color(0xFFE9E7EF);
  static const Color surfaceContainerHighest = Color(0xFFE3E1E9);
  static const Color onSurface = Color(0xFF1A1B21);
  static const Color onSurfaceVariant = Color(0xFF444651);
  static const Color surfaceVariant = Color(0xFFE3E1E9);
  static const Color surfaceTint = Color(0xFF4059AA);

  // ─── Outline ───
  static const Color outline = Color(0xFF757682);
  static const Color outlineVariant = Color(0xFFC5C5D3);

  // ─── Inverse ───
  static const Color inverseSurface = Color(0xFF2F3036);
  static const Color inverseOnSurface = Color(0xFFF1F0F7);
  static const Color inversePrimary = Color(0xFFB6C4FF);

  // ─── Background ───
  static const Color background = Color(0xFFFAF8FF);
  static const Color onBackground = Color(0xFF1A1B21);

  // ─── Fixed Colors ───
  static const Color primaryFixed = Color(0xFFDCE1FF);
  static const Color onPrimaryFixed = Color(0xFF00164E);
  static const Color onPrimaryFixedVariant = Color(0xFF264191);
  static const Color primaryFixedDim = Color(0xFFB6C4FF);
  
  static const Color secondaryFixed = Color(0xFF89F5E7);
  static const Color onSecondaryFixed = Color(0xFF00201D);
  static const Color onSecondaryFixedVariant = Color(0xFF005049);
  static const Color secondaryFixedDim = Color(0xFF6BD8CB);
  
  static const Color tertiaryFixed = Color(0xFFFFDBCB);
  static const Color onTertiaryFixed = Color(0xFF341100);
  static const Color onTertiaryFixedVariant = Color(0xFF773205);
  static const Color tertiaryFixedDim = Color(0xFFFFB691);

  // ─── Gradient ───
  static const LinearGradient walletGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
  );
}
