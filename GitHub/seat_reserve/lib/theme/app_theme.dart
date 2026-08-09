import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ------------------------------------------------------------
  // SURFACE COLORS
  // ------------------------------------------------------------

  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceDim = Color(0xFFCBDBF5);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);
  static const Color surfaceVariant = Color(0xFFD3E4FE);

  // ------------------------------------------------------------
  // ON SURFACE
  // ------------------------------------------------------------

  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF45464D);
  static const Color outlineVariant = Color(0xFFC6C6CD);

  // ------------------------------------------------------------
  // PRIMARY
  // ------------------------------------------------------------

  static const Color primary = Color(0xFF000000);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color primaryContainer = Color(0xFF131B2E);
  static const Color onPrimaryContainer = Color(0xFF7C839B);

  static const Color primaryFixed = Color(0xFFDAE2FD);
  static const Color primaryFixedDim = Color(0xFFBEC6E0);

  // ------------------------------------------------------------
  // SECONDARY
  // ------------------------------------------------------------

  static const Color secondary = Color(0xFF0058BE);
  static const Color onSecondary = Color(0xFFFFFFFF);

  static const Color secondaryContainer = Color(0xFF2170E4);
  static const Color onSecondaryContainer = Color(0xFFFEFCFF);

  static const Color secondaryFixedDim = Color(0xFFADC6FF);

  // ------------------------------------------------------------
  // TERTIARY
  // ------------------------------------------------------------

  static const Color tertiaryContainer = Color(0xFF002113);
  static const Color onTertiaryContainer = Color(0xFF009668);

  static const Color tertiaryFixed = Color(0xFF6FFBBE);
  static const Color tertiaryFixedDim = Color(0xFF4EDEA3);

  // ------------------------------------------------------------
  // SEMANTIC COLORS
  // ------------------------------------------------------------

  static const Color checkedIn = onTertiaryContainer;
  static const Color reserved = secondary;
  static const Color available = onTertiaryContainer;

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);

  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // ------------------------------------------------------------
  // LIGHT THEME
  // ------------------------------------------------------------

  static ThemeData get lightTheme {
    final baseText = GoogleFonts.hankenGroteskTextTheme();
    final monoFont = GoogleFonts.jetBrainsMono();

    return ThemeData(
      useMaterial3: true,

      scaffoldBackgroundColor: surface,

      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,

        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,

        secondary: secondary,
        onSecondary: onSecondary,

        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,

        surface: surface,
        onSurface: onSurface,

        onSurfaceVariant: onSurfaceVariant,

        surfaceContainerLow: surfaceContainerLow,
        surfaceContainerLowest: surfaceContainerLowest,
        surfaceContainer: surfaceContainer,
        surfaceContainerHigh: surfaceContainerHigh,
        surfaceContainerHighest: surfaceContainerHighest,

        outlineVariant: outlineVariant,

        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
      ),

      // ----------------------------------------------------------
      // TEXT THEME
      // ----------------------------------------------------------

      textTheme: baseText.copyWith(
        displayLarge: GoogleFonts.hankenGrotesk(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          height: 56 / 48,
          color: onSurface,
          letterSpacing: -0.02,
        ),

        headlineLarge: GoogleFonts.hankenGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          height: 40 / 32,
          color: onSurface,
          letterSpacing: -0.01,
        ),

        headlineMedium: GoogleFonts.hankenGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 32 / 24,
          color: onSurface,
        ),

        titleMedium: GoogleFonts.hankenGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 28 / 20,
          color: onSurface,
        ),

        titleSmall: GoogleFonts.hankenGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 22 / 16,
          color: onSurface,
        ),

        bodyLarge: GoogleFonts.hankenGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 24 / 16,
          color: onSurface,
        ),

        bodyMedium: GoogleFonts.hankenGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: 20 / 14,
          color: onSurfaceVariant,
        ),

        labelSmall: monoFont.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 16 / 12,
          letterSpacing: 0.05,
        ),
      ),

      // ----------------------------------------------------------
      // CARD THEME
      // ----------------------------------------------------------

      cardTheme: CardThemeData(
        color: surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: outlineVariant,
            width: 0.8,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // ELEVATED BUTTON
      // ----------------------------------------------------------

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(88, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.hankenGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // OUTLINED BUTTON
      // ----------------------------------------------------------

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(
            color: outlineVariant,
          ),
          minimumSize: const Size(88, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.hankenGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // CHIP THEME
      // ----------------------------------------------------------

      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainerLow,
        selectedColor: secondaryContainer,
        disabledColor: surfaceVariant,

        side: const BorderSide(
          color: outlineVariant,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),

        labelStyle: GoogleFonts.hankenGrotesk(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: onSurface,
        ),
      ),

      // ----------------------------------------------------------
      // INPUT DECORATION
      // ----------------------------------------------------------

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLowest,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: outlineVariant,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: outlineVariant,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: secondary,
            width: 2,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: error,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: error,
            width: 2,
          ),
        ),
      ),
    );
  }
}