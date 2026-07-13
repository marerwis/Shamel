import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.ibmPlexSansArabicTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.inverseOnSurface,
        inversePrimary: AppColors.inversePrimary,
        surfaceTint: AppColors.surfaceTint,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontSize: 48, fontWeight: FontWeight.w700, height: 1.25, letterSpacing: -0.02,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          fontSize: 32, fontWeight: FontWeight.w700, height: 1.25,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontSize: 30, fontWeight: FontWeight.w600, height: 1.27,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 24, fontWeight: FontWeight.w600, height: 1.33,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 18, fontWeight: FontWeight.w400, height: 1.56,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 16, fontWeight: FontWeight.w400, height: 1.5,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 14, fontWeight: FontWeight.w500, height: 1.43, letterSpacing: 0.01,
        ),
        labelMedium: baseTextTheme.labelMedium?.copyWith(
          fontSize: 14, fontWeight: FontWeight.w500, height: 1.43, letterSpacing: 0.01,
        ),
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          fontSize: 12, fontWeight: FontWeight.w600, height: 1.33, letterSpacing: 0.05,
        ),
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        centerTitle: true,
        titleTextStyle: baseTextTheme.headlineMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.onSurfaceVariant),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: baseTextTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: baseTextTheme.labelSmall,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.secondaryContainer,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return baseTextTheme.labelSmall?.copyWith(
              color: AppColors.onSecondaryContainer,
              fontWeight: FontWeight.w700,
            );
          }
          return baseTextTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant);
        }),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.outlineVariant.withValues(alpha: 0.3),
        thickness: 1,
      ),
    );
  }
}
