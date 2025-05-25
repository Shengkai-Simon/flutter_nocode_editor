import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/component_registry.dart';
import '../../core/widget_node.dart';
import '../utils/component_util.dart';

final RegisteredComponent containerComponentDefinition = RegisteredComponent(
  type: 'Container',
  displayName: 'Container',
  icon: Icons.crop_square,
  defaultProps: {
    'width': '200',
    'height': '100',
    'backgroundColor': '',
    'alignment': 'center',
    'padding': 'all:0',
    'margin': 'all:0',
  },
  propFields: [
    PropField(name: 'width', label: 'Width', fieldType: FieldType.number, defaultValue: '200'),
    PropField(name: 'height', label: 'Height', fieldType: FieldType.number, defaultValue: '100'),
    PropField(name: 'backgroundColor', label: 'Background', fieldType: FieldType.color, defaultValue: ''),
    PropField(
      name: 'alignment',
      label: 'Alignment',
      fieldType: FieldType.select,
      defaultValue: 'center',
      options: [
        {'id': 'topLeft', 'name': 'Top Left'},
        {'id': 'topCenter', 'name': 'Top Center'},
        {'id': 'topRight', 'name': 'Top Right'},
        {'id': 'centerLeft', 'name': 'Center Left'},
        {'id': 'center', 'name': 'Center'},
        {'id': 'centerRight', 'name': 'Center Right'},
        {'id': 'bottomLeft', 'name': 'Bottom Left'},
        {'id': 'bottomCenter', 'name': 'Bottom Center'},
        {'id': 'bottomRight', 'name': 'Bottom Right'},
      ],
    ),
    PropField(name: 'padding', label: 'Padding', fieldType: FieldType.edgeInsets, defaultValue: 'all:0'),
    PropField(name: 'margin', label: 'Margin', fieldType: FieldType.edgeInsets, defaultValue: 'all:0'),
  ],
  childPolicy: ChildAcceptancePolicy.single,
  builder: (WidgetNode node, WidgetRef ref, Widget Function(WidgetNode childNode) renderChild) {
    final props = node.props;

    final double? width = double.tryParse(props['width']?.toString() ?? '');
    final double? height = double.tryParse(props['height']?.toString() ?? '');
    final bgColor = ComponentUtil.parseColor(props['backgroundColor']?.toString());
    final alignment = ComponentUtil.parseAlignment(props['alignment']?.toString());
    final padding = ComponentUtil.parseEdgeInsets(props['padding']?.toString());
    final margin = ComponentUtil.parseEdgeInsets(props['margin']?.toString());

    Widget? childWidgetInstance;
    if (node.children.isNotEmpty) {
      childWidgetInstance = renderChild(node.children.first);
    }

    return Container(
      width: width,
      height: height,
      color: bgColor,
      alignment: alignment,
      padding: padding,
      margin: margin,
      child: childWidgetInstance,
    );
  },
);