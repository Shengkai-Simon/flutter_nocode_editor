import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/core/component_model.dart';

/// support for field types in editor's right-side properties panel
enum FieldType { string, number, color, select, boolean, alignment, edgeInsets }

/// support how many children a component can have
enum ChildAcceptancePolicy {
  none, // Cannot have any children
  single, // Can have exactly one child
  multiple, // Can have multiple children
}

typedef PropertyEditorBuilder = Widget Function(
    BuildContext context,
    PropField field,
    dynamic currentValue,
    void Function(dynamic newValue) onChanged,
    );


/// Support displaying component field a property
class PropField {
  final String name;
  final String label;
  final FieldType fieldType;
  final dynamic defaultValue;
  final List<Map<String, String>>? options;
  final PropertyEditorBuilder? editorBuilder;

  const PropField({
    required this.name,
    required this.label,
    required this.fieldType,
    this.defaultValue,
    this.options,
    required this.editorBuilder,
  });
}

/// Register the metadata structure for component
class RegisteredComponent {
  final String type;
  final String displayName;
  final IconData? icon;
  final List<PropField> propFields;
  final Map<String, dynamic> defaultProps;
  final ChildAcceptancePolicy childPolicy;

  /// return a widget builder based on props
  final Widget Function(WidgetNode node, WidgetRef ref, Widget Function(WidgetNode childNode) renderChild) builder;

  const RegisteredComponent({
    required this.type,
    required this.displayName,
    this.icon,
    required this.propFields,
    required this.defaultProps,
    required this.builder,
    required this.childPolicy,
  });
}