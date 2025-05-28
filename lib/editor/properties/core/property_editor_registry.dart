import 'package:flutter/material.dart';
import 'package:flutter_editor/editor/properties/core/property_meta.dart';

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

PropertyEditorBuilder kSliderNumberInputEditor =
    (BuildContext context, PropField field, dynamic currentValue, void Function(dynamic newValue) onChanged) {
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
    onChanged: (double newValue) {
      onChanged(newValue);
    },
  );
};

PropertyEditorBuilder kIntegerStepperEditor = (BuildContext context, PropField field, dynamic currentValue, void Function(dynamic newValue) onChanged) {
  final config = field.editorConfig ?? {};
  final int? minValue = config['minValue'] as int?;
  final int? maxValue = config['maxValue'] as int?;
  final int step = (config['step'] as int?) ?? 1;

  int? currentIntValue;
  if (currentValue is num) {
    currentIntValue = currentValue.toInt();
  } else if (currentValue is String) {
    currentIntValue = int.tryParse(currentValue);
  } else if (currentValue == null && field.defaultValue != null){
    currentIntValue = (field.defaultValue as num?)?.toInt();
  }

  return IntegerStepperField(
    label: field.label,
    value: currentIntValue,
    minValue: minValue,
    maxValue: maxValue,
    step: step,
    onChanged: (int? newValue) {
      onChanged(newValue);
    },
  );
};

PropertyEditorBuilder kAlignmentPickerEditor =
    (BuildContext context, PropField field, dynamic currentValue, void Function(dynamic newValue) onChanged) {

  String effectiveValue = currentValue?.toString() ?? field.defaultValue?.toString() ?? 'center';
  final options = field.options ?? [];

  if (options.isNotEmpty && !options.any((opt) => opt['id'] == effectiveValue)) {
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
      onChanged(newValue);
    },
  );
};

PropertyEditorBuilder kAlignmentDropdownEditor = kDefaultDropdownEditor;