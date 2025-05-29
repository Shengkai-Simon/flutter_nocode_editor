import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/parsing_util.dart';
import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_meta.dart';
import '../core/component_model.dart';

final RegisteredComponent dividerComponentDefinition = RegisteredComponent(
  type: 'Divider',
  displayName: 'Divider',
  icon: Icons.horizontal_rule,
  defaultProps: {
    'height': 16.0,
    'thickness': null,
    'indent': 0.0,
    'endIndent': 0.0,
    'color': null,
  },
  propFields: [
    PropField(
      name: 'height',
      label: 'Height (Total Space)',
      fieldType: FieldType.number,
      defaultValue: 16.0,
      editorBuilder: kSliderNumberInputEditor,
      editorConfig: {'minValue': 1.0, 'maxValue': 100.0, 'divisions': 99, 'decimalPlaces': 0},
    ),
    PropField(
      name: 'thickness',
      label: 'Thickness (Line)',
      fieldType: FieldType.number,
      defaultValue: null,
      editorBuilder: kSliderNumberInputEditor,
      editorConfig: {'minValue': 0.5, 'maxValue': 10.0, 'divisions': 19, 'decimalPlaces': 1},
    ),
    PropField(
      name: 'indent',
      label: 'Indent (Start Space)',
      fieldType: FieldType.number,
      defaultValue: 0.0,
      editorBuilder: kSliderNumberInputEditor,
      editorConfig: {'minValue': 0.0, 'maxValue': 100.0, 'divisions': 100, 'decimalPlaces': 0},
    ),
    PropField(
      name: 'endIndent',
      label: 'End Indent (End Space)',
      fieldType: FieldType.number,
      defaultValue: 0.0,
      editorBuilder: kSliderNumberInputEditor,
      editorConfig: {'minValue': 0.0, 'maxValue': 100.0, 'divisions': 100, 'decimalPlaces': 0},
    ),
    PropField(name: 'color', label: 'Color', fieldType: FieldType.color, defaultValue: null, editorBuilder: kDefaultColorPickerEditor),
  ],
  childPolicy: ChildAcceptancePolicy.none,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;

    final double? height = (props['height'] as num?)?.toDouble();
    final double? thickness = (props['thickness'] as num?)?.toDouble();
    final double? indent = (props['indent'] as num?)?.toDouble();
    final double? endIndent = (props['endIndent'] as num?)?.toDouble();

    final String? colorString = props['color'] as String?;
    final Color? color = (colorString != null && colorString.isNotEmpty) ? ParsingUtil.parseColor(colorString) : null;

    return Divider(height: height, thickness: thickness, indent: indent, endIndent: endIndent, color: color);
  },
  category: ComponentCategory.content,
);