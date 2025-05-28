import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/parsing_util.dart';
import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_meta.dart';
import '../core/component_model.dart';

final RegisteredComponent sliderComponentDefinition = RegisteredComponent(
  type: 'Slider',
  displayName: 'Slider',
  icon: Icons.linear_scale,
  defaultProps: {
    'value': 0.5,
    'min': 0.0,
    'max': 1.0,
    'divisions': null,
    'activeColor': null,
    'inactiveColor': null,
    'thumbColor': null,
  },
  propFields: [
    PropField(
      name: 'value',
      label: 'Value',
      fieldType: FieldType.number,
      defaultValue: 0.5,
      editorBuilder: kDefaultNumberInputEditor,
    ),
    PropField(
      name: 'min',
      label: 'Min Value',
      fieldType: FieldType.number,
      defaultValue: 0.0,
      editorBuilder: kDefaultNumberInputEditor,
    ),
    PropField(
      name: 'max',
      label: 'Max Value',
      fieldType: FieldType.number,
      defaultValue: 1.0,
      editorBuilder: kDefaultNumberInputEditor,
    ),
    PropField(
      name: 'divisions',
      label: 'Divisions (null for continuous)',
      fieldType: FieldType.number,
      defaultValue: null,
      editorBuilder: kIntegerStepperEditor,
      editorConfig: {'minValue': 2, 'step': 1},
    ),
    PropField(
      name: 'activeColor',
      label: 'Active Color (Track)',
      fieldType: FieldType.color,
      defaultValue: null,
      editorBuilder: kDefaultColorPickerEditor,
    ),
    PropField(
      name: 'inactiveColor',
      label: 'Inactive Color (Track)',
      fieldType: FieldType.color,
      defaultValue: null,
      editorBuilder: kDefaultColorPickerEditor,
    ),
    PropField(
      name: 'thumbColor',
      label: 'Thumb Color',
      fieldType: FieldType.color,
      defaultValue: null,
      editorBuilder: kDefaultColorPickerEditor,
    ),
  ],
  childPolicy: ChildAcceptancePolicy.none,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;
    double minValue = (props['min'] as num?)?.toDouble() ?? 0.0;
    double maxValue = (props['max'] as num?)?.toDouble() ?? 1.0;

    if (minValue > maxValue) {
      final temp = minValue;
      minValue = maxValue;
      maxValue = temp;
    } else if (minValue == maxValue) {
      maxValue = minValue + 1.0;
    }

    double currentValue = (props['value'] as num?)?.toDouble() ?? minValue;
    currentValue = currentValue.clamp(minValue, maxValue);

    final int? divisions = (props['divisions'] as num?)?.toInt();
    final int? effectiveDivisions = (divisions != null && divisions >=1) ? divisions : null;


    final String? activeColorHex = props['activeColor'] as String?;
    final Color? activeColor = (activeColorHex != null && activeColorHex.isNotEmpty)
        ? ParsingUtil.parseColor(activeColorHex)
        : null;

    final String? inactiveColorHex = props['inactiveColor'] as String?;
    final Color? inactiveColor = (inactiveColorHex != null && inactiveColorHex.isNotEmpty)
        ? ParsingUtil.parseColor(inactiveColorHex)
        : null;

    final String? thumbColorHex = props['thumbColor'] as String?;
    final Color? thumbColor = (thumbColorHex != null && thumbColorHex.isNotEmpty)
        ? ParsingUtil.parseColor(thumbColorHex)
        : null;

    return Slider(
      value: currentValue,
      min: minValue,
      max: maxValue,
      divisions: effectiveDivisions,
      label: effectiveDivisions != null ? currentValue.toStringAsFixed(2) : null,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      thumbColor: thumbColor,
      onChanged: null,
    );
  },
);