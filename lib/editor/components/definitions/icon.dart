import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/parsing_util.dart';
import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_definition.dart';
import '../core/widget_node.dart';
import '../core/component_definition.dart';

const Map<String, IconData> _availableIcons = {
  'Settings': Icons.settings, 'Favorite': Icons.favorite, 'Home': Icons.home,
  'Search': Icons.search, 'Add': Icons.add, 'Edit': Icons.edit,
  'Delete': Icons.delete, 'Info': Icons.info, 'Check Circle': Icons.check_circle,
  'Warning': Icons.warning, 'Person': Icons.person, 'Shopping Cart': Icons.shopping_cart,
  'Menu': Icons.menu, 'Close': Icons.close, 'Arrow Back': Icons.arrow_back,
  'Arrow Forward': Icons.arrow_forward, 'Visibility': Icons.visibility,
  'Visibility Off': Icons.visibility_off, 'Lightbulb': Icons.lightbulb, 'Star': Icons.star,
};

IconData _getIconDataFromString(String? iconName) {
  return _availableIcons[iconName] ?? Icons.image;
}

final RegisteredComponent iconComponentDefinition = RegisteredComponent(
  type: 'Icon',
  displayName: 'Icon',
  icon: Icons.insert_emoticon,
  defaultProps: {
    'iconName': 'Favorite',
    'size': 24.0,
    'color': '#000000',
  },
  propFields: [
    PropField(
      name: 'iconName',
      label: 'Icon',
      fieldType: FieldType.select,
      defaultValue: 'Favorite',
      options: _availableIcons.keys.map((name) => {'id': name, 'name': name}).toList(),
      editorBuilder: kDefaultDropdownEditor,
      propertyCategory: PropertyCategory.general
    ),
    PropField(
      name: 'size',
      label: 'Size',
      fieldType: FieldType.number,
      defaultValue: 24.0,
      editorBuilder: kSliderNumberInputEditor,
      editorConfig: {'minValue': 8.0, 'maxValue': 128.0, 'divisions': 120, 'decimalPlaces': 0},
      propertyCategory: PropertyCategory.sizing
    ),
    PropField(
      name: 'color',
      label: 'Color',
      fieldType: FieldType.color,
      defaultValue: '#000000',
      editorBuilder: kDefaultColorPickerEditor,
      propertyCategory: PropertyCategory.appearance
    ),
  ],
  childPolicy: ChildAcceptancePolicy.none,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;

    final String? iconName = props['iconName'] as String?;
    final IconData iconData = _getIconDataFromString(iconName);

    final double size = (props['size'] as num?)?.toDouble() ?? 24.0;
    final Color iconColor = ParsingUtil.parseColor(props['color'] as String?);

    return Icon(
      iconData,
      size: size,
      color: iconColor,
    );
  },
  category: ComponentCategory.content,
);