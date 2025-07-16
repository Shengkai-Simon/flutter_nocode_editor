import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../properties/core/property_code_formatters.dart';
import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_definition.dart';
import '../core/widget_node.dart';
import '../core/component_definition.dart';
import '../core/component_types.dart' as ct;

final RegisteredComponent centerComponentDefinition = RegisteredComponent(
  type: ct.center,
  displayName: ct.center,
  icon: Icons.align_horizontal_center,
  defaultProps: {
    'widthFactor': null,
    'heightFactor': null,
  },
  propFields: [
    PropField(
      name: 'widthFactor',
      label: 'Width Factor',
      fieldType: FieldType.number,
      defaultValue: null,
      editorBuilder: kDefaultNumberInputEditor,
      propertyCategory: PropertyCategory.sizing,
      toCode: kNumberCodeFormatter
    ),
    PropField(
      name: 'heightFactor',
      label: 'Height Factor',
      fieldType: FieldType.number,
      defaultValue: null,
      editorBuilder: kDefaultNumberInputEditor,
      propertyCategory: PropertyCategory.sizing,
      toCode: kNumberCodeFormatter
    ),
  ],
  childPolicy: ChildAcceptancePolicy.single,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;
    final double? widthFactor = (props['widthFactor'] as num?)?.toDouble();
    final double? heightFactor = (props['heightFactor'] as num?)?.toDouble();
    Widget? childWidget;
    if (node.children.isNotEmpty) {
      childWidget = renderChild(node.children.first);
    }
    return Center(
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: childWidget,
    );
  },
  category: ComponentCategory.layout,
);