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

final RegisteredComponent alignComponentDefinition = RegisteredComponent(
  type: ct.align,
  displayName: ct.align,
  icon: Icons.align_vertical_bottom,
  defaultProps: {
    ...ChildAlignmentProps.defaults,
    'widthFactor': null,
    'heightFactor': null,
  },
  propFields: [
    ...ChildAlignmentProps.fields,

    PropField(
        name: 'widthFactor',
        label: 'Width Factor',
        fieldType: FieldType.number,
        defaultValue: null,
        editorBuilder: kDefaultNumberInputEditor,
        propertyCategory: PropertyCategory.sizing,
        toCode: kNumberCodeFormatter
    ),
    PropField(
        name: 'heightFactor',
        label: 'Height Factor',
        fieldType: FieldType.number,
        defaultValue: null,
        editorBuilder: kDefaultNumberInputEditor,
        propertyCategory: PropertyCategory.sizing,
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

    final AlignmentGeometry alignment = ParsingUtil.parseAlignment(props['alignment'] as String?);

    final double? widthFactor = (props['widthFactor'] as num?)?.toDouble();
    final double? heightFactor = (props['heightFactor'] as num?)?.toDouble();

    Widget? childWidget;
    if (node.children.isNotEmpty) {
      childWidget = renderChild(node.children.first);
    }

    return Align(
      alignment: alignment,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: childWidget,
    );
  },
  category: ComponentCategory.singleChildLayout,
);
