import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/parsing_util.dart';
import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_meta.dart';
import '../core/component_model.dart';

final RegisteredComponent checkboxComponentDefinition = RegisteredComponent(
  type: 'Checkbox',
  displayName: 'Checkbox',
  icon: Icons.check_box_outlined,
  defaultProps: {
    'value': false,
    'tristate': false,
    'activeColor': null,
    'checkColor': null,
    'splashRadius': 20.0,
  },
  propFields: [
    PropField(
      name: 'value',
      label: 'Checked',
      fieldType: FieldType.boolean,
      defaultValue: false,
      editorBuilder: kDefaultSwitchEditor,
      propertyCategory: PropertyCategory.general,
    ),
    PropField(
      name: 'tristate',
      label: 'Tristate (allows indeterminate state)',
      fieldType: FieldType.boolean,
      defaultValue: false,
      editorBuilder: kDefaultSwitchEditor,
      propertyCategory: PropertyCategory.behavior,
    ),
    PropField(
      name: 'activeColor',
      label: 'Active Color (Box Fill)',
      fieldType: FieldType.color,
      defaultValue: null,
      editorBuilder: kDefaultColorPickerEditor,
      propertyCategory: PropertyCategory.appearance,
    ),
    PropField(
      name: 'checkColor',
      label: 'Check Color (Mark)',
      fieldType: FieldType.color,
      defaultValue: null,
      editorBuilder: kDefaultColorPickerEditor,
      propertyCategory: PropertyCategory.appearance,
    ),
    PropField(
      name: 'splashRadius',
      label: 'Splash Radius',
      fieldType: FieldType.number,
      defaultValue: 20.0,
      editorBuilder: kSliderNumberInputEditor,
      editorConfig: {'minValue': 0.0, 'maxValue': 50.0, 'decimalPlaces': 0},
      propertyCategory: PropertyCategory.appearance,
    ),
  ],
  childPolicy: ChildAcceptancePolicy.none,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;
    final bool tristate = (props['tristate'] as bool?) ?? false;

    bool? checkboxValue;
    if (tristate) {
      checkboxValue = (props['value'] as bool?) ?? false;
    } else {
      checkboxValue = (props['value'] as bool?) ?? false;
    }


    final String? activeColorHex = props['activeColor'] as String?;
    final Color? activeColor = (activeColorHex != null && activeColorHex.isNotEmpty)
        ? ParsingUtil.parseColor(activeColorHex)
        : null;

    final String? checkColorHex = props['checkColor'] as String?;
    final Color? checkColor = (checkColorHex != null && checkColorHex.isNotEmpty)
        ? ParsingUtil.parseColor(checkColorHex)
        : null;

    final double splashRadius = (props['splashRadius'] as num?)?.toDouble() ?? 20.0;

    return Checkbox(
      value: checkboxValue,
      tristate: tristate,
      onChanged: null,
      activeColor: activeColor,
      checkColor: checkColor,
      splashRadius: splashRadius,
    );
  },
  category: ComponentCategory.input,
);