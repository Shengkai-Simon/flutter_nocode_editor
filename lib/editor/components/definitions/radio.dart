import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/parsing_util.dart';
import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_meta.dart';
import '../core/component_model.dart';

final RegisteredComponent radioComponentDefinition = RegisteredComponent(
  type: 'Radio',
  displayName: 'Radio Button',
  icon: Icons.radio_button_checked_outlined,
  defaultProps: {
    'itemValue': 'option1',
    'isSelectedInGroup': false,
    'activeColor': null,
  },
  propFields: [
    PropField(
      name: 'itemValue',
      label: 'Item Value (Unique Identifier)',
      fieldType: FieldType.string,
      defaultValue: 'option1',
      editorBuilder: kDefaultTextInputEditor,
    ),
    PropField(
      name: 'isSelectedInGroup',
      label: 'Is Selected',
      fieldType: FieldType.boolean,
      defaultValue: false,
      editorBuilder: kDefaultSwitchEditor,
    ),
    PropField(
      name: 'activeColor',
      label: 'Active Color',
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
    final String itemValue = props['itemValue'] as String? ?? 'default_value';
    final bool isSelectedInGroup = (props['isSelectedInGroup'] as bool?) ?? false;

    final String groupValueForDisplay = isSelectedInGroup ? itemValue : 'a_different_value_to_ensure_unselected_${itemValue.hashCode}';

    final String? activeColorHex = props['activeColor'] as String?;
    final Color? activeColor = (activeColorHex != null && activeColorHex.isNotEmpty)
        ? ParsingUtil.parseColor(activeColorHex)
        : null;

    return Radio<String>(
      value: itemValue,
      groupValue: groupValueForDisplay,
      onChanged: null,
      activeColor: activeColor,
    );
  },
);