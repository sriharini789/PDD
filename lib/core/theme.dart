import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primaryDark,
        surface: AppColors.backgroundLight,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 2,
        shadowColor: Colors.black.withAlpha(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.textLightPrimary, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: AppColors.textLightPrimary, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: AppColors.textLightPrimary),
        bodyMedium: TextStyle(color: AppColors.textLightSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textLightSecondary),
        hintStyle: const TextStyle(color: AppColors.textLightSecondary),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: AppColors.primary,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDarkAccent,
        secondary: AppColors.primaryLight,
        surface: AppColors.backgroundDark,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: AppColors.textDarkPrimary),
        bodyMedium: TextStyle(color: AppColors.textDarkSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF242436),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          borderSide: const BorderSide(color: AppColors.primaryDarkAccent, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textDarkSecondary),
        hintStyle: const TextStyle(color: AppColors.textDarkSecondary),
      ),
    );
  }
}

// Global Theme Controller
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.light);

  bool get isDarkMode => value == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    value = isOn ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeController = ThemeController();
