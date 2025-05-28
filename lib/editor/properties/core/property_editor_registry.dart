import 'package:flutter/material.dart';
import 'package:flutter_editor/editor/properties/core/property_meta.dart';

import '../definitions/color_picker_field.dart';
import '../definitions/dropdown_field.dart';
import '../definitions/edge_insets_field.dart';
import '../definitions/number_input_field.dart';
import '../definitions/switch_field.dart';
import '../definitions/text_input_field.dart';

/// Builds a standard text input field.
PropertyEditorBuilder kDefaultTextInputEditor =
    (BuildContext context, PropField field, dynamic currentValue, void Function(dynamic newValue) onChanged) {
  return TextInputField(
    label: field.label,
    value: currentValue?.toString() ?? field.defaultValue?.toString() ?? '',
    onChanged: onChanged,
  );
};

/// Builds a standard number input field.
PropertyEditorBuilder kDefaultNumberInputEditor =
    (BuildContext context, PropField field, dynamic currentValue, void Function(dynamic newValue) onChanged) {
  return NumberInputField(
    label: field.label,
    value: (currentValue as num?)?.toString() ?? (field.defaultValue as num?)?.toString() ?? '',
    onChanged: (String newValueString) {
      onChanged(double.tryParse(newValueString));
    },
  );
};

/// Builds a number input field constrained to positive numbers (or zero).
PropertyEditorBuilder kPositiveNumberInputEditor =
    (BuildContext context, PropField field, dynamic currentValue, void Function(dynamic newValue) onChanged) {
  return NumberInputField(
    label: field.label,
    value: (currentValue as num?)?.toString() ?? (field.defaultValue as num?)?.toString() ?? '0',
    onChanged: (String newValueString) {
      final num? val = double.tryParse(newValueString);
      if (val != null && val < 0) {
        onChanged(0.0);
      } else {
        onChanged(val);
      }
    },
  );
};

/// Builds a standard color picker field.
PropertyEditorBuilder kDefaultColorPickerEditor =
    (BuildContext context, PropField field, dynamic currentValue, void Function(dynamic newValue) onChanged) {
  return ColorPickerField(
    label: field.label,
    value: currentValue?.toString() ?? field.defaultValue?.toString() ?? '',
    onChanged: onChanged,
  );
};

/// Builds a standard dropdown field.
PropertyEditorBuilder kDefaultDropdownEditor =
    (BuildContext context, PropField field, dynamic currentValue, void Function(dynamic newValue) onChanged) {
  String effectiveValue = currentValue?.toString() ?? field.defaultValue?.toString() ?? '';
  final options = field.options ?? [];
  if (options.isNotEmpty && !options.any((opt) => opt['id'] == effectiveValue)) {
    effectiveValue = options.first['id'] ?? '';
  }

  return DropdownField(
    label: field.label,
    value: effectiveValue,
    options: options,
    onChanged: onChanged,
  );
};

/// Builds a standard switch field for boolean values.
PropertyEditorBuilder kDefaultSwitchEditor =
    (BuildContext context, PropField field, dynamic currentValue, void Function(dynamic newValue) onChanged) {
  return SwitchField(
    label: field.label,
    value: (currentValue as bool?) ?? (field.defaultValue as bool?) ?? false,
    onChanged: onChanged,
  );
};

/// Builds a standard EdgeInsets editor field.
PropertyEditorBuilder kDefaultEdgeInsetsEditor =
    (BuildContext context, PropField field, dynamic currentValue, void Function(dynamic newValue) onChanged) {
  return EdgeInsetsField(
    label: field.label,
    value: currentValue?.toString() ?? field.defaultValue?.toString() ?? 'all:0',
    onChanged: onChanged,
  );
};

PropertyEditorBuilder kAlignmentDropdownEditor = kDefaultDropdownEditor;