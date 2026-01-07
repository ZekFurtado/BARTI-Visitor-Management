import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static var colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: const Color(0xFFFA5013),
      primaryContainer: const Color(0xFFFFF0EB),
      primaryFixed: const Color(0xFFFFF0EB),
      onPrimary: const Color(0xFFFFFFFF),
      secondary: const Color(0xFFFFFFFF),
      onSecondary: const Color(0xFF000000),
      tertiary: const Color(0xFF4600FF),
      onTertiary: const Color(0xFFFFFFFF),
      error: const Color(0xffba1a1a),
      onError: const Color(0xffffffff),
      surface: const Color(0xFFFFFFFF),
      surfaceTint: const Color(0xFFFBFBFB),
      // surface: const Color(0xFFFFF3E7),
      onSurface: const Color(0xFF000000),
      onSurfaceVariant: const Color(0xFF5C7282),
      shadow: const Color(0xFF000000).withOpacity(0.25));

  // TextTheme Style Guide (Material 3 Defaults)
// All styles using GoogleFonts.figtreeTextTheme()

// Display Styles - For large scale headings
// displayLarge    - ~57sp - Very large headlines (e.g., landing pages)
// displayMedium   - ~45sp - Large headlines
// displaySmall    - ~36sp - Medium headlines

// Headline Styles - For page titles and sections
// headlineLarge   - ~32sp - Page titles
// headlineMedium  - ~28sp - Section headers
// headlineSmall   - ~24sp - Smaller section headers

// Title Styles - For cards, dialogs, and app bars
// titleLarge      - ~22sp - Prominent titles (e.g., cards)
// titleMedium     - ~16sp - Subtitles, smaller headings
// titleSmall      - ~14sp - Tab labels, small UI titles

// Body Styles - For most text content
// bodyLarge       - ~16sp - Main content text (e.g., paragraphs)
// bodyMedium      - ~14sp - Secondary text (e.g., list items)
// bodySmall       - ~12sp - Caption text, footnotes

// Label Styles - For buttons, tags, and labels
// labelLarge      - ~14sp - Button text, primary labels
// labelMedium     - ~12sp - Secondary buttons, chips
// labelSmall      - ~11sp - Helper text, timestamps, etc.
  static var textTheme = TextTheme(
    displayLarge: GoogleFonts.figtree(),
    displayMedium: GoogleFonts.figtree(),
    displaySmall: GoogleFonts.figtree(),
    titleLarge: GoogleFonts.figtree(),
    titleMedium: GoogleFonts.figtree(),
    titleSmall: GoogleFonts.figtree(),
    bodyLarge: GoogleFonts.figtree(),
    bodyMedium: GoogleFonts.figtree(),
    bodySmall: GoogleFonts.figtree(),
  );
}
