import 'package:flutter/material.dart';

class AppColors {
  // Static Core Fin Accents
  static const Color primary = Colors.red;
  static const Color greenSmooth = Colors.green;
  static const Color redSmooth = Colors.redAccent;
  static const Color accent = Color(0xFF111111);

  // Dynamic Theme Elements based on active Provider switches
  static Color getBackground(bool isDarkMode) => isDarkMode ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
  static Color getCardBackground(bool isDarkMode) => isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  static Color getTextDark(bool isDarkMode) => isDarkMode ? const Color(0xFFF5F5F5) : const Color(0xFF222222);
  static Color getTextLight(bool isDarkMode) => isDarkMode ? Colors.white60 : Colors.grey;
  static Color getBorder(bool isDarkMode) => isDarkMode ? Colors.white12 : const Color(0xFFEEEEEE);
}
