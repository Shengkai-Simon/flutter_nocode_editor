import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/component_registry.dart';
import '../../core/widget_node.dart';
import '../utils/component_util.dart';
import '../../core/common_component_props.dart'; // Import common props

final RegisteredComponent cardComponentDefinition = RegisteredComponent(
  type: 'Card',
  displayName: 'Card',
  icon: Icons.credit_card_outlined,
  defaultProps: {
    // Common props
    ...BackgroundColorProp.defaults,
    ...MarginProps.defaults,

    'margin': 'all:4.0',
    'shadowColor': null,
    'elevation': 1.0,
    'borderRadius': 4.0,
  },
  propFields: [
    ...BackgroundColorProp.fields,
    ...MarginProps.fields,

    PropField(name: 'shadowColor', label: 'Shadow Color', fieldType: FieldType.color, defaultValue: null),
    PropField(name: 'elevation', label: 'Elevation', fieldType: FieldType.number, defaultValue: 1.0),
    PropField(name: 'borderRadius', label: 'Border Radius', fieldType: FieldType.number, defaultValue: 4.0),
  ],
  childPolicy: ChildAcceptancePolicy.single,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;

    final String? backgroundColorString = props['backgroundColor'] as String?;
    final Color? cardColor = (backgroundColorString != null && backgroundColorString.isNotEmpty)
        ? ComponentUtil.parseColor(backgroundColorString)
        : null;

    final EdgeInsetsGeometry margin = ComponentUtil.parseEdgeInsets(props['margin'] as String?);

    final String? shadowColorString = props['shadowColor'] as String?;
    final Color? shadowColor = (shadowColorString != null && shadowColorString.isNotEmpty)
        ? ComponentUtil.parseColor(shadowColorString)
        : null;
    final double? elevation = (props['elevation'] as num?)?.toDouble();
    final double borderRadiusValue = (props['borderRadius'] as num?)?.toDouble() ?? 4.0;

    final ShapeBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadiusValue),
    );

    Widget? childWidget;
    if (node.children.isNotEmpty) {
      childWidget = renderChild(node.children.first);
    }

    return Card(
      color: cardColor,
      shadowColor: shadowColor,
      elevation: elevation,
      margin: margin,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: childWidget,
    );
  },
);