import 'package:flutter/material.dart';
import 'package:visitor_management/core/utils/typedef.dart';
import 'package:visitor_management/src/organization/domain/entities/branding_config.dart';

/// Data model for BrandingConfig with Firebase serialization
class BrandingConfigModel extends BrandingConfig {
  const BrandingConfigModel({
    super.logoUrl,
    required super.primaryColor,
    required super.secondaryColor,
    required super.appName,
    super.tagline,
    super.accentColor,
    super.backgroundColor,
    super.surfaceColor,
    super.errorColor,
  });

  /// Creates default branding model
  const BrandingConfigModel.defaultBranding() : super.defaultBranding();

  /// Creates BARTI branding model
  const BrandingConfigModel.barti() : super.barti();

  /// Creates empty branding model
  const BrandingConfigModel.empty() : super.empty();

  /// Creates a model from an entity
  factory BrandingConfigModel.fromEntity(BrandingConfig entity) {
    return BrandingConfigModel(
      logoUrl: entity.logoUrl,
      primaryColor: entity.primaryColor,
      secondaryColor: entity.secondaryColor,
      appName: entity.appName,
      tagline: entity.tagline,
      accentColor: entity.accentColor,
      backgroundColor: entity.backgroundColor,
      surfaceColor: entity.surfaceColor,
      errorColor: entity.errorColor,
    );
  }

  /// Creates a model from JSON/Firestore data
  factory BrandingConfigModel.fromJson(DataMap json) {
    return BrandingConfigModel(
      logoUrl: json['logoUrl'] as String?,
      primaryColor: json['primaryColor'] != null
          ? BrandingConfig.hexToColor(json['primaryColor'] as String)
          : const Color(0xFFFA5013),
      secondaryColor: json['secondaryColor'] != null
          ? BrandingConfig.hexToColor(json['secondaryColor'] as String)
          : const Color(0xFFFFFFFF),
      appName: json['appName'] as String? ?? 'E-Pravesh',
      tagline: json['tagline'] as String?,
      accentColor: json['accentColor'] != null
          ? BrandingConfig.hexToColor(json['accentColor'] as String)
          : null,
      backgroundColor: json['backgroundColor'] != null
          ? BrandingConfig.hexToColor(json['backgroundColor'] as String)
          : null,
      surfaceColor: json['surfaceColor'] != null
          ? BrandingConfig.hexToColor(json['surfaceColor'] as String)
          : null,
      errorColor: json['errorColor'] != null
          ? BrandingConfig.hexToColor(json['errorColor'] as String)
          : null,
    );
  }

  /// Converts model to JSON/Firestore format
  DataMap toJson() {
    return {
      if (logoUrl != null) 'logoUrl': logoUrl,
      'primaryColor': BrandingConfig.colorToHex(primaryColor),
      'secondaryColor': BrandingConfig.colorToHex(secondaryColor),
      'appName': appName,
      if (tagline != null) 'tagline': tagline,
      if (accentColor != null)
        'accentColor': BrandingConfig.colorToHex(accentColor!),
      if (backgroundColor != null)
        'backgroundColor': BrandingConfig.colorToHex(backgroundColor!),
      if (surfaceColor != null)
        'surfaceColor': BrandingConfig.colorToHex(surfaceColor!),
      if (errorColor != null)
        'errorColor': BrandingConfig.colorToHex(errorColor!),
    };
  }

  /// Copy with method
  BrandingConfigModel copyWith({
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
    return BrandingConfigModel(
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
}
