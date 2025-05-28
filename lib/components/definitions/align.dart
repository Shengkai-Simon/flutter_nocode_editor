import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/component_registry.dart';
import '../../core/widget_node.dart';
import '../utils/component_util.dart';
import '../../core/common_component_props.dart';

final RegisteredComponent alignComponentDefinition = RegisteredComponent(
  type: 'Align',
  displayName: 'Align',
  icon: Icons.border_outer,
  defaultProps: {
    ...ChildAlignmentProps.defaults,
    'widthFactor': null,
    'heightFactor': null,
  },
  propFields: [
    ...ChildAlignmentProps.fields,

    PropField(
      name: 'widthFactor',
      label: 'Width Factor',
      fieldType: FieldType.number,
      defaultValue: null,
    ),
    PropField(
      name: 'heightFactor',
      label: 'Height Factor',
      fieldType: FieldType.number,
      defaultValue: null,
    ),
  ],
  childPolicy: ChildAcceptancePolicy.single,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;

    final AlignmentGeometry alignment = ComponentUtil.parseAlignment(props['alignment'] as String?);

    final double? widthFactor = (props['widthFactor'] as num?)?.toDouble();
    final double? heightFactor = (props['heightFactor'] as num?)?.toDouble();

    Widget? childWidget;
    if (node.children.isNotEmpty) {
      childWidget = renderChild(node.children.first);
    }

    return Align(
      alignment: alignment,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: childWidget,
    );
  },
);