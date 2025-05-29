import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_definition.dart';
import '../core/widget_node.dart';
import '../core/component_definition.dart';

final RegisteredComponent aspectRatioComponentDefinition = RegisteredComponent(
  type: 'AspectRatio',
  displayName: 'Aspect Ratio',
  icon: Icons.aspect_ratio,
  defaultProps: {
    'aspectRatio': 1.0,
  },
  propFields: [
    PropField(
      name: 'aspectRatio',
      label: 'Aspect Ratio (width/height)',
      fieldType: FieldType.number,
      defaultValue: 1.0,
      editorBuilder: kSliderNumberInputEditor,
      editorConfig: {'minValue': 0.1, 'maxValue': 4.0, 'divisions': 39, 'decimalPlaces': 2},
      propertyCategory: PropertyCategory.sizing,
    ),
  ],
  childPolicy: ChildAcceptancePolicy.single,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;

    double aspectRatioValue = (props['aspectRatio'] as num?)?.toDouble() ?? 1.0;
    if (aspectRatioValue <= 0) {
      print("Warning: AspectRatio received invalid value $aspectRatioValue. Defaulting to 1.0.");
      aspectRatioValue = 1.0;
    }

    Widget? childWidget;
    if (node.children.isNotEmpty) {
      childWidget = renderChild(node.children.first);
    } else {
      childWidget = Container(
        constraints: const BoxConstraints.expand(),
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: Text(
          'Child for AspectRatio',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: aspectRatioValue,
      child: childWidget,
    );
  },
  category: ComponentCategory.layout,
);