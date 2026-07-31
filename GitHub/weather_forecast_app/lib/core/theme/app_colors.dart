import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Light — coastal sky
  static const Color lightPrimary = Color(0xFF0B6E99);
  static const Color lightSecondary = Color(0xFF1A9B8E);
  static const Color lightAccent = Color(0xFFE8A838);
  static const Color lightBackground = Color(0xFFF0F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF0F2433);
  static const Color lightError = Color(0xFFC62828);

  // Dark — midnight navy
  static const Color darkPrimary = Color(0xFF4DB8E0);
  static const Color darkSecondary = Color(0xFF3DC9B8);
  static const Color darkAccent = Color(0xFFF0B84A);
  static const Color darkBackground = Color(0xFF0A1622);
  static const Color darkSurface = Color(0xFF132433);
  static const Color darkOnSurface = Color(0xFFE8F1F7);
  static const Color darkError = Color(0xFFEF9A9A);

  static const LinearGradient lightHeroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B6E99), Color(0xFF1A9B8E), Color(0xFF0D8A6A)],
  );

  static const LinearGradient darkHeroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A1622), Color(0xFF16324A), Color(0xFF0F3D4A)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0B6E99), Color(0xFF0A3D5C)],
  );
}
