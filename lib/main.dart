import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: ResearchAIApp()));
}

class ResearchAIApp extends StatelessWidget {
  const ResearchAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, currentThemeMode, child) {
        return MaterialApp(
          title: 'Research AI Assistant',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentThemeMode,
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.routes,
          builder: (context, child) {
            // Add a global floating action button to easily toggle dark/light mode for testing
            return Scaffold(
              body: child,
              floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: FloatingActionButton.small(
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2C2C3D)
                      : Colors.white,
                  child: Icon(
                    Theme.of(context).brightness == Brightness.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    themeController.toggleTheme(!isDark);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
