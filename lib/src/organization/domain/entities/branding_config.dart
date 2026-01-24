import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Organization-specific branding configuration
/// Controls app appearance, colors, logo, and naming
class BrandingConfig extends Equatable {
  /// URL to organization's logo image
  final String? logoUrl;

  /// Primary brand color (used for app bar, buttons, etc.)
  final Color primaryColor;

  /// Secondary brand color (used for accents)
  final Color secondaryColor;

  /// App name to display (organization-specific)
  final String appName;

  /// Organization's tagline or subtitle
  final String? tagline;

  /// Accent color for highlights
  final Color? accentColor;

  /// Background color
  final Color? backgroundColor;

  /// Surface color for cards and dialogs
  final Color? surfaceColor;

  /// Error color
  final Color? errorColor;

  const BrandingConfig({
    this.logoUrl,
    required this.primaryColor,
    required this.secondaryColor,
    required this.appName,
    this.tagline,
    this.accentColor,
    this.backgroundColor,
    this.surfaceColor,
    this.errorColor,
  });

  /// Default branding for E-Pravesh
  const BrandingConfig.defaultBranding()
      : logoUrl = null,
        primaryColor = const Color(0xFFFA5013),
        secondaryColor = const Color(0xFFFFFFFF),
        appName = 'E-Pravesh',
        tagline = 'Digital Visitor Management',
        accentColor = const Color(0xFFFF6B35),
        backgroundColor = null,
        surfaceColor = null,
        errorColor = null;

  /// BARTI organization branding
  const BrandingConfig.barti()
      : logoUrl = null,
        primaryColor = const Color(0xFFFA5013),
        secondaryColor = const Color(0xFF2C3E50),
        appName = 'E-Pravesh - BARTI',
        tagline = 'Dr. Babasaheb Ambedkar Research and Training Institute',
        accentColor = const Color(0xFFFF6B35),
        backgroundColor = null,
        surfaceColor = null,
        errorColor = null;

  /// Empty branding configuration
  const BrandingConfig.empty()
      : logoUrl = null,
        primaryColor = const Color(0xFF000000),
        secondaryColor = const Color(0xFFFFFFFF),
        appName = '',
        tagline = null,
        accentColor = null,
        backgroundColor = null,
        surfaceColor = null,
        errorColor = null;

  /// Convert branding to Material 3 ColorScheme
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: _getContrastColor(primaryColor),
      primaryContainer: _lightenColor(primaryColor, 0.8),
      onPrimaryContainer: _darkenColor(primaryColor, 0.3),
      secondary: secondaryColor,
      onSecondary: _getContrastColor(secondaryColor),
      secondaryContainer: _lightenColor(secondaryColor, 0.8),
      onSecondaryContainer: _darkenColor(secondaryColor, 0.3),
      tertiary: accentColor ?? _adjustColor(primaryColor, 30),
      onTertiary: _getContrastColor(accentColor ?? primaryColor),
      tertiaryContainer: _lightenColor(accentColor ?? primaryColor, 0.8),
      onTertiaryContainer: _darkenColor(accentColor ?? primaryColor, 0.3),
      error: errorColor ?? const Color(0xFFB3261E),
      onError: Colors.white,
      errorContainer: const Color(0xFFF9DEDC),
      onErrorContainer: const Color(0xFF410E0B),
      surface: surfaceColor ?? Colors.white,
      onSurface: const Color(0xFF1C1B1F),
      surfaceContainerHighest: const Color(0xFFE7E0EC),
      onSurfaceVariant: const Color(0xFF49454F),
      outline: const Color(0xFF79747E),
      outlineVariant: const Color(0xFFCAC4D0),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: const Color(0xFF313033),
      onInverseSurface: const Color(0xFFF4EFF4),
      inversePrimary: _lightenColor(primaryColor, 0.6),
    );
  }

  /// Generate a dark theme color scheme
  ColorScheme toDarkColorScheme() {
    return ColorScheme(
      brightness: Brightness.dark,
      primary: _lightenColor(primaryColor, 0.3),
      onPrimary: const Color(0xFF2C2C2C),
      primaryContainer: _darkenColor(primaryColor, 0.5),
      onPrimaryContainer: _lightenColor(primaryColor, 0.9),
      secondary: _lightenColor(secondaryColor, 0.3),
      onSecondary: const Color(0xFF2C2C2C),
      secondaryContainer: _darkenColor(secondaryColor, 0.5),
      onSecondaryContainer: _lightenColor(secondaryColor, 0.9),
      tertiary: _lightenColor(accentColor ?? primaryColor, 0.3),
      onTertiary: const Color(0xFF2C2C2C),
      tertiaryContainer: _darkenColor(accentColor ?? primaryColor, 0.5),
      onTertiaryContainer: _lightenColor(accentColor ?? primaryColor, 0.9),
      error: const Color(0xFFF2B8B5),
      onError: const Color(0xFF601410),
      errorContainer: const Color(0xFF8C1D18),
      onErrorContainer: const Color(0xFFF9DEDC),
      surface: const Color(0xFF1C1B1F),
      onSurface: const Color(0xFFE6E1E5),
      surfaceContainerHighest: const Color(0xFF36343B),
      onSurfaceVariant: const Color(0xFFCAC4D0),
      outline: const Color(0xFF938F99),
      outlineVariant: const Color(0xFF49454F),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: const Color(0xFFE6E1E5),
      onInverseSurface: const Color(0xFF313033),
      inversePrimary: primaryColor,
    );
  }

  /// Get contrasting color (black or white) for text on a background color
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Lighten a color by a factor (0.0 to 1.0)
  Color _lightenColor(Color color, double factor) {
    assert(factor >= 0 && factor <= 1);
    final hslColor = HSLColor.fromColor(color);
    final lightness = (hslColor.lightness + factor).clamp(0.0, 1.0);
    return hslColor.withLightness(lightness).toColor();
  }

  /// Darken a color by a factor (0.0 to 1.0)
  Color _darkenColor(Color color, double factor) {
    assert(factor >= 0 && factor <= 1);
    final hslColor = HSLColor.fromColor(color);
    final lightness = (hslColor.lightness - factor).clamp(0.0, 1.0);
    return hslColor.withLightness(lightness).toColor();
  }

  /// Adjust hue of a color by degrees
  Color _adjustColor(Color color, double degrees) {
    final hslColor = HSLColor.fromColor(color);
    final hue = (hslColor.hue + degrees) % 360;
    return hslColor.withHue(hue).toColor();
  }

  /// Convert hex color string to Color
  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Convert Color to hex string
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  /// Copy with method for creating modified configurations
  BrandingConfig copyWith({
    String? logoUrl,
    Color? primaryColor,
    Color? secondaryColor,
    String? appName,
    String? tagline,
    Color? accentColor,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? errorColor,
  }) {
    return BrandingConfig(
      logoUrl: logoUrl ?? this.logoUrl,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      appName: appName ?? this.appName,
      tagline: tagline ?? this.tagline,
      accentColor: accentColor ?? this.accentColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      errorColor: errorColor ?? this.errorColor,
    );
  }

  @override
  List<Object?> get props => [
        logoUrl,
        primaryColor,
        secondaryColor,
        appName,
        tagline,
        accentColor,
        backgroundColor,
        surfaceColor,
        errorColor,
      ];

  @override
  String toString() {
    return 'BrandingConfig(appName: $appName, primaryColor: ${BrandingConfig.colorToHex(primaryColor)})';
  }
}
