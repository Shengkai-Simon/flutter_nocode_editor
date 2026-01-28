import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/parsing_util.dart';
import '../../properties/core/property_code_formatters.dart';
import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_definition.dart';
import '../core/widget_node.dart';
import '../core/component_definition.dart';
import '../core/component_types.dart' as ct;

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

// Add this custom formatter function within the icon.dart file.
String? _iconDataToCode(dynamic value) {
  // This map translates the user-facing string to the required Dart code string.
  const Map<String, String> iconNameToCodeMap = {
    'Settings': 'Icons.settings',
    'Favorite': 'Icons.favorite',
    'Home': 'Icons.home',
    'Search': 'Icons.search',
    'Add': 'Icons.add',
    'Edit': 'Icons.edit',
    'Delete': 'Icons.delete',
    'Info': 'Icons.info',
    'Check Circle': 'Icons.check_circle',
    'Warning': 'Icons.warning',
    'Person': 'Icons.person',
    'Shopping Cart': 'Icons.shopping_cart',
    'Menu': 'Icons.menu',
    'Close': 'Icons.close',
    'Arrow Back': 'Icons.arrow_back',
    'Arrow Forward': 'Icons.arrow_forward',
    'Visibility': 'Icons.visibility',
    'Visibility Off': 'Icons.visibility_off',
    'Lightbulb': 'Icons.lightbulb',
    'Star': 'Icons.star',
  };

  if (value is String && iconNameToCodeMap.containsKey(value)) {
    return iconNameToCodeMap[value];
  }

  // Return a fallback icon if no match is found, ensuring valid code generation.
  return 'Icons.error';
}

final RegisteredComponent iconComponentDefinition = RegisteredComponent(
  type: ct.icon,
  displayName: ct.icon,
  icon: Icons.insert_emoticon,
  defaultProps: {
    'iconName': 'Favorite',
    'size': 24.0,
    'color': '#000000',
  },
  propFields: [
    PropField(
      name: 'iconName',
      label: ct.icon,
      fieldType: FieldType.select,
      defaultValue: 'Favorite',
      options: _availableIcons.keys.map((name) => {'id': name, 'name': name}).toList(),
      editorBuilder: kDefaultDropdownEditor,
      propertyCategory: PropertyCategory.general,
      toCode: _iconDataToCode,
    ),
    PropField(
      name: 'size',
      label: 'Size',
      fieldType: FieldType.number,
      defaultValue: 24.0,
      editorBuilder: kSliderNumberInputEditor,
      editorConfig: {'minValue': 8.0, 'maxValue': 128.0, 'divisions': 120, 'decimalPlaces': 0},
      propertyCategory: PropertyCategory.sizing,
      toCode: kNumberCodeFormatter
    ),
    PropField(
      name: 'color',
      label: 'Color',
      fieldType: FieldType.color,
      defaultValue: '#000000',
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