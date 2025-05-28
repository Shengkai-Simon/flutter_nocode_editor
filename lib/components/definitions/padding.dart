import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/component_registry.dart';
import '../../core/widget_node.dart';
import '../utils/component_util.dart';
import '../../core/common_component_props.dart';

final RegisteredComponent paddingComponentDefinition = RegisteredComponent(
  type: 'Padding',
  displayName: 'Padding',
  icon: Icons.padding,
  defaultProps: {
    ...PaddingProps.defaults,
  },
  propFields: [
    ...PaddingProps.fields,
  ],
  childPolicy: ChildAcceptancePolicy.single,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;

    final EdgeInsetsGeometry padding = ComponentUtil.parseEdgeInsets(props['padding']?.toString());

    Widget? childWidget;
    if (node.children.isNotEmpty) {
      childWidget = renderChild(node.children.first);
    }

    return Padding(
      padding: padding,
      child: childWidget,
    );
  },
);