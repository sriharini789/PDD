import 'package:flutter/material.dart';

class AppColors {
  // Light Mode Colors
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryLight = Color(0xFFE8E0FF);
  static const Color primaryDark = Color(0xFF3700B3);
  static const Color backgroundLight = Color(0xFFFBFBFE);
  static const Color cardLight = Colors.white;
  static const Color textLightPrimary = Color(0xFF1E1E24);
  static const Color textLightSecondary = Color(0xFF757575);
  
  // Dark Mode Colors
  static const Color backgroundDark = Color(0xFF12121A);
  static const Color cardDark = Color(0xFF1E1E2C);
  static const Color textDarkPrimary = Color(0xFFF5F5FA);
  static const Color textDarkSecondary = Color(0xFFA0A0C0);
  static const Color primaryDarkAccent = Color(0xFFBB86FC);

  // Status & Accents
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA000);
  static const Color noteYellow = Color(0xFFFFF9C4);

  // Gradients
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF6200EE), Color(0xFF8B3CFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1E1E2C), Color(0xFF12121A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppBorderRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 20.0;
  static const double xl = 30.0;
}
