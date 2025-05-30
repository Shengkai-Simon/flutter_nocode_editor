import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/parsing_util.dart';
import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_definition.dart';
import '../../properties/core/property_common_groups.dart';
import '../core/widget_node.dart';
import '../core/component_definition.dart';


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
      editorBuilder: kDefaultDropdownEditor,
      propertyCategory: PropertyCategory.layout
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
      editorBuilder: kDefaultDropdownEditor,
      propertyCategory: PropertyCategory.appearance
    ),
  ],
  childPolicy: ChildAcceptancePolicy.multiple,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;

    final AlignmentGeometry alignment = ParsingUtil.parseAlignment(props['alignment'] as String?);

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
  category: ComponentCategory.layout,
);