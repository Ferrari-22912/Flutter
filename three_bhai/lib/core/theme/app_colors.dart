import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color flame = Color(0xFFFF8A1F);
  static const Color ember = Color(0xFFFF4E1B);
  static const Color deep = Color(0xFFD72E0F);
  static const Color ink = Color(0xFF2B1A14);
  static const Color muted = Color(0xFF8A766C);
  static const Color surface = Color(0xFFFFFAF6);
  static const Color outline = Color(0xFFF0DDD2);
  static const Color error = Color(0xFFB3261E);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [flame, ember, deep],
  );
}
