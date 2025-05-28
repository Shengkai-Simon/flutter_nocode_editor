import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/component_registry.dart';
import '../../core/widget_node.dart';
import '../utils/component_util.dart';
import '../../core/common_component_props.dart';

final RegisteredComponent rowComponentDefinition = RegisteredComponent(
  type: 'Row',
  displayName: 'Row',
  icon: Icons.vertical_distribute,
  defaultProps: {
    ...SizingProps.defaults,
    ...MainAxisAlignmentProp.defaults,
    ...CrossAxisAlignmentProp.defaults,
    ...MainAxisSizeProp.defaults,

  },
  propFields: [
    ...SizingProps.fields,
    ...MainAxisAlignmentProp.fields,
    ...CrossAxisAlignmentProp.fields,
    ...MainAxisSizeProp.fields,
  ],
  childPolicy: ChildAcceptancePolicy.multiple,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;

    // Read common props
    final double? width = (props['width'] as num?)?.toDouble();
    final double? height = (props['height'] as num?)?.toDouble();
    final MainAxisAlignment mainAxisAlignment = ComponentUtil.parseMainAxisAlignment(props['mainAxisAlignment']?.toString());
    final CrossAxisAlignment crossAxisAlignment = ComponentUtil.parseCrossAxisAlignment(props['crossAxisAlignment']?.toString());
    final MainAxisSize mainAxisSize = ComponentUtil.parseMainAxisSize(props['mainAxisSize']?.toString());

    final childrenWidgets = node.children.map((childNode) => renderChild(childNode)).toList();

    Widget rowWidget = Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: childrenWidgets,
    );

    if (width != null || height != null) {
      rowWidget = SizedBox(
        width: width,
        height: height,
        child: rowWidget,
      );
    }
    return rowWidget;
  },
);