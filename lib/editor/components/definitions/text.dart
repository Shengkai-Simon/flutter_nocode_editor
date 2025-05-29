import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/parsing_util.dart';
import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_definition.dart';
import '../../properties/core/property_common_groups.dart';
import '../core/widget_node.dart';
import '../core/component_definition.dart';

final RegisteredComponent textComponentDefinition = RegisteredComponent(
  type: 'Text',
  displayName: 'Text',
  icon: Icons.text_fields,
  defaultProps: {
    ...BasicTextStyleProps.defaults,
    'text': 'Hello World',
    'softWrap': true,
    'maxLines': null,
    'overflow': 'clip',
  },
  propFields: [
    PropField(name: 'text',
        label: 'Text Content',
        fieldType: FieldType.string,
        defaultValue: 'Hello World',
        editorBuilder: kDefaultTextInputEditor,
        propertyCategory: PropertyCategory.value
    ),

    ...BasicTextStyleProps.fields,

    PropField(name: 'softWrap',
        label: 'Soft Wrap',
        fieldType: FieldType.boolean,
        defaultValue: true,
        editorBuilder: kDefaultSwitchEditor,
        propertyCategory: PropertyCategory.appearance
    ),
    PropField(
      name: 'maxLines',
      label: 'Max Lines',
      fieldType: FieldType.number,
      defaultValue: null,
      editorBuilder: kIntegerStepperEditor,
      editorConfig: {'minValue': 1, 'step': 1},
      propertyCategory: PropertyCategory.appearance
    ),
    PropField(
      name: 'overflow',
      label: 'Overflow',
      fieldType: FieldType.select,
      defaultValue: 'clip',
      options: [
        {'id': 'clip', 'name': 'Clip'},
        {'id': 'ellipsis', 'name': 'Ellipsis (...)'},
        {'id': 'fade', 'name': 'Fade'},
        {'id': 'visible', 'name': 'Visible (can overflow bounds)'},
      ],
      editorBuilder: kDefaultDropdownEditor,
      propertyCategory: PropertyCategory.appearance
    ),
  ],
  childPolicy: ChildAcceptancePolicy.none,
  builder: (WidgetNode node, WidgetRef ref, Widget Function(WidgetNode childNode) renderChild) {
    final props = node.props;

    final String textValue = props['text']?.toString() ?? 'Hello World';
    final bool softWrap = (props['softWrap'] as bool?) ?? true;
    final int? maxLines = (props['maxLines'] as num?)?.toInt();
    final TextOverflow overflow = ParsingUtil.parseTextOverflow(props['overflow']?.toString());

    final double fontSize = (props['fontSize'] as num?)?.toDouble() ?? BasicTextStyleProps.defaults['fontSize'] as double;
    final Color textColor = ParsingUtil.parseColor(props['textColor']?.toString());
    final FontWeight fontWeight = ParsingUtil.parseFontWeight(props['fontWeight']?.toString());
    final FontStyle fontStyle = ParsingUtil.parseFontStyle(props['fontStyle']?.toString());
    final TextAlign textAlign = ParsingUtil.parseTextAlign(props['textAlign']?.toString());

    return Text(
      textValue,
      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
      ),
      textAlign: textAlign,
      softWrap: softWrap,
      maxLines: maxLines,
      overflow: overflow,
    );
  },
  category: ComponentCategory.content,
);