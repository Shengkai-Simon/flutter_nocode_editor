import 'package:flutter/cupertino.dart';

// Define a function type for formatting a property's value into a Dart code string.
typedef PropValueToCodeFormatter = String? Function(dynamic propValue);

const List<PropertyCategory> kPropertyCategoryOrder = [
  PropertyCategory.general,
  PropertyCategory.value,
  PropertyCategory.dataSource,
  PropertyCategory.sizing,
  PropertyCategory.spacing,
  PropertyCategory.layout,
  PropertyCategory.appearance,
  PropertyCategory.textStyle,
  PropertyCategory.background,
  PropertyCategory.border,
  PropertyCategory.shadow,
  PropertyCategory.image,
  PropertyCategory.behavior,
];

/// support for field types in editor's right-side properties panel
enum FieldType { string, number, color, select, boolean, alignment, edgeInsets }

enum PropertyCategory {
  // Core Content & Data
  general, // Text.text, Button.text, Radio.itemValue
  value, // Switch.value, Slider.value, TextField.initialValue
  dataSource, // DropdownButton.itemsString
  // Layout & Sizing
  sizing,
  spacing,
  layout,
  // Visual Styling
  appearance,
  textStyle,
  background,
  border,
  shadow,
  // Specific Component Types
  image,
  // Behavior & Interaction
  behavior, // keyboardType, obscureText, Slider's min/max/divisions, splashRadius
}

typedef PropertyEditorBuilder = Widget Function(
    BuildContext context,
    Map<String, dynamic> allProps,
    PropField field,
    dynamic currentValue,
    void Function(dynamic newValue) onCommit,
);

typedef PropertyEditorBuilderWithUpdate = Widget Function(
    BuildContext context,
    Map<String, dynamic> allProps,
    PropField field,
    dynamic currentValue,
    void Function(dynamic newValue) onCommit,
    void Function(dynamic newValue) onUpdate,
);

/// Support displaying component field a property
class PropField {
  final String name;
  final String label;
  final FieldType fieldType;
  final dynamic defaultValue;
  final List<Map<String, String>>? options;
  final Function? editorBuilder; // Can be PropertyEditorBuilder or PropertyEditorBuilderWithUpdate
  final Map<String, dynamic>? editorConfig;
  final PropertyCategory propertyCategory;
  final PropValueToCodeFormatter? toCode;

  const PropField({
    required this.name,
    required this.label,
    required this.fieldType,
    this.defaultValue,
    this.options,
    required this.editorBuilder,
    this.editorConfig,
    required this.propertyCategory,
    required this.toCode,
  });
}