import 'package:flutter/cupertino.dart';

const List<PropertyCategory> kPropertyCategoryOrder = [
  PropertyCategory.general,
  PropertyCategory.sizing,
  PropertyCategory.spacing,
  PropertyCategory.layout,
  PropertyCategory.flexLayout,
  PropertyCategory.appearance,
  PropertyCategory.fill,
  PropertyCategory.border,
  PropertyCategory.shadow,
  PropertyCategory.gradient,
  PropertyCategory.textStyle,
  PropertyCategory.imageSource,
  PropertyCategory.imageAppearance,
  PropertyCategory.behavior,
  PropertyCategory.value,
  PropertyCategory.data,
];

/// support for field types in editor's right-side properties panel
enum FieldType { string, number, color, select, boolean, alignment, edgeInsets }

enum PropertyCategory {
  general,
  sizing,
  spacing,
  layout,
  flexLayout,
  appearance,
  fill,
  border,
  shadow,
  gradient,
  textStyle,
  imageSource,
  imageAppearance,
  behavior,
  data,
  value
}

typedef PropertyEditorBuilder = Widget Function(
    BuildContext context,
    Map<String, dynamic> allProps,
    PropField field,
    dynamic currentValue,
    void Function(dynamic newValue) onChanged,
);

/// Support displaying component field a property
class PropField {
  final String name;
  final String label;
  final FieldType fieldType;
  final dynamic defaultValue;
  final List<Map<String, String>>? options;
  final PropertyEditorBuilder? editorBuilder;
  final Map<String, dynamic>? editorConfig;
  final PropertyCategory propertyCategory;

  const PropField({
    required this.name,
    required this.label,
    required this.fieldType,
    this.defaultValue,
    this.options,
    required this.editorBuilder,
    this.editorConfig,
    required this.propertyCategory,
  });
}