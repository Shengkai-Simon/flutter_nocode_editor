import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/component_registry.dart';
import '../../core/editor_state.dart';
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

    if (ref.read(selectedNodeIdProvider) == node.id) {
      return Container(
          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
          ),
          alignment: Alignment.center,
          child: Text(
            'Spacer (flex: $flex)',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          )
      );
    }

    return Spacer(
      flex: flex,
    );
  },
);