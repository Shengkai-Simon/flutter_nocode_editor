import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/component_registry.dart';
import '../../core/widget_node.dart';
import '../utils/component_util.dart';

final RegisteredComponent textComponentDefinition = RegisteredComponent(
  type: 'Text',
  displayName: 'Text',
  icon: Icons.text_fields,
  defaultProps: {
    'text': 'Hello World',
    'fontSize': 16.0,
    'color': '',
    'softWrap': true,
    'textAlign': 'start',
    'fontWeight': 'normal',
    'fontStyle': 'normal',
    'maxLines': null,
    'overflow': 'clip',
  },
  propFields: [
    PropField(
      name: 'text',
      label: 'Text',
      fieldType: FieldType.string,
      defaultValue: 'Hello World',
    ),
    PropField(
      name: 'fontSize',
      label: 'Font Size',
      fieldType: FieldType.number,
      defaultValue: 16.0,
    ),
    PropField(
      name: 'color',
      label: 'Text Color',
      fieldType: FieldType.color,
      defaultValue: '',
    ),
    PropField(
      name: 'softWrap',
      label: 'Soft Wrap',
      fieldType: FieldType.boolean,
      defaultValue: true,
    ),
    PropField(
      name: 'textAlign',
      label: 'Text Align',
      fieldType: FieldType.select,
      defaultValue: 'start',
      options: [
        {'id': 'left', 'name': 'Left'},
        {'id': 'right', 'name': 'Right'},
        {'id': 'center', 'name': 'Center'},
        {'id': 'justify', 'name': 'Justify'},
        {'id': 'start', 'name': 'Start'},
        {'id': 'end', 'name': 'End'},
      ],
    ),
    PropField(
      // ADDED: fontWeight
      name: 'fontWeight',
      label: 'Font Weight',
      fieldType: FieldType.select,
      defaultValue: 'normal',
      options: [
        {'id': 'normal', 'name': 'Normal (w400)'},
        {'id': 'bold', 'name': 'Bold (w700)'},
        {'id': 'w100', 'name': 'Thin (w100)'},
        {'id': 'w200', 'name': 'Extra-Light (w200)'},
        {'id': 'w300', 'name': 'Light (w300)'},
        {'id': 'w500', 'name': 'Medium (w500)'},
        {'id': 'w600', 'name': 'Semi-Bold (w600)'},
        {'id': 'w800', 'name': 'Extra-Bold (w800)'},
        {'id': 'w900', 'name': 'Black (w900)'},
      ],
    ),
    PropField(
      name: 'fontStyle',
      label: 'Font Style',
      fieldType: FieldType.select,
      defaultValue: 'normal',
      options: [
        {'id': 'normal', 'name': 'Normal'},
        {'id': 'italic', 'name': 'Italic'},
      ],
    ),
    PropField(
      name: 'maxLines',
      label: 'Max Lines',
      fieldType: FieldType.number,
      defaultValue: null,
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
    ),
  ],
  childPolicy: ChildAcceptancePolicy.none,
  builder: (
    WidgetNode node,
    WidgetRef ref,
    Widget Function(WidgetNode childNode) renderChild,
  ) {
    final props = node.props;

    final String textValue = props['text']?.toString() ?? 'Hello World';
    final double fontSize = (props['fontSize'] as num?)?.toDouble() ?? 16.0;
    final bool softWrap = (props['softWrap'] as bool?) ?? true;
    final Color textColor = ComponentUtil.parseColor(props['color']?.toString());
    final TextAlign textAlign = ComponentUtil.parseTextAlign(props['textAlign']?.toString());

    final FontWeight fontWeight = ComponentUtil.parseFontWeight(props['fontWeight']?.toString());
    final FontStyle fontStyle = ComponentUtil.parseFontStyle(props['fontStyle']?.toString());

    final int? maxLines = (props['maxLines'] as num?)?.toInt();

    final TextOverflow overflow = ComponentUtil.parseTextOverflow(props['overflow']?.toString());

    return Text(
      textValue,
      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
      ),
      softWrap: softWrap,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  },
);
