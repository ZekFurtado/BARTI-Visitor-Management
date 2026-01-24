import 'package:equatable/equatable.dart';

/// Represents a custom field that can be added to visitor or employee forms
/// for organization-specific data collection
class CustomField extends Equatable {
  /// Unique identifier for this custom field
  final String id;

  /// Display label for the field
  final String label;

  /// Type of input field
  final CustomFieldType type;

  /// Whether this field is required
  final bool required;

  /// Options for dropdown fields
  final List<String>? options;

  /// Default value for the field
  final String? defaultValue;

  /// Placeholder text
  final String? placeholder;

  /// Help text or description
  final String? helpText;

  const CustomField({
    required this.id,
    required this.label,
    required this.type,
    this.required = false,
    this.options,
    this.defaultValue,
    this.placeholder,
    this.helpText,
  });

  /// Creates an empty custom field
  const CustomField.empty()
      : id = '',
        label = '',
        type = CustomFieldType.text,
        required = false,
        options = null,
        defaultValue = null,
        placeholder = null,
        helpText = null;

  /// Validates if a value is acceptable for this field
  bool validate(String? value) {
    // Check if required field has value
    if (required && (value == null || value.isEmpty)) {
      return false;
    }

    // If not required and no value provided, it's valid
    if (value == null || value.isEmpty) {
      return true;
    }

    // Type-specific validation
    switch (type) {
      case CustomFieldType.number:
        return double.tryParse(value) != null;
      case CustomFieldType.dropdown:
        return options?.contains(value) ?? false;
      case CustomFieldType.email:
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        return emailRegex.hasMatch(value);
      case CustomFieldType.phone:
        final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
        return phoneRegex.hasMatch(value);
      case CustomFieldType.url:
        final urlRegex = RegExp(
          r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
        );
        return urlRegex.hasMatch(value);
      default:
        return true; // text and date fields accept any string
    }
  }

  /// Gets the validation error message for this field
  String? getValidationError(String? value) {
    if (required && (value == null || value.isEmpty)) {
      return '$label is required';
    }

    if (value == null || value.isEmpty) {
      return null;
    }

    switch (type) {
      case CustomFieldType.number:
        return double.tryParse(value) == null
            ? '$label must be a valid number'
            : null;
      case CustomFieldType.dropdown:
        return options?.contains(value) ?? false
            ? null
            : 'Invalid selection for $label';
      case CustomFieldType.email:
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        return emailRegex.hasMatch(value)
            ? null
            : '$label must be a valid email';
      case CustomFieldType.phone:
        final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
        return phoneRegex.hasMatch(value)
            ? null
            : '$label must be a valid phone number';
      case CustomFieldType.url:
        final urlRegex = RegExp(
          r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
        );
        return urlRegex.hasMatch(value) ? null : '$label must be a valid URL';
      default:
        return null;
    }
  }

  @override
  List<Object?> get props => [
        id,
        label,
        type,
        required,
        options,
        defaultValue,
        placeholder,
        helpText,
      ];

  @override
  String toString() {
    return 'CustomField(id: $id, label: $label, type: $type, required: $required)';
  }
}

/// Types of custom fields supported
enum CustomFieldType {
  /// Single-line text input
  text,

  /// Multi-line text input
  textarea,

  /// Numeric input
  number,

  /// Dropdown selection
  dropdown,

  /// Date picker
  date,

  /// Email input with validation
  email,

  /// Phone number input
  phone,

  /// URL input with validation
  url,

  /// Checkbox (boolean)
  checkbox,
}

/// Extension methods for CustomFieldType
extension CustomFieldTypeX on CustomFieldType {
  /// Get display name for the field type
  String get displayName {
    switch (this) {
      case CustomFieldType.text:
        return 'Text';
      case CustomFieldType.textarea:
        return 'Long Text';
      case CustomFieldType.number:
        return 'Number';
      case CustomFieldType.dropdown:
        return 'Dropdown';
      case CustomFieldType.date:
        return 'Date';
      case CustomFieldType.email:
        return 'Email';
      case CustomFieldType.phone:
        return 'Phone';
      case CustomFieldType.url:
        return 'URL';
      case CustomFieldType.checkbox:
        return 'Checkbox';
    }
  }

  /// Convert to string for serialization
  String toJson() => name;

  /// Parse from string
  static CustomFieldType fromJson(String value) {
    return CustomFieldType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => CustomFieldType.text,
    );
  }
}
