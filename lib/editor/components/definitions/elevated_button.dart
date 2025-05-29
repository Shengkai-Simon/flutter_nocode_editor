import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/parsing_util.dart';
import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_meta.dart';
import '../core/common_props.dart';
import '../core/component_model.dart';

final RegisteredComponent elevatedButtonComponentDefinition = RegisteredComponent(
  type: 'ElevatedButton',
  displayName: 'Button',
  icon: Icons.smart_button_outlined,
  defaultProps: {
    'buttonText': 'Click Me',
    'backgroundColor': null,
    'foregroundColor': null,
    'elevation': 2.0,
    ...PaddingProps.defaults,
    'padding': 'symmetric:H16,V8',
  },
  propFields: [
    PropField(name: 'buttonText', label: 'Text', fieldType: FieldType.string, defaultValue: 'Click Me', editorBuilder: kDefaultTextInputEditor, propertyCategory: PropertyCategory.general),
    PropField(name: 'backgroundColor', label: 'Background Color', fieldType: FieldType.color, defaultValue: null, editorBuilder: kDefaultColorPickerEditor, propertyCategory: PropertyCategory.appearance),
    PropField(name: 'foregroundColor', label: 'Foreground Color (Text/Icon)', fieldType: FieldType.color, defaultValue: null, editorBuilder: kDefaultColorPickerEditor, propertyCategory: PropertyCategory.appearance),
    PropField(
        name: 'elevation',
        label: 'Elevation',
        fieldType: FieldType.number,
        defaultValue: 1.0,
        editorBuilder: kSliderNumberInputEditor,
        editorConfig: {'minValue': 0.0, 'maxValue': 24.0, 'divisions': 24, 'decimalPlaces': 1},
        propertyCategory: PropertyCategory.appearance
    ),
    ...PaddingProps.fields,
  ],
  childPolicy: ChildAcceptancePolicy.single,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;
    final buttonText = props['buttonText']?.toString() ?? 'Button';

    final String? backgroundColorHex = props['backgroundColor'] as String?;
    final Color? backgroundColor = (backgroundColorHex != null && backgroundColorHex.isNotEmpty)
        ? ParsingUtil.parseColor(backgroundColorHex)
        : null;

    final String? foregroundColorHex = props['foregroundColor'] as String?;
    final Color? foregroundColor = (foregroundColorHex != null && foregroundColorHex.isNotEmpty)
        ? ParsingUtil.parseColor(foregroundColorHex)
        : null;

    final double? elevation = (props['elevation'] as num?)?.toDouble();

    final String? paddingString = props['padding'] as String?;
    final EdgeInsetsGeometry? padding = (paddingString != null && paddingString.isNotEmpty)
        ? ParsingUtil.parseEdgeInsets(paddingString)
        : null;

    Widget buttonChild;
    if (node.children.isNotEmpty) {
      buttonChild = renderChild(node.children.first);
    } else {
      buttonChild = Text(buttonText);
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      padding: padding,
    );

    final actualButton = ElevatedButton(
      onPressed: () {},
      style: buttonStyle,
      child: buttonChild,
    );

    return AbsorbPointer(
      absorbing: true,
      child: actualButton,
    );
  },
  category: ComponentCategory.input,
);