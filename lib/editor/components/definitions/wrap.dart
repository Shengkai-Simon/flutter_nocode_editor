import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/parsing_util.dart';
import '../../properties/core/property_code_formatters.dart';
import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_definition.dart';
import '../core/component_types.dart' as ct;
import '../core/widget_node.dart';
import '../core/component_definition.dart';

final RegisteredComponent wrapComponentDefinition = RegisteredComponent(
  type: ct.wrap,
  displayName: ct.wrap,
  icon: Icons.wrap_text,
  defaultProps: {
    'direction': 'horizontal',
    'alignment': 'start',
    'spacing': 0.0,
    'runAlignment': 'start',
    'runSpacing': 0.0,
    'crossAxisAlignment': 'start',
    'clipBehavior': 'none',
  },
  propFields: [
    PropField(
      name: 'direction',
      label: 'Direction',
      fieldType: FieldType.select,
      defaultValue: 'horizontal',
      options: [
        {'id': 'horizontal', 'name': 'Horizontal'},
        {'id': 'vertical', 'name': 'Vertical'},
      ],
      editorBuilder: kDefaultDropdownEditor,
      propertyCategory: PropertyCategory.layout,
      toCode: kEnumCodeFormatter('Axis'),
    ),
    PropField(
      name: 'alignment',
      label: 'Alignment (in Run)',
      fieldType: FieldType.select,
      defaultValue: 'start',
      options: [
        {'id': 'start', 'name': 'Start'},
        {'id': 'end', 'name': 'End'},
        {'id': 'center', 'name': 'Center'},
        {'id': 'spaceBetween', 'name': 'Space Between'},
        {'id': 'spaceAround', 'name': 'Space Around'},
        {'id': 'spaceEvenly', 'name': 'Space Evenly'},
      ],
      editorBuilder: kDefaultDropdownEditor,
      propertyCategory: PropertyCategory.layout,
      toCode: kEnumCodeFormatter('WrapAlignment'),
    ),
    PropField(
      name: 'spacing',
      label: 'Spacing (Main Axis)',
      fieldType: FieldType.number,
      defaultValue: 0.0,
      editorBuilder: kSliderNumberInputEditor,
      editorConfig: {'minValue': 0.0, 'maxValue': 100.0, 'decimalPlaces': 1},
      propertyCategory: PropertyCategory.spacing,
      toCode: kNumberCodeFormatter
    ),
    PropField(
      name: 'runAlignment',
      label: 'Run Alignment (Cross Axis)',
      fieldType: FieldType.select,
      defaultValue: 'start',
      options: [
        {'id': 'start', 'name': 'Start'},
        {'id': 'end', 'name': 'End'},
        {'id': 'center', 'name': 'Center'},
        {'id': 'spaceBetween', 'name': 'Space Between'},
        {'id': 'spaceAround', 'name': 'Space Around'},
        {'id': 'spaceEvenly', 'name': 'Space Evenly'},
      ],
      editorBuilder: kDefaultDropdownEditor,
      propertyCategory: PropertyCategory.layout,
      toCode: kEnumCodeFormatter('WrapAlignment'),
    ),
    PropField(
      name: 'runSpacing',
      label: 'Run Spacing (Cross Axis)',
      fieldType: FieldType.number,
      defaultValue: 0.0,
      editorBuilder: kSliderNumberInputEditor,
      editorConfig: {'minValue': 0.0, 'maxValue': 100.0, 'decimalPlaces': 1},
      propertyCategory: PropertyCategory.spacing,
      toCode: kNumberCodeFormatter
    ),
    PropField(
      name: 'crossAxisAlignment',
      label: 'Cross Axis Alignment (in Run)',
      fieldType: FieldType.select,
      defaultValue: 'start',
      options: [
        {'id': 'start', 'name': 'Start'},
        {'id': 'end', 'name': 'End'},
        {'id': 'center', 'name': 'Center'},
        {'id': 'stretch', 'name': 'Stretch'},
      ],
      editorBuilder: kDefaultDropdownEditor,
      propertyCategory: PropertyCategory.layout,
      toCode: kEnumCodeFormatter('WrapCrossAlignment'),
    ),
    PropField(
      name: 'clipBehavior',
      label: 'Clip Behavior',
      fieldType: FieldType.select,
      defaultValue: 'none',
      options: [
        {'id': 'none', 'name': 'None'},
        {'id': 'hardEdge', 'name': 'Hard Edge'},
        {'id': 'antiAlias', 'name': 'Anti Alias'},
        {'id': 'antiAliasWithSaveLayer', 'name': 'Anti Alias With SaveLayer'},
      ],
      editorBuilder: kDefaultDropdownEditor,
      propertyCategory: PropertyCategory.appearance,
      toCode: kEnumCodeFormatter('Clip'),
    ),
  ],
  childPolicy: ChildAcceptancePolicy.multiple,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;

    final Axis direction = ParsingUtil.parseAxis(props['direction'] as String?);
    final WrapAlignment alignment = ParsingUtil.parseWrapAlignment(props['alignment'] as String?);
    final double spacing = (props['spacing'] as num?)?.toDouble() ?? 0.0;
    final WrapAlignment runAlignment = ParsingUtil.parseWrapAlignment(props['runAlignment'] as String?);
    final double runSpacing = (props['runSpacing'] as num?)?.toDouble() ?? 0.0;
    final WrapCrossAlignment crossAxisAlignment = ParsingUtil.parseWrapCrossAlignment(props['crossAxisAlignment'] as String?);
    final Clip clipBehavior = ParsingUtil.parseClipBehavior(props['clipBehavior'] as String?);


    final List<Widget> childrenWidgets = node.children.map((childNode) => renderChild(childNode)).toList();

    if (childrenWidgets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(4)
        ),
        child: Text(
          'Wrap (add children)',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
        ),
      );
    }

    return Wrap(
      direction: direction,
      alignment: alignment,
      spacing: spacing,
      runAlignment: runAlignment,
      runSpacing: runSpacing,
      crossAxisAlignment: crossAxisAlignment,
      clipBehavior: clipBehavior,
      children: childrenWidgets,
    );
  },
  category: ComponentCategory.layout,
);