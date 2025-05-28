import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/component_registry.dart';
import '../../core/widget_node.dart';
import '../utils/component_util.dart';
import '../../core/common_component_props.dart';

StackFit _parseStackFit(String? fitString) {
  switch (fitString) {
    case 'loose': return StackFit.loose;
    case 'expand': return StackFit.expand;
    case 'passthrough': return StackFit.passthrough;
    default: return StackFit.loose;
  }
}

Clip _parseClipBehavior(String? clipString) {
  switch (clipString) {
    case 'none': return Clip.none;
    case 'hardEdge': return Clip.hardEdge;
    case 'antiAlias': return Clip.antiAlias;
    case 'antiAliasWithSaveLayer': return Clip.antiAliasWithSaveLayer;
    default: return Clip.hardEdge;
  }
}

final RegisteredComponent stackComponentDefinition = RegisteredComponent(
  type: 'Stack',
  displayName: 'Stack',
  icon: Icons.layers,
  defaultProps: {
    ...ChildAlignmentProps.defaults,
    'alignment': 'topLeft',

    'fit': 'loose',
    'clipBehavior': 'hardEdge',
  },
  propFields: [
    ...ChildAlignmentProps.fields,

    PropField(
      name: 'fit',
      label: 'Stack Fit',
      fieldType: FieldType.select,
      defaultValue: 'loose',
      options: [
        {'id': 'loose', 'name': 'Loose (children size themselves)'},
        {'id': 'expand', 'name': 'Expand (children expand to fit stack)'},
        {'id': 'passthrough', 'name': 'Passthrough (constraints pass through)'},
      ],
    ),
    PropField(
      name: 'clipBehavior',
      label: 'Clip Behavior',
      fieldType: FieldType.select,
      defaultValue: 'hardEdge',
      options: [
        {'id': 'hardEdge', 'name': 'Hard Edge'},
        {'id': 'antiAlias', 'name': 'Anti Alias'},
        {'id': 'antiAliasWithSaveLayer', 'name': 'Anti Alias With SaveLayer'},
        {'id': 'none', 'name': 'None'},
      ],
    ),
  ],
  childPolicy: ChildAcceptancePolicy.multiple,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;

    final AlignmentGeometry alignment = ComponentUtil.parseAlignment(props['alignment'] as String?);

    final StackFit fit = _parseStackFit(props['fit'] as String?);
    final Clip clipBehavior = _parseClipBehavior(props['clipBehavior'] as String?);

    final List<Widget> childrenWidgets = node.children.map((childNode) => renderChild(childNode)).toList();

    return Stack(
      alignment: alignment,
      fit: fit,
      clipBehavior: clipBehavior,
      children: childrenWidgets,
    );
  },
);