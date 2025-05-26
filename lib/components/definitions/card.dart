import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/component_registry.dart';
import '../../core/widget_node.dart';
import '../utils/component_util.dart';

final RegisteredComponent cardComponentDefinition = RegisteredComponent(
  type: 'Card',
  displayName: 'Card',
  icon: Icons.credit_card,
  defaultProps: {
    'color': null,
    'shadowColor': null,
    'elevation': 1.0,
    'margin': 'all:4.0',
    'borderRadius': 4.0,
  },
  propFields: [
    PropField(name: 'color', label: 'Background Color', fieldType: FieldType.color, defaultValue: null),
    PropField(name: 'shadowColor', label: 'Shadow Color', fieldType: FieldType.color, defaultValue: null),
    PropField(name: 'elevation', label: 'Elevation', fieldType: FieldType.number, defaultValue: 1.0),
    PropField(name: 'margin', label: 'Margin', fieldType: FieldType.edgeInsets, defaultValue: 'all:4.0'),
    PropField(name: 'borderRadius', label: 'Border Radius', fieldType: FieldType.number, defaultValue: 4.0)
  ],
  childPolicy: ChildAcceptancePolicy.single,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;

    final String? colorString = props['color'] as String?;
    final Color? cardColor = (colorString != null && colorString.isNotEmpty)
        ? ComponentUtil.parseColor(colorString)
        : null;

    final String? shadowColorString = props['shadowColor'] as String?;
    final Color? shadowColor = (shadowColorString != null && shadowColorString.isNotEmpty)
        ? ComponentUtil.parseColor(shadowColorString)
        : null;

    final double? elevation = (props['elevation'] as num?)?.toDouble();
    final EdgeInsetsGeometry margin = ComponentUtil.parseEdgeInsets(props['margin'] as String?);
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