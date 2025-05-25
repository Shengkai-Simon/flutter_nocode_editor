import 'package:flutter/material.dart';
import 'package:flutter_editor/core/widget_node.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/definitions/column.dart';
import '../components/definitions/container.dart';
import '../components/definitions/elevated_button.dart';
import '../components/definitions/padding.dart';
import '../components/definitions/row.dart';
import '../components/definitions/text.dart';

/// support for field types in editor's right-side properties panel
enum FieldType { string, number, color, select, boolean, alignment, edgeInsets }

/// Support displaying component field a property
class PropField {
  final String name;
  final String label;
  final FieldType fieldType;
  final dynamic defaultValue;
  final List<Map<String, String>>? options;

  const PropField({
    required this.name,
    required this.label,
    required this.fieldType,
    this.defaultValue,
    this.options,
  });
}

/// Register the metadata structure for component
class RegisteredComponent {
  final String type;
  final String displayName;
  final IconData? icon;
  final List<PropField> propFields;
  final Map<String, dynamic> defaultProps;

  /// return a widget builder based on props
  final Widget Function(WidgetNode node, WidgetRef ref, Widget Function(WidgetNode childNode) renderChild) builder;

  const RegisteredComponent({
    required this.type,
    required this.displayName,
    this.icon,
    required this.propFields,
    required this.defaultProps,
    required this.builder,
  });
}

/// Registry: Component Type → Component Metadata
final Map<String, RegisteredComponent> registeredComponents = {
  textComponentDefinition.type: textComponentDefinition,
  containerComponentDefinition.type: containerComponentDefinition,
  columnComponentDefinition.type: columnComponentDefinition,
  rowComponentDefinition.type: rowComponentDefinition,
  paddingComponentDefinition.type: paddingComponentDefinition,
  elevatedButtonComponentDefinition.type: elevatedButtonComponentDefinition,
};


