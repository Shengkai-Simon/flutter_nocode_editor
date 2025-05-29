import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_meta.dart';
import '../core/component_model.dart';

final RegisteredComponent expandedComponentDefinition = RegisteredComponent(
  type: 'Expanded',
  displayName: 'Expanded',
  icon: Icons.fit_screen,
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
      propertyCategory: PropertyCategory.flexLayout
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

    Widget? childWidget;
    if (node.children.isNotEmpty) {
      childWidget = renderChild(node.children.first);
    } else {
      childWidget = Container(
        constraints: const BoxConstraints.expand(),
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: Text(
          'Child for Expanded',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      );
    }

    return Expanded(
      flex: effectiveFlex,
      child: childWidget,
    );
  },
  category: ComponentCategory.layout,
);