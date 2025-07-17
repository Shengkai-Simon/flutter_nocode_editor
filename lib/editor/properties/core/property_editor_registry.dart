import 'package:flutter/material.dart';
import 'package:flutter_editor/editor/properties/core/property_definition.dart';

import '../definitions/alignment_picker_field.dart';
import '../definitions/color_picker_field.dart';
import '../definitions/dropdown_field.dart';
import '../definitions/edge_insets_field.dart';
import '../definitions/integer_stepper_field.dart';
import '../definitions/number_input_field.dart';
import '../definitions/slider_number_input_field.dart';
import '../definitions/switch_field.dart';
import '../definitions/text_input_field.dart';

/// Builds a standard text input field.
PropertyEditorBuilderWithUpdate kDefaultTextInputEditor = (
  BuildContext context,
  Map<String, dynamic> allProps,
  PropField field,
  dynamic currentValue,
  void Function(dynamic newValue) onCommit,
  void Function(dynamic newValue) onUpdate,
) {
  return TextInputField(
    label: field.label,
    value: currentValue?.toString() ?? field.defaultValue?.toString() ?? '',
    onCommit: onCommit,
    onUpdate: onUpdate,
  );
};

/// Builds a standard number input field.
PropertyEditorBuilderWithUpdate kDefaultNumberInputEditor = (
  BuildContext context,
  Map<String, dynamic> allProps,
  PropField field,
  dynamic currentValue,
  void Function(dynamic newValue) onCommit,
  void Function(dynamic newValue) onUpdate,
) {
  return NumberInputField(
    label: field.label,
    value: currentValue as num? ?? field.defaultValue as num?,
    onCommit: (num? val) {
      if (val != null && val < 0) {
        onCommit(0.0);
      } else {
        onCommit(val);
      }
    },
    onUpdate: (num? val) {
      if (val != null && val < 0) {
        onUpdate(0.0);
      } else {
        onUpdate(val);
      }
    },
    allowDecimal: true, // Default to allowing decimals
  );
};

/// Builds a number input field constrained to positive numbers (or zero).
PropertyEditorBuilderWithUpdate kPositiveNumberInputEditor = (
  BuildContext context,
  Map<String, dynamic> allProps,
  PropField field,
  dynamic currentValue,
  void Function(dynamic newValue) onCommit,
  void Function(dynamic newValue) onUpdate,
) {
  return NumberInputField(
    label: field.label,
    value: currentValue as num? ?? field.defaultValue as num?,
    onCommit: (num? val) {
      if (val != null && val < 0) {
        onCommit(0.0);
      } else {
        onCommit(val);
      }
    },
    onUpdate: (num? val) {
      if (val != null && val < 0) {
        onUpdate(0.0);
      } else {
        onUpdate(val);
      }
    },
    allowDecimal: true, // Default to allowing decimals
  );
};

/// Builds a standard color picker field.
PropertyEditorBuilder kDefaultColorPickerEditor = (
  BuildContext context,
  Map<String, dynamic> allProps,
  PropField field,
  dynamic currentValue,
  void Function(dynamic newValue) onCommit,
) {
  return ColorPickerField(
    label: field.label,
    value: currentValue?.toString() ?? field.defaultValue?.toString() ?? '',
    onChanged: onCommit,
  );
};

/// Builds a standard dropdown field.
PropertyEditorBuilder kDefaultDropdownEditor = (
  BuildContext context,
  Map<String, dynamic> allProps,
  PropField field,
  dynamic currentValue,
  void Function(dynamic newValue) onCommit,
) {
  String effectiveValue =
      currentValue?.toString() ?? field.defaultValue?.toString() ?? '';
  final options = field.options ?? [];
  if (options.isNotEmpty &&
      !options.any((opt) => opt['id'] == effectiveValue)) {
    effectiveValue = options.first['id'] ?? '';
  }

  return DropdownField(
    label: field.label,
    value: effectiveValue,
    options: options,
    onChanged: onCommit,
  );
};

/// Builds a standard switch field for boolean values.
PropertyEditorBuilder kDefaultSwitchEditor = (
  BuildContext context,
  Map<String, dynamic> allProps,
  PropField field,
  dynamic currentValue,
  void Function(dynamic newValue) onCommit,
) {
  return SwitchField(
    label: field.label,
    value: (currentValue as bool?) ?? (field.defaultValue as bool?) ?? false,
    onChanged: onCommit,
  );
};

/// Builds a standard EdgeInsets editor field.
PropertyEditorBuilderWithUpdate kDefaultEdgeInsetsEditor = (
  BuildContext context,
  Map<String, dynamic> allProps,
  PropField field,
  dynamic currentValue,
  void Function(dynamic newValue) onCommit,
  void Function(dynamic newValue) onUpdate,
) {
  return EdgeInsetsField(
    label: field.label,
    value:
        currentValue?.toString() ?? field.defaultValue?.toString() ?? 'all:0',
    onCommit: onCommit,
    onUpdate: onUpdate,
  );
};

PropertyEditorBuilderWithUpdate kSliderNumberInputEditor = (
  BuildContext context,
  Map<String, dynamic> allProps,
  PropField field,
  dynamic currentValue,
  void Function(dynamic newValue) onCommit,
  void Function(dynamic newValue) onUpdate,
) {
  final config = field.editorConfig ?? {};
  final double minValue = (config['minValue'] as num?)?.toDouble() ?? 0.0;
  final double maxValue = (config['maxValue'] as num?)?.toDouble() ?? 100.0;
  final int? divisions = (config['divisions'] as int?);
  final int decimalPlaces = (config['decimalPlaces'] as int?) ?? 2;

  double currentNumericValue;
  if (currentValue is num) {
    currentNumericValue = currentValue.toDouble();
  } else if (currentValue is String) {
    currentNumericValue = double.tryParse(currentValue) ?? minValue;
  } else {
    currentNumericValue = (field.defaultValue as num?)?.toDouble() ?? minValue;
  }

  return SliderNumberInputField(
    label: field.label,
    value: currentNumericValue,
    minValue: minValue,
    maxValue: maxValue,
    divisions: divisions,
    decimalPlaces: decimalPlaces,
    onCommit: (double newValue) {
      onCommit(newValue);
    },
    onUpdate: (double newValue) {
      onUpdate(newValue);
    },
  );
};

PropertyEditorBuilderWithUpdate kIntegerStepperEditor = (
  BuildContext context,
  Map<String, dynamic> allProps,
  PropField field,
  dynamic currentValue,
  void Function(dynamic newValue) onCommit,
  void Function(dynamic newValue) onUpdate,
) {
  final config = field.editorConfig ?? {};
  final int? minValue = config['minValue'] as int?;
  final int? maxValue = config['maxValue'] as int?;
  final int step = (config['step'] as int?) ?? 1;

  int? currentIntValue;
  if (currentValue is num) {
    currentIntValue = currentValue.toInt();
  } else if (currentValue is String) {
    currentIntValue = int.tryParse(currentValue);
  } else if (currentValue == null && field.defaultValue != null) {
    currentIntValue = (field.defaultValue as num?)?.toInt();
  }

  return IntegerStepperField(
    label: field.label,
    value: currentIntValue,
    minValue: minValue,
    maxValue: maxValue,
    step: step,
    onCommit: (int? newValue) {
      onCommit(newValue);
    },
    onUpdate: (int? newValue) {
      onUpdate(newValue);
    },
  );
};

PropertyEditorBuilder kAlignmentPickerEditor = (
  BuildContext context,
  Map<String, dynamic> allProps,
  PropField field,
  dynamic currentValue,
  void Function(dynamic newValue) onCommit,
) {
  String effectiveValue =
      currentValue?.toString() ?? field.defaultValue?.toString() ?? 'center';
  final options = field.options ?? [];

  if (options.isNotEmpty &&
      !options.any((opt) => opt['id'] == effectiveValue)) {
    if (options.any((opt) => opt['id'] == 'center')) {
      effectiveValue = 'center';
    } else {
      effectiveValue = options.first['id'] ?? 'center';
    }
  }

  return AlignmentPickerField(
    label: field.label,
    value: effectiveValue,
    options: options,
    onChanged: (String newValue) {
      onCommit(newValue);
    },
  );
};

PropertyEditorBuilder kAlignmentDropdownEditor = kDefaultDropdownEditor;

final Map<String, PropertyEditorBuilder> _propertyEditorRegistry = {
  'color': kDefaultColorPickerEditor,
  'dropdown': kDefaultDropdownEditor,
  'switch': kDefaultSwitchEditor,
  'alignmentPicker': kAlignmentPickerEditor,
  'alignmentDropdown': kAlignmentDropdownEditor,
};

final Map<String, PropertyEditorBuilderWithUpdate>
    _propertyEditorRegistryWithUpdate = {
  'string': kDefaultTextInputEditor,
  'number': kDefaultNumberInputEditor,
  'positiveNumber': kPositiveNumberInputEditor,
  'edgeInsets': kDefaultEdgeInsetsEditor,
  'sliderNumber': kSliderNumberInputEditor,
  'integerStepper': kIntegerStepperEditor,
};

PropertyEditorBuilder? getPropertyEditor(String editorType) {
  return _propertyEditorRegistry[editorType];
}

PropertyEditorBuilderWithUpdate? getPropertyEditorWithUpdate(String editorType) {
  return _propertyEditorRegistryWithUpdate[editorType];
}
