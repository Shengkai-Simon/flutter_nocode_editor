import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../properties/core/property_code_formatters.dart';
import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_definition.dart';
import '../core/widget_node.dart';
import '../core/component_definition.dart';

final RegisteredComponent spacerComponentDefinition = RegisteredComponent(
  type: 'Spacer',
  displayName: 'Spacer',
  icon: Icons.space_bar,
  defaultProps: {
    'flex': 1,
  },
  propFields: [
    PropField(
      name: 'flex',
      label: 'Flex Factor',
      fieldType: FieldType.number,
      defaultValue: 1,
      editorBuilder: kSliderNumberInputEditor,
      editorConfig: {'minValue': 1.0, 'maxValue': 10.0, 'divisions': 9, 'decimalPlaces': 0},
      propertyCategory: PropertyCategory.sizing,
      toCode: kNumberCodeFormatter
    ),
  ],
  childPolicy: ChildAcceptancePolicy.none,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;
    final int flex = (props['flex'] as num?)?.toInt() ?? 1;

    return Spacer(
      flex: flex,
    );
  },
  category: ComponentCategory.layout,
);