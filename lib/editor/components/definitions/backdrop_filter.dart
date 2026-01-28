import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../properties/core/property_code_formatters.dart';
import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_definition.dart';
import '../core/widget_node.dart';
import '../core/component_definition.dart';
import '../core/component_types.dart' as ct;

/// The component definition for the BackdropFilter widget.
final RegisteredComponent backdropFilterComponentDefinition = RegisteredComponent(
  type: ct.backdropFilter,
  displayName: 'Backdrop Filter',
  icon: Icons.blur_on,
  defaultProps: {
    'blurSigmaX': 10.0,
    'blurSigmaY': 10.0,
  },
  propFields: [
    PropField(
        name: 'blurSigmaX',
        label: 'Horizontal blur radius (Blur X)',
        fieldType: FieldType.number,
        defaultValue: 10.0,
        editorBuilder: kSliderNumberInputEditor,
        editorConfig: {'minValue': 0.0, 'maxValue': 50.0, 'divisions': 50, 'decimalPlaces': 1},
        propertyCategory: PropertyCategory.appearance,
        toCode: kNumberCodeFormatter
    ),
    PropField(
        name: 'blurSigmaY',
        label: 'Vertical blur radius (Blur Y)',
        fieldType: FieldType.number,
        defaultValue: 10.0,
        editorBuilder: kSliderNumberInputEditor,
        editorConfig: {'minValue': 0.0, 'maxValue': 50.0, 'divisions': 50, 'decimalPlaces': 1},
        propertyCategory: PropertyCategory.appearance,
        toCode: kNumberCodeFormatter
    ),
  ],
  childPolicy: ChildAcceptancePolicy.single,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;

    double sigmaX = (props['blurSigmaX'] as num?)?.toDouble() ?? 0.0;
    double sigmaY = (props['blurSigmaY'] as num?)?.toDouble() ?? 0.0;

    // Sigma values cannot be negative.
    if (sigmaX < 0) sigmaX = 0;
    if (sigmaY < 0) sigmaY = 0;

    Widget? childWidget;
    if (node.children.isNotEmpty) {
      childWidget = renderChild(node.children.first);
    } else {
      // Provide an empty, non-visible widget to satisfy the 'child' requirement,
      // preventing runtime errors without adding visual clutter.
      childWidget = Container();
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
      child: childWidget,
    );
  },
  // As discussed, this is a single-child layout component.
  category: ComponentCategory.singleChildLayout,
);
