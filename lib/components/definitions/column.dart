import 'package:flutter/material.dart';
import 'package:flutter_editor/components/utils/component_util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/component_registry.dart';
import '../../core/widget_node.dart';

final RegisteredComponent columnComponentDefinition = RegisteredComponent(
  type: 'Column',
  displayName: 'Column',
  icon: Icons.horizontal_distribute,
  defaultProps: {
    'mainAxisAlignment': 'start',
    'crossAxisAlignment': 'center',
    'mainAxisSize': 'max',
  },
  propFields: [
    PropField(
      name: 'mainAxisAlignment',
      label: 'Main Axis Align',
      fieldType: FieldType.select,
      defaultValue: 'start',
      options: [
        {'id': 'start', 'name': 'Start'},
        {'id': 'end', 'name': 'End'},
        {'id': 'center', 'name': 'Center'},
        {'id': 'spaceBetween', 'name': 'Space Between'},
        {'id': 'spaceAround', 'name': 'Space Around'},
        {'id': 'spaceEvenly', 'name': 'Space Evenly'},
      ],
    ),
    PropField(
      name: 'crossAxisAlignment',
      label: 'Cross Axis Align',
      fieldType: FieldType.select,
      defaultValue: 'center',
      options: [
        {'id': 'start', 'name': 'Start'},
        {'id': 'end', 'name': 'End'},
        {'id': 'center', 'name': 'Center'},
        {'id': 'stretch', 'name': 'Stretch'},
        {'id': 'baseline', 'name': 'Baseline (req. textBaseline)'},
      ],
    ),
    PropField(
      name: 'mainAxisSize',
      label: 'Main Axis Size',
      fieldType: FieldType.select,
      defaultValue: 'max',
      options: [
        {'id': 'min', 'name': 'Min'},
        {'id': 'max', 'name': 'Max'},
      ],
    ),
  ],
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;
    final mainAxisAlignment = ComponentUtil.parseMainAxisAlignment(props['mainAxisAlignment']?.toString());
    final crossAxisAlignment = ComponentUtil.parseCrossAxisAlignment(props['crossAxisAlignment']?.toString());
    final mainAxisSize = ComponentUtil.parseMainAxisSize(props['mainAxisSize']?.toString());

    final childrenWidgets = node.children.map((childNode) => renderChild(childNode)).toList();

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: childrenWidgets,
    );
  },
);