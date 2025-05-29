import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/parsing_util.dart';
import '../../properties/core/property_meta.dart';
import '../core/common_props.dart';
import '../core/component_model.dart';

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

    final EdgeInsetsGeometry padding = ParsingUtil.parseEdgeInsets(props['padding']?.toString());

    Widget? childWidget;
    if (node.children.isNotEmpty) {
      childWidget = renderChild(node.children.first);
    }

    return Padding(
      padding: padding,
      child: childWidget,
    );
  },
  category: ComponentCategory.layout,
);