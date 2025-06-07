import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../properties/core/property_code_formatters.dart';
import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_definition.dart';
import '../core/widget_node.dart';
import '../core/component_definition.dart';

FlexFit _parseFlexFit(String? fitString) {
  switch (fitString) {
    case 'tight':
      return FlexFit.tight;
    case 'loose':
    default:
      return FlexFit.loose;
  }
}

final RegisteredComponent flexibleComponentDefinition = RegisteredComponent(
  type: 'Flexible',
  displayName: 'Flexible',
  icon: Icons.settings_overscan,
  defaultProps: {
    'flex': 1,
    'fit': 'loose',
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
      toCode: kNumberCodeFormatter,
    ),
    PropField(
      name: 'fit',
      label: 'Fit',
      fieldType: FieldType.select,
      defaultValue: 'loose',
      options: [
        {'id': 'loose', 'name': 'Loose (child can be smaller)'},
        {'id': 'tight', 'name': 'Tight (child fills space, like Expanded)'},
      ],
      editorBuilder: kDefaultDropdownEditor,
      propertyCategory: PropertyCategory.layout,
      toCode: kEnumCodeFormatter('FlexFit'),
    ),
  ],
  childPolicy: ChildAcceptancePolicy.single,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;
    final int flex = (props['flex'] as num?)?.toInt() ?? 1;
    final int effectiveFlex = flex > 0 ? flex : 1;
    final FlexFit fit = _parseFlexFit(props['fit'] as String?);

    Widget? childWidget;
    if (node.children.isNotEmpty) {
      childWidget = renderChild(node.children.first);
    } else {
      childWidget = Container(
        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
        padding: const EdgeInsets.all(4),
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: Text(
          'Child for Flexible',
          style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Flexible(
      flex: effectiveFlex,
      fit: fit,
      child: childWidget,
    );
  },
  category: ComponentCategory.layout,
);