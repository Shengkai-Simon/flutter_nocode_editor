import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/parsing_util.dart';
import '../../properties/core/property_code_formatters.dart';
import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_definition.dart';
import '../../properties/core/property_common_groups.dart';
import '../core/widget_node.dart';
import '../core/component_definition.dart';
import '../core/component_types.dart' as ct;

final RegisteredComponent cardComponentDefinition = RegisteredComponent(
  type: ct.card,
  displayName: ct.card,
  icon: Icons.credit_card_outlined,
  defaultProps: {
    ...BackgroundColorProp.defaults,
    ...MarginProps.defaults,

    'margin': 'all:4.0',
    'shadowColor': null,
    'elevation': 1.0,
    'borderRadius': 4.0,
  },
  propFields: [
    ...BackgroundColorProp.fields,
    ...MarginProps.fields,

    PropField(
        name: 'shadowColor',
        label: 'Shadow Color',
        fieldType: FieldType.color,
        defaultValue: null,
        editorBuilder: kDefaultColorPickerEditor,
        propertyCategory: PropertyCategory.shadow,
        toCode: kColorCodeFormatter
    ),
    PropField(
        name: 'borderRadius',
        label: 'Border Radius',
        fieldType: FieldType.number,
        defaultValue: 4.0,
        editorBuilder: kDefaultNumberInputEditor,
        propertyCategory: PropertyCategory.border,
        toCode: kNumberCodeFormatter
    ),
    PropField(
        name: 'elevation',
        label: 'Elevation',
        fieldType: FieldType.number,
        defaultValue: 1.0,
        editorBuilder: kSliderNumberInputEditor,
        editorConfig: {'minValue': 0.0, 'maxValue': 24.0, 'divisions': 24, 'decimalPlaces': 1},
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

    final String? backgroundColorString = props['backgroundColor'] as String?;
    final Color? cardColor = (backgroundColorString != null && backgroundColorString.isNotEmpty)
        ? ParsingUtil.parseColor(backgroundColorString)
        : null;

    final EdgeInsetsGeometry margin = ParsingUtil.parseEdgeInsets(props['margin'] as String?);

    final String? shadowColorString = props['shadowColor'] as String?;
    final Color? shadowColor = (shadowColorString != null && shadowColorString.isNotEmpty)
        ? ParsingUtil.parseColor(shadowColorString)
        : null;
    final double? elevation = (props['elevation'] as num?)?.toDouble();
    final double borderRadiusValue = (props['borderRadius'] as num?)?.toDouble() ?? 4.0;

    final ShapeBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadiusValue),
    );

    Widget? childWidget;
    if (node.children.isNotEmpty) {
      childWidget = renderChild(node.children.first);
    }

    return Card(
      color: cardColor,
      shadowColor: shadowColor,
      elevation: elevation,
      margin: margin,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: childWidget,
    );
  },
  category: ComponentCategory.singleChildLayout,
);
