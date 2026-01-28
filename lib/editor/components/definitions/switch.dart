import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/parsing_util.dart';
import '../../properties/core/property_code_formatters.dart';
import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_definition.dart';
import '../core/component_types.dart' as ct;
import '../core/widget_node.dart';
import '../core/component_definition.dart';

final RegisteredComponent switchComponentDefinition = RegisteredComponent(
  type: ct.switchWidget,
  displayName: ct.switchWidget,
  icon: Icons.toggle_on_outlined,
  defaultProps: {
    'value': false,
    'activeColor': null,
    'activeTrackColor': null,
    'inactiveThumbColor': null,
    'inactiveTrackColor': null,
  },
  propFields: [
    PropField(
      name: 'value',
      label: 'Value (On/Off)',
      fieldType: FieldType.boolean,
      defaultValue: false,
      editorBuilder: kDefaultSwitchEditor,
      propertyCategory: PropertyCategory.value,
      toCode: kBooleanCodeFormatter
    ),
    PropField(
      name: 'activeColor',
      label: 'Active Color (Thumb)',
      fieldType: FieldType.color,
      defaultValue: null,
      editorBuilder: kDefaultColorPickerEditor,
      propertyCategory: PropertyCategory.appearance,
      toCode: kColorCodeFormatter
    ),
    PropField(
      name: 'activeTrackColor',
      label: 'Active Track Color',
      fieldType: FieldType.color,
      defaultValue: null,
      editorBuilder: kDefaultColorPickerEditor,
      propertyCategory: PropertyCategory.appearance,
      toCode: kColorCodeFormatter
    ),
    PropField(
      name: 'inactiveThumbColor',
      label: 'Inactive Thumb Color',
      fieldType: FieldType.color,
      defaultValue: null,
      editorBuilder: kDefaultColorPickerEditor,
      propertyCategory: PropertyCategory.appearance,
      toCode: kColorCodeFormatter
    ),
    PropField(
      name: 'inactiveTrackColor',
      label: 'Inactive Track Color',
      fieldType: FieldType.color,
      defaultValue: null,
      editorBuilder: kDefaultColorPickerEditor,
      propertyCategory: PropertyCategory.appearance,
      toCode: kColorCodeFormatter
    ),
  ],
  childPolicy: ChildAcceptancePolicy.none,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;
    final bool value = (props['value'] as bool?) ?? false;

    final String? activeColorHex = props['activeColor'] as String?;
    final Color? activeColor = (activeColorHex != null && activeColorHex.isNotEmpty)
        ? ParsingUtil.parseColor(activeColorHex)
        : null;

    final String? activeTrackColorHex = props['activeTrackColor'] as String?;
    final Color? activeTrackColor = (activeTrackColorHex != null && activeTrackColorHex.isNotEmpty)
        ? ParsingUtil.parseColor(activeTrackColorHex)
        : null;

    final String? inactiveThumbColorHex = props['inactiveThumbColor'] as String?;
    final Color? inactiveThumbColor = (inactiveThumbColorHex != null && inactiveThumbColorHex.isNotEmpty)
        ? ParsingUtil.parseColor(inactiveThumbColorHex)
        : null;

    final String? inactiveTrackColorHex = props['inactiveTrackColor'] as String?;
    final Color? inactiveTrackColor = (inactiveTrackColorHex != null && inactiveTrackColorHex.isNotEmpty)
        ? ParsingUtil.parseColor(inactiveTrackColorHex)
        : null;

    return Switch(
      value: value,
      onChanged: null,
      activeColor: activeColor,
      activeTrackColor: activeTrackColor,
      inactiveThumbColor: inactiveThumbColor,
      inactiveTrackColor: inactiveTrackColor,
    );
  },
  category: ComponentCategory.input,
);