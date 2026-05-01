import 'package:flutter/material.dart';

class AppTheme {
  static const _seed = Color(0xFF0F6F68);

  static ThemeData light() {
    return _theme(Brightness.light);
  }

  static ThemeData dark() {
    return _theme(Brightness.dark);
  }

  static ThemeData _theme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF0B1012)
          : const Color(0xFFF4F7F6),
      textTheme: Typography.material2021().black
          .copyWith(
            displaySmall: const TextStyle(fontSize: 34, height: 1.05),
            headlineSmall: const TextStyle(fontSize: 24, height: 1.16),
            titleLarge: const TextStyle(fontSize: 20, height: 1.18),
            titleMedium: const TextStyle(fontSize: 16, height: 1.25),
            titleSmall: const TextStyle(fontSize: 14, height: 1.25),
            bodyMedium: const TextStyle(fontSize: 13, height: 1.35),
            bodySmall: const TextStyle(fontSize: 12, height: 1.35),
            labelLarge: const TextStyle(fontSize: 13, height: 1.15),
            labelMedium: const TextStyle(fontSize: 11, height: 1.15),
          )
          .apply(
            bodyColor: isDark
                ? const Color(0xFFE7ECEA)
                : const Color(0xFF101817),
            displayColor: isDark
                ? const Color(0xFFE7ECEA)
                : const Color(0xFF101817),
          ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 62,
        backgroundColor: isDark
            ? const Color(0xFF111719)
            : const Color(0xFFF9FBFA),
        elevation: 0,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 23,
            color: states.contains(WidgetState.selected)
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.32),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.75),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
        ),
      ),
    );
  }
}
