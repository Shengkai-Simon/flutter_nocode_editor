import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/component_registry.dart';
import '../../core/widget_node.dart';
import '../utils/component_util.dart';

final RegisteredComponent textComponentDefinition = RegisteredComponent(
  type: 'Text',
  displayName: 'Text',
  icon: Icons.text_fields,
  defaultProps: {'text': 'Hello World', 'fontSize': 16.0, 'color': ''},
  propFields: [
    PropField(name: 'text', label: 'Text', fieldType: FieldType.string, defaultValue: 'Hello World'),
    PropField(name: 'fontSize', label: 'Font Size', fieldType: FieldType.number, defaultValue: 16.0),
    PropField(name: 'color', label: 'Text Color', fieldType: FieldType.color, defaultValue: ''),
  ],
  childPolicy: ChildAcceptancePolicy.none,
  builder: (WidgetNode node, WidgetRef ref, Widget Function(WidgetNode childNode) renderChild) {
    final props = node.props;
    final double fontSize = (props['fontSize'] as num?)?.toDouble() ?? 16.0;
    final color = ComponentUtil.parseColor(props['color']?.toString());
    return Text(
      props['text']?.toString() ?? '',
      style: TextStyle(fontSize: fontSize, color: color),
      softWrap: true,
      overflow: TextOverflow.visible,
    );
  },
);