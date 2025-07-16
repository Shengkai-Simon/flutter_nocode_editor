import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/parsing_util.dart';
import '../../properties/core/property_common_groups.dart';
import '../core/widget_node.dart';
import '../core/component_definition.dart';
import '../core/component_types.dart' as ct;

final RegisteredComponent columnComponentDefinition = RegisteredComponent(
  type: ct.column,
  displayName: ct.column,
  icon: Icons.horizontal_distribute,
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

    final double? width = (props['width'] as num?)?.toDouble();
    final double? height = (props['height'] as num?)?.toDouble();
    final MainAxisAlignment mainAxisAlignment = ParsingUtil.parseMainAxisAlignment(props['mainAxisAlignment']?.toString());
    final CrossAxisAlignment crossAxisAlignment = ParsingUtil.parseCrossAxisAlignment(props['crossAxisAlignment']?.toString());
    final MainAxisSize mainAxisSize = ParsingUtil.parseMainAxisSize(props['mainAxisSize']?.toString());

    final childrenWidgets = node.children.map((childNode) => renderChild(childNode)).toList();

    Widget columnWidget = Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: childrenWidgets,
    );

    if (width != null || height != null) {
      columnWidget = SizedBox(
        width: width,
        height: height,
        child: columnWidget,
      );
    }
    return columnWidget;
  },
  category: ComponentCategory.layout,
);