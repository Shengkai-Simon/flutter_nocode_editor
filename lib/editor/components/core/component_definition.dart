import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../properties/core/property_definition.dart';
import 'widget_node.dart';

/// Defines the categorization of components in the editor's left panel.
/// This is structured based on a user's typical UI building workflow.
enum ComponentCategory {
  /// For widgets that arrange multiple children, like Row, Column, Stack, Wrap.
  multiChildLayout,

  /// For widgets that decorate or position a single child, like Container, Padding, Center.
  singleChildLayout,

  /// For Flex-specific children that only work inside Row/Column.
  flexChild,

  /// For displaying static content.
  content,

  /// For user interaction and forms.
  input,
}

/// support how many children a component can have
enum ChildAcceptancePolicy {
  none, // Cannot have any children
  single, // Can have exactly one child
  multiple, // Can have multiple children
}

/// Register the metadata structure for component
class RegisteredComponent {
  final String type;
  final String displayName;
  final IconData? icon;
  final List<PropField> propFields;
  final Map<String, dynamic> defaultProps;
  final ChildAcceptancePolicy childPolicy;
  final ComponentCategory category;
  final List<String>? requiredParentTypes;

  final Widget Function(WidgetNode node, WidgetRef ref, Widget Function(WidgetNode childNode) renderChild) builder;

  const RegisteredComponent({
    required this.type,
    required this.displayName,
    this.icon,
    required this.propFields,
    required this.defaultProps,
    required this.builder,
    required this.childPolicy,
    required this.category,
    this.requiredParentTypes,
  });
}
