import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/parsing_util.dart';
import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_meta.dart';
import '../core/common_props.dart';
import '../core/component_model.dart';

final Map<String, dynamic> _textFieldDefaultProps = {
  'initialValue': '',
  'hintText': 'Hint text',
  'labelText': '',
  'obscureText': false,
  'keyboardType': 'text',
  'maxLines': 1,
  'minLines': 1,
  'maxLength': null,
  ...BasicTextStyleProps.defaults,
  'textColor': '#000000',
  'fontSize': 14.0,
};

final RegisteredComponent textFieldComponentDefinition = RegisteredComponent(
  type: 'TextField',
  displayName: 'Text Field',
  icon: Icons.edit_note,
  defaultProps: _textFieldDefaultProps,
  propFields: [
    PropField(
      name: 'initialValue',
      label: 'Initial Value',
      fieldType: FieldType.string,
      defaultValue:  _textFieldDefaultProps['initialValue'],
      editorBuilder: kDefaultTextInputEditor,
    ),
    PropField(
      name: 'hintText',
      label: 'Hint Text',
      fieldType: FieldType.string,
      defaultValue: _textFieldDefaultProps['hintText'],
      editorBuilder: kDefaultTextInputEditor,
    ),
    PropField(
      name: 'labelText',
      label: 'Label Text',
      fieldType: FieldType.string,
      defaultValue: _textFieldDefaultProps['labelText'],
      editorBuilder: kDefaultTextInputEditor,
    ),
    PropField(
      name: 'obscureText',
      label: 'Obscure Text (Password)',
      fieldType: FieldType.boolean,
      defaultValue: _textFieldDefaultProps['obscureText'],
      editorBuilder: kDefaultSwitchEditor,
    ),
    PropField(
      name: 'keyboardType',
      label: 'Keyboard Type',
      fieldType: FieldType.select,
      defaultValue: _textFieldDefaultProps['keyboardType'],
      options: [
        {'id': 'text', 'name': 'Text (Plain)'},
        {'id': 'multiline', 'name': 'Multiline'},
        {'id': 'number', 'name': 'Number'},
        {'id': 'phone', 'name': 'Phone'},
        {'id': 'datetime', 'name': 'Date Time'},
        {'id': 'emailaddress', 'name': 'Email Address'},
        {'id': 'url', 'name': 'URL'},
        {'id': 'visiblepassword', 'name': 'Visible Password'},
      ],
      editorBuilder: kDefaultDropdownEditor,
    ),
    PropField(
      name: 'maxLines',
      label: 'Max Lines',
      fieldType: FieldType.number,
      defaultValue: _textFieldDefaultProps['maxLines'],
      editorBuilder: kIntegerStepperEditor,
      editorConfig: {'minValue': 1},
    ),
    PropField(
      name: 'minLines',
      label: 'Min Lines',
      fieldType: FieldType.number,
      defaultValue: _textFieldDefaultProps['minLines'],
      editorBuilder: kIntegerStepperEditor,
      editorConfig: {'minValue': 1},
    ),
    PropField(
      name: 'maxLength',
      label: 'Max Length',
      fieldType: FieldType.number,
      defaultValue: _textFieldDefaultProps['maxLength'],
      editorBuilder: kIntegerStepperEditor,
      editorConfig: {'minValue': 1},
    ),
    ...BasicTextStyleProps.fields.map((field) {
      String label = field.label;
      if (field.name == 'textColor') label = 'Input Text Color';
      if (field.name == 'fontSize') label = 'Input Font Size';

      dynamic defaultValue = field.defaultValue;
      if (field.name == 'textColor' && _textFieldDefaultProps.containsKey('textColor')) {
        defaultValue = _textFieldDefaultProps['textColor'];
      }
      if (field.name == 'fontSize' && _textFieldDefaultProps.containsKey('fontSize')) {
        defaultValue = _textFieldDefaultProps['fontSize'];
      }
      return PropField(
          name: field.name,
          label: label,
          fieldType: field.fieldType,
          defaultValue: defaultValue,
          options: field.options,
          editorBuilder: field.editorBuilder);
    }),
  ],
  childPolicy: ChildAcceptancePolicy.none,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;
    final String initialValue = props['initialValue'] as String? ?? _textFieldDefaultProps['initialValue'] as String;
    final String hintText = props['hintText'] as String? ?? _textFieldDefaultProps['hintText'] as String;
    final String labelText = props['labelText'] as String? ?? _textFieldDefaultProps['labelText'] as String;
    final bool obscureText = (props['obscureText'] as bool?) ?? _textFieldDefaultProps['obscureText'] as bool;
    final TextInputType keyboardType = ParsingUtil.parseTextInputType(props['keyboardType'] as String? ?? _textFieldDefaultProps['keyboardType'] as String);

    final int? maxLines = obscureText ? 1 : (props['maxLines'] as num?)?.toInt() ?? _textFieldDefaultProps['maxLines'] as int?;
    final int? minLines = (props['minLines'] as num?)?.toInt() ?? _textFieldDefaultProps['minLines'] as int?;
    final int? maxLength = (props['maxLength'] as num?)?.toInt() ?? _textFieldDefaultProps['maxLength'] as int?;

    final double fontSize = (props['fontSize'] as num?)?.toDouble() ?? _textFieldDefaultProps['fontSize'] as double;
    final Color textColor = ParsingUtil.parseColor(props['textColor']?.toString(), defaultColor: ParsingUtil.parseColor(_textFieldDefaultProps['textColor'] as String));
    final FontWeight fontWeight = ParsingUtil.parseFontWeight(props['fontWeight']?.toString() ?? BasicTextStyleProps.defaults['fontWeight'] as String);
    final FontStyle fontStyle = ParsingUtil.parseFontStyle(props['fontStyle']?.toString() ?? BasicTextStyleProps.defaults['fontStyle'] as String);

    final controller = TextEditingController(text: initialValue);

    return AbsorbPointer(
      absorbing: true,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText.isNotEmpty ? hintText : null,
          labelText: labelText.isNotEmpty ? labelText : null,
          border: const OutlineInputBorder(),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
        ),
        readOnly: true,
      ),
    );
  },
  category: ComponentCategory.input,
);