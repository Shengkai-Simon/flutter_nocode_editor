import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/parsing_util.dart';
import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_meta.dart';
import '../core/common_props.dart';
import '../core/component_model.dart';

final Map<String, dynamic> _dropdownButtonDefaultProps = {
  'itemsString': 'Option 1,Option 2,Option 3',
  'selectedValue': null,
  'hintText': 'Select an option',
  'isExpanded': false,
  ...BasicTextStyleProps.defaults,
  'textColor': '#000000',
  'fontSize': 14.0,
};

final RegisteredComponent dropdownButtonComponentDefinition = RegisteredComponent(
  type: 'DropdownButton',
  displayName: 'Dropdown',
  icon: Icons.arrow_drop_down_circle_outlined,
  defaultProps: _dropdownButtonDefaultProps,
  propFields: [
    PropField(
      name: 'itemsString',
      label: 'Items (comma-separated)',
      fieldType: FieldType.string,
      defaultValue: _dropdownButtonDefaultProps['itemsString'],
      editorBuilder: kDefaultTextInputEditor,
    ),
    PropField(
      name: 'selectedValue',
      label: 'Selected Value (must match an item)',
      fieldType: FieldType.string,
      defaultValue: _dropdownButtonDefaultProps['selectedValue'],
      editorBuilder: kDefaultTextInputEditor,
    ),
    PropField(
      name: 'hintText',
      label: 'Hint Text (if no value selected)',
      fieldType: FieldType.string,
      defaultValue: _dropdownButtonDefaultProps['hintText'],
      editorBuilder: kDefaultTextInputEditor,
    ),
    PropField(
      name: 'isExpanded',
      label: 'Is Expanded (fill width)',
      fieldType: FieldType.boolean,
      defaultValue: _dropdownButtonDefaultProps['isExpanded'],
      editorBuilder: kDefaultSwitchEditor,
    ),
    ...BasicTextStyleProps.fields.map((field) {
      String labelPrefix = "Item ";
      dynamic defaultValue = field.defaultValue;
      if (field.name == 'textColor' && _dropdownButtonDefaultProps.containsKey('textColor')) {
        defaultValue = _dropdownButtonDefaultProps['textColor'];
      }
      if (field.name == 'fontSize' && _dropdownButtonDefaultProps.containsKey('fontSize')) {
        defaultValue = _dropdownButtonDefaultProps['fontSize'];
      }
      return PropField(
          name: field.name,
          label: labelPrefix + field.label,
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
    final String itemsString = props['itemsString'] as String? ?? _dropdownButtonDefaultProps['itemsString'] as String;
    final List<String> items = itemsString.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final String? selectedValue = props['selectedValue'] as String? ?? _dropdownButtonDefaultProps['selectedValue'] as String?;
    final String hintText = props['hintText'] as String? ?? _dropdownButtonDefaultProps['hintText'] as String;
    final bool isExpanded = (props['isExpanded'] as bool?) ?? _dropdownButtonDefaultProps['isExpanded'] as bool;

    final double fontSize = (props['fontSize'] as num?)?.toDouble() ?? _dropdownButtonDefaultProps['fontSize'] as double;
    final Color textColor = ParsingUtil.parseColor(
        props['textColor']?.toString(),
        defaultColor: ParsingUtil.parseColor(_dropdownButtonDefaultProps['textColor'] as String)
    );
    final FontWeight fontWeight = ParsingUtil.parseFontWeight(props['fontWeight']?.toString() ?? BasicTextStyleProps.defaults['fontWeight'] as String);
    final FontStyle fontStyle = ParsingUtil.parseFontStyle(props['fontStyle']?.toString() ?? BasicTextStyleProps.defaults['fontStyle'] as String);

    final textStyle = TextStyle(
      fontSize: fontSize,
      color: textColor,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
    );

    String? currentDropdownValue = (selectedValue != null && items.contains(selectedValue)) ? selectedValue : null;

    return AbsorbPointer(
      absorbing: true,
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        ),
        value: currentDropdownValue,
        hint: Text(hintText, style: textStyle.copyWith(color: textStyle.color?.withOpacity(0.6))),
        isExpanded: isExpanded,
        icon: const Icon(Icons.arrow_drop_down),
        style: textStyle,
        onChanged: null,
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: textStyle),
          );
        }).toList().isEmpty
            ? [
          DropdownMenuItem<String>(
            value: null,
            enabled: false,
            child: Text(items.isEmpty ? (itemsString.trim().isEmpty ? "No items defined" : "Processing items...") : "No valid items", style: textStyle.copyWith(fontStyle: FontStyle.italic)),
          )
        ]
            : items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: textStyle),
          );
        }).toList(),
      ),
    );
  },
);