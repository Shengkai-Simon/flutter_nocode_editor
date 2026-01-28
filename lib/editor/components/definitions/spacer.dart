import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../properties/core/property_code_formatters.dart';
import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_definition.dart';
import '../core/widget_node.dart';
import '../core/component_definition.dart';
import '../core/component_types.dart' as ct;

final RegisteredComponent spacerComponentDefinition = RegisteredComponent(
  type: ct.spacer,
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
        editorBuilder: kIntegerStepperEditor,
        editorConfig: {'minValue': 1, 'step': 1},
        propertyCategory: PropertyCategory.sizing,
        toCode: kNumberCodeFormatter
    ),
  ],
  childPolicy: ChildAcceptancePolicy.none,
  allowedParentTypes: [ct.row, ct.column],
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;
    final int flex = (props['flex'] as num?)?.toInt() ?? 1;

    // Return the pure, original widget without any wrappers.
    // This guarantees correct Flex layout behavior.
    return Spacer(
      flex: flex,
    );
  },
  category: ComponentCategory.flexChild,
);
