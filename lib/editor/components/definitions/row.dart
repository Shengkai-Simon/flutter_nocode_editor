import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/parsing_util.dart';
import '../../properties/core/property_meta.dart';
import '../core/common_props.dart';
import '../core/component_model.dart';

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

    final double? width = (props['width'] as num?)?.toDouble();
    final double? height = (props['height'] as num?)?.toDouble();
    final MainAxisAlignment mainAxisAlignment = ParsingUtil.parseMainAxisAlignment(props['mainAxisAlignment']?.toString());
    final CrossAxisAlignment crossAxisAlignment = ParsingUtil.parseCrossAxisAlignment(props['crossAxisAlignment']?.toString());
    final MainAxisSize mainAxisSize = ParsingUtil.parseMainAxisSize(props['mainAxisSize']?.toString());

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