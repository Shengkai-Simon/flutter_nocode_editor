import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/component_registry.dart';
import '../../core/widget_node.dart';
import '../utils/component_util.dart';
import '../../core/common_component_props.dart';

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
    PropField(name: 'text', label: 'Text Content', fieldType: FieldType.string, defaultValue: 'Hello World'),

    ...BasicTextStyleProps.fields,

    PropField(name: 'softWrap', label: 'Soft Wrap', fieldType: FieldType.boolean, defaultValue: true),
    PropField(name: 'maxLines', label: 'Max Lines', fieldType: FieldType.number, defaultValue: null),
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
    ),
  ],
  childPolicy: ChildAcceptancePolicy.none,
  builder: (WidgetNode node, WidgetRef ref, Widget Function(WidgetNode childNode) renderChild) {
    final props = node.props;

    final String textValue = props['text']?.toString() ?? 'Hello World';
    final bool softWrap = (props['softWrap'] as bool?) ?? true;
    final int? maxLines = (props['maxLines'] as num?)?.toInt();
    final TextOverflow overflow = ComponentUtil.parseTextOverflow(props['overflow']?.toString());

    final double fontSize = (props['fontSize'] as num?)?.toDouble() ?? BasicTextStyleProps.defaults['fontSize'] as double;
    final Color textColor = ComponentUtil.parseColor(props['textColor']?.toString());
    final FontWeight fontWeight = ComponentUtil.parseFontWeight(props['fontWeight']?.toString());
    final FontStyle fontStyle = ComponentUtil.parseFontStyle(props['fontStyle']?.toString());
    final TextAlign textAlign = ComponentUtil.parseTextAlign(props['textAlign']?.toString());

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
);