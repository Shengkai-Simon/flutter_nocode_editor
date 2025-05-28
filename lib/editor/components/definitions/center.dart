import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_meta.dart';
import '../core/component_model.dart';

final RegisteredComponent centerComponentDefinition = RegisteredComponent(
  type: 'Center',
  displayName: 'Center',
  icon: Icons.align_horizontal_center,
  defaultProps: {
    'widthFactor': null,
    'heightFactor': null,
  },
  propFields: [
    PropField(
      name: 'widthFactor',
      label: 'Width Factor',
      fieldType: FieldType.number,
      defaultValue: null,
      editorBuilder: kDefaultNumberInputEditor,
    ),
    PropField(
      name: 'heightFactor',
      label: 'Height Factor',
      fieldType: FieldType.number,
      defaultValue: null,
      editorBuilder: kDefaultNumberInputEditor,
    ),
  ],
  childPolicy: ChildAcceptancePolicy.single,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;
    final double? widthFactor = (props['widthFactor'] as num?)?.toDouble();
    final double? heightFactor = (props['heightFactor'] as num?)?.toDouble();
    Widget? childWidget;
    if (node.children.isNotEmpty) {
      childWidget = renderChild(node.children.first);
    }
    return Center(
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: childWidget,
    );
  },
);