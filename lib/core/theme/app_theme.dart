import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() => _theme(
        brightness: Brightness.light,
        seed: const Color(0xFF1A7F64),
        surface: const Color(0xFFF7FAF9),
      );

  static ThemeData dark() => _theme(
        brightness: Brightness.dark,
        seed: const Color(0xFF72D6B6),
        surface: const Color(0xFF101716),
      );

  static ThemeData _theme({
    required Brightness brightness,
    required Color seed,
    required Color surface,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      surface: surface,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }
}
