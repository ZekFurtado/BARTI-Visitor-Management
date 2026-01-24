import 'package:visitor_management/core/utils/typedef.dart';
import 'package:visitor_management/src/organization/domain/entities/custom_field.dart';

/// Data model for CustomField with Firebase serialization
class CustomFieldModel extends CustomField {
  const CustomFieldModel({
    required super.id,
    required super.label,
    required super.type,
    super.required,
    super.options,
    super.defaultValue,
    super.placeholder,
    super.helpText,
  });

  /// Creates empty custom field model
  const CustomFieldModel.empty() : super.empty();

  /// Creates a model from an entity
  factory CustomFieldModel.fromEntity(CustomField entity) {
    return CustomFieldModel(
      id: entity.id,
      label: entity.label,
      type: entity.type,
      required: entity.required,
      options: entity.options,
      defaultValue: entity.defaultValue,
      placeholder: entity.placeholder,
      helpText: entity.helpText,
    );
  }

  /// Creates a model from JSON/Firestore data
  factory CustomFieldModel.fromJson(DataMap json) {
    return CustomFieldModel(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      type: CustomFieldTypeX.fromJson(json['type'] as String? ?? 'text'),
      required: json['required'] as bool? ?? false,
      options: json['options'] != null
          ? List<String>.from(json['options'] as List)
          : null,
      defaultValue: json['defaultValue'] as String?,
      placeholder: json['placeholder'] as String?,
      helpText: json['helpText'] as String?,
    );
  }

  /// Converts model to JSON/Firestore format
  DataMap toJson() {
    return {
      'id': id,
      'label': label,
      'type': type.toJson(),
      'required': required,
      if (options != null) 'options': options,
      if (defaultValue != null) 'defaultValue': defaultValue,
      if (placeholder != null) 'placeholder': placeholder,
      if (helpText != null) 'helpText': helpText,
    };
  }

  /// Copy with method
  CustomFieldModel copyWith({
    String? id,
    String? label,
    CustomFieldType? type,
    bool? required,
    List<String>? options,
    String? defaultValue,
    String? placeholder,
    String? helpText,
  }) {
    return CustomFieldModel(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      required: required ?? this.required,
      options: options ?? this.options,
      defaultValue: defaultValue ?? this.defaultValue,
      placeholder: placeholder ?? this.placeholder,
      helpText: helpText ?? this.helpText,
    );
  }
}
