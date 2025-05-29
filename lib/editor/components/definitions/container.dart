import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/parsing_util.dart';
import '../../properties/core/property_editor_registry.dart';
import '../../properties/core/property_definition.dart';
import '../../properties/core/property_common_groups.dart';
import '../core/widget_node.dart';
import '../core/component_definition.dart';

final RegisteredComponent containerComponentDefinition = RegisteredComponent(
  type: 'Container',
  displayName: 'Container',
  icon: Icons.crop_square,
  defaultProps: {
    ...SizingProps.defaults,
    ...MarginProps.defaults,
    ...PaddingProps.defaults,
    ...ChildAlignmentProps.defaults,
    ...BackgroundColorProp.defaults,

    'alignment': 'topLeft',

    'borderRadius': 0.0,
    'borderWidth': 0.0,
    'borderColor': '#000000',

    'shadowColor': null,
    'shadowOffsetX': 0.0,
    'shadowOffsetY': 2.0,
    'shadowBlurRadius': 4.0,
    'shadowSpreadRadius': 0.0,

    'gradientType': 'none',
    'gradientColor1': '#FFFFFFFF',
    'gradientColor2': '#FF000000',
    'gradientBeginAlignment': 'topLeft',
    'gradientEndAlignment': 'bottomRight',
  },
  propFields: [
    ...SizingProps.fields,
    ...MarginProps.fields,
    ...PaddingProps.fields,
    ...ChildAlignmentProps.fields,
    ...BackgroundColorProp.fields,

    PropField(name: 'borderRadius', label: 'Border Radius', fieldType: FieldType.number, defaultValue: 0.0, editorBuilder: kDefaultNumberInputEditor, propertyCategory: PropertyCategory.border),
    PropField(name: 'borderWidth', label: 'Border Width', fieldType: FieldType.number, defaultValue: 0.0, editorBuilder: kDefaultNumberInputEditor, propertyCategory: PropertyCategory.border),
    PropField(name: 'borderColor', label: 'Border Color', fieldType: FieldType.color, defaultValue: '#000000', editorBuilder: kDefaultColorPickerEditor, propertyCategory: PropertyCategory.border),

    PropField(name: 'shadowColor', label: 'Shadow Color', fieldType: FieldType.color, defaultValue: null, editorBuilder: kDefaultColorPickerEditor, propertyCategory: PropertyCategory.shadow),
    PropField(
      name: 'shadowOffsetX',
      label: 'Shadow Offset X',
      fieldType: FieldType.number,
      defaultValue: 0.0,
      editorBuilder: kSliderNumberInputEditor,
      editorConfig: {'minValue': -20.0, 'maxValue': 20.0, 'divisions': 40, 'decimalPlaces': 1},
      propertyCategory: PropertyCategory.shadow,
    ),
    PropField(
      name: 'shadowOffsetY',
      label: 'Shadow Offset Y',
      fieldType: FieldType.number,
      defaultValue: 2.0,
      editorBuilder: kSliderNumberInputEditor,
      editorConfig: {'minValue': -20.0, 'maxValue': 20.0, 'divisions': 40, 'decimalPlaces': 1},
        propertyCategory: PropertyCategory.shadow,
    ),
    PropField(
      name: 'shadowBlurRadius',
      label: 'Shadow Blur Radius',
      fieldType: FieldType.number,
      defaultValue: 4.0,
      editorBuilder: kSliderNumberInputEditor,
      editorConfig: {'minValue': 0.0, 'maxValue': 50.0, 'divisions': 50, 'decimalPlaces': 1},
      propertyCategory: PropertyCategory.shadow,
    ),
    PropField(
      name: 'shadowSpreadRadius',
      label: 'Shadow Spread Radius',
      fieldType: FieldType.number,
      defaultValue: 0.0,
      editorBuilder: kSliderNumberInputEditor,
      editorConfig: {'minValue': -10.0, 'maxValue': 20.0, 'divisions': 30, 'decimalPlaces': 1},
      propertyCategory: PropertyCategory.shadow,
    ),
    PropField(
      name: 'gradientType',
      label: 'Gradient Type',
      fieldType: FieldType.select,
      defaultValue: 'none',
      options: [
        {'id': 'none', 'name': 'None'},
        {'id': 'linear', 'name': 'Linear'},
      ],
      editorBuilder: kDefaultDropdownEditor,
      propertyCategory: PropertyCategory.gradient,
    ),
    PropField(name: 'gradientColor1', label: 'Gradient Color 1', fieldType: FieldType.color, defaultValue: '#FFFFFFFF', editorBuilder: kDefaultColorPickerEditor, propertyCategory: PropertyCategory.gradient),
    PropField(name: 'gradientColor2', label: 'Gradient Color 2', fieldType: FieldType.color, defaultValue: '#FF000000', editorBuilder: kDefaultColorPickerEditor, propertyCategory: PropertyCategory.gradient),
    PropField(
      name: 'gradientBeginAlignment',
      label: 'Gradient Begin Align',
      fieldType: FieldType.select,
      defaultValue: 'topLeft',
      options: ChildAlignmentProps.fields.first.options,
      editorBuilder: kDefaultDropdownEditor,
      propertyCategory: PropertyCategory.gradient,
    ),
    PropField(
      name: 'gradientEndAlignment',
      label: 'Gradient End Align',
      fieldType: FieldType.select,
      defaultValue: 'bottomRight',
      options: ChildAlignmentProps.fields.first.options,
      editorBuilder: kDefaultDropdownEditor,
      propertyCategory: PropertyCategory.gradient,
    ),
  ],
  childPolicy: ChildAcceptancePolicy.single,
  builder: (WidgetNode node, WidgetRef ref, Widget Function(WidgetNode childNode) renderChild) {
    final props = node.props;

    final double? width = (props['width'] as num?)?.toDouble();
    final double? height = (props['height'] as num?)?.toDouble();
    final EdgeInsetsGeometry margin = ParsingUtil.parseEdgeInsets(props['margin']?.toString());
    final EdgeInsetsGeometry padding = ParsingUtil.parseEdgeInsets(props['padding']?.toString());

    final AlignmentGeometry alignment = ParsingUtil.parseAlignment(props['alignment']?.toString());

    String? backgroundColorString = props['backgroundColor'] as String?;
    Color? bgColor = (backgroundColorString != null && backgroundColorString.isNotEmpty)
        ? ParsingUtil.parseColor(backgroundColorString)
        : null;

    final double borderRadiusValue = (props['borderRadius'] as num?)?.toDouble() ?? 0.0;
    final double borderWidthValue = (props['borderWidth'] as num?)?.toDouble() ?? 0.0;
    final String? borderColorString = props['borderColor'] as String?;
    Color? borderColorVal;
    if (borderWidthValue > 0) {
      borderColorVal = ParsingUtil.parseColor(borderColorString,
          defaultColor: Colors.black);
    }

    final String? shadowColorString = props['shadowColor'] as String?;
    final Color? shadowColorVal = (shadowColorString != null && shadowColorString.isNotEmpty)
        ? ParsingUtil.parseColor(shadowColorString)
        : null;
    final double shadowOffsetXVal = (props['shadowOffsetX'] as num?)?.toDouble() ?? 0.0;
    final double shadowOffsetYVal = (props['shadowOffsetY'] as num?)?.toDouble() ?? 0.0;
    final double shadowBlurRadiusVal = (props['shadowBlurRadius'] as num?)?.toDouble() ?? 0.0;
    final double shadowSpreadRadiusVal = (props['shadowSpreadRadius'] as num?)?.toDouble() ?? 0.0;

    List<BoxShadow>? boxShadows;
    if (shadowColorVal != null && (shadowBlurRadiusVal > 0 || shadowSpreadRadiusVal > 0 || shadowOffsetXVal != 0 || shadowOffsetYVal != 0)) {
      boxShadows = [
        BoxShadow(
          color: shadowColorVal,
          offset: Offset(shadowOffsetXVal, shadowOffsetYVal),
          blurRadius: shadowBlurRadiusVal,
          spreadRadius: shadowSpreadRadiusVal,
        ),
      ];
    }

    final String gradientType = props['gradientType'] as String? ?? 'none';
    Gradient? gradient;

    if (gradientType == 'linear') {
      final String? color1String = props['gradientColor1'] as String?;
      final String? color2String = props['gradientColor2'] as String?;
      final Color color1 = ParsingUtil.parseColor(color1String, defaultColor: Colors.transparent);
      final Color color2 = ParsingUtil.parseColor(color2String, defaultColor: Colors.transparent);

      if ((color1String != null && color1String.isNotEmpty) || (color2String != null && color2String.isNotEmpty)){
        gradient = LinearGradient(
          colors: [color1, color2],
          begin: ParsingUtil.parseAlignment(props['gradientBeginAlignment'] as String?),
          end: ParsingUtil.parseAlignment(props['gradientEndAlignment'] as String?),
        );
      }
    }

    if (gradient != null) {
      bgColor = null;
    }

    BoxDecoration? decoration;
    bool hasDecoration = bgColor != null ||
        borderRadiusValue > 0 ||
        (borderWidthValue > 0 && borderColorVal != null) ||
        boxShadows != null ||
        gradient != null;

    if (hasDecoration) {
      decoration = BoxDecoration(
        color: bgColor,
        gradient: gradient,
        borderRadius: borderRadiusValue > 0 ? BorderRadius.circular(borderRadiusValue) : null,
        border: (borderWidthValue > 0 && borderColorVal != null)
            ? Border.all(
          color: borderColorVal,
          width: borderWidthValue,
        )
            : null,
        boxShadow: boxShadows,
      );
    }

    Widget? childWidgetInstance;
    if (node.children.isNotEmpty) {
      childWidgetInstance = renderChild(node.children.first);
    }

    return Container(
      width: width,
      height: height,
      decoration: decoration,
      alignment: alignment,
      padding: padding,
      margin: margin,
      child: childWidgetInstance,
    );
  },
    category: ComponentCategory.layout
);