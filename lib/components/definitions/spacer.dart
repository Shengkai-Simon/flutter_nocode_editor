import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/component_registry.dart';
import '../../core/property_editor_builders.dart';
import '../../core/widget_node.dart';

final RegisteredComponent spacerComponentDefinition = RegisteredComponent(
  type: 'Spacer',
  displayName: 'Spacer',
  icon: Icons.space_bar,
  defaultProps: {
    'flex': 1,
  },
  propFields: [
    PropField(
      name: 'flex',
      label: 'Flex Factor',
      fieldType: FieldType.number,
      defaultValue: 1,
      editorBuilder: kPositiveNumberInputEditor,
    ),
  ],
  childPolicy: ChildAcceptancePolicy.none,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;
    final int flex = (props['flex'] as num?)?.toInt() ?? 1;

    return Spacer(
      flex: flex,
    );
  },
);