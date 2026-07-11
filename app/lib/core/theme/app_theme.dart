import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  // ==========================================================
  // Tema Rosa/Light
  // ----------------------------------------------------------
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.lightPrimary,
      brightness: Brightness.light,
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      surface: AppColors.lightSurface,
      onPrimary: AppColors.lightText,
      onSecondary: AppColors.lightText,
      onSurface: AppColors.lightText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightText,
        elevation: 0,
        centerTitle: true,
      ),

      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.lightBackground,
      ),

      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.lightAccent,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            color: AppColors.lightText,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: WidgetStateProperty.all(
          const IconThemeData(
            color: AppColors.lightText,
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightButtonBackground,
        foregroundColor: AppColors.lightButtonForeground,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.lightButtonBackground,
          foregroundColor: AppColors.lightButtonForeground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        labelStyle: const TextStyle(
          color: AppColors.lightTextSecondary,
        ),
        hintStyle: const TextStyle(
          color: AppColors.lightTextSecondary,
        ),
        prefixIconColor: AppColors.lightText,
        suffixIconColor: AppColors.lightText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.lightText,
            width: 1.5,
          ),
        ),
      ),

      dividerColor: AppColors.lightText.withValues(alpha: 0.18),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.lightText,
          fontSize: 42,
          fontWeight: FontWeight.w800,
        ),
        headlineSmall: TextStyle(
          color: AppColors.lightText,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: AppColors.lightText,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppColors.lightText,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.lightText,
        ),
        bodyMedium: TextStyle(
          color: AppColors.lightTextSecondary,
        ),
      ),
    );
  }


  // ==========================================================
  // Tema Rosa/Dark
  // ----------------------------------------------------------
  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.darkPrimary,
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      surface: AppColors.darkSurface,
      onPrimary: AppColors.darkButtonForeground,
      onSecondary: AppColors.darkText,
      onSurface: AppColors.darkText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        centerTitle: true,
      ),

      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.darkSurface,
      ),

      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.darkAccent,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: WidgetStateProperty.all(
          const IconThemeData(
            color: AppColors.darkText,
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkButtonBackground,
        foregroundColor: AppColors.darkButtonForeground,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.darkButtonBackground,
          foregroundColor: AppColors.darkButtonForeground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        labelStyle: const TextStyle(
          color: AppColors.darkTextSecondary,
        ),
        hintStyle: const TextStyle(
          color: AppColors.darkTextSecondary,
        ),
        prefixIconColor: AppColors.darkText,
        suffixIconColor: AppColors.darkText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.darkPrimary,
            width: 1.5,
          ),
        ),
      ),

      dividerColor: AppColors.darkText.withValues(alpha: 0.18),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.darkText,
          fontSize: 42,
          fontWeight: FontWeight.w800,
        ),
        headlineSmall: TextStyle(
          color: AppColors.darkText,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: AppColors.darkText,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppColors.darkText,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.darkText,
        ),
        bodyMedium: TextStyle(
          color: AppColors.darkTextSecondary,
        ),
      ),
    );
  }
}