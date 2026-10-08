import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:three_bhai/core/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.ember,
      primary: AppColors.ember,
      surface: AppColors.surface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: _textTheme(),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: AppColors.muted),
        prefixIconColor: AppColors.muted,
        suffixIconColor: AppColors.muted,
        border: _border(AppColors.outline),
        enabledBorder: _border(AppColors.outline),
        focusedBorder: _border(AppColors.ember, width: 2),
        errorBorder: _border(AppColors.error),
        focusedErrorBorder: _border(AppColors.error, width: 2),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1.5}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  static TextTheme _textTheme() {
    final body = GoogleFonts.dmSansTextTheme().apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );

    TextStyle heading(TextStyle? base, double size) =>
        GoogleFonts.bricolageGrotesque(
          textStyle: base,
          fontSize: size,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: AppColors.ink,
        );

    return body.copyWith(
      displaySmall: heading(body.displaySmall, 40),
      headlineMedium: heading(body.headlineMedium, 30),
      headlineSmall: heading(body.headlineSmall, 24),
      titleLarge: heading(body.titleLarge, 20),
    );
  }
}
