import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/component_registry.dart';
import '../../core/widget_node.dart';
import '../utils/component_util.dart';

final RegisteredComponent containerComponentDefinition = RegisteredComponent(
  type: 'Container',
  displayName: 'Container',
  icon: Icons.crop_square,
  defaultProps: {
    'width': 200.0,
    'height': 100.0,
    'backgroundColor': '',
    'alignment': 'center',
    'padding': 'all:0',
    'margin': 'all:0',
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
    PropField(name: 'width', label: 'Width', fieldType: FieldType.number, defaultValue: null),
    PropField(name: 'height', label: 'Height', fieldType: FieldType.number, defaultValue: null),
    PropField(name: 'backgroundColor', label: 'Background Color', fieldType: FieldType.color, defaultValue: null),
    PropField(
      name: 'alignment',
      label: 'Alignment (Child)',
      fieldType: FieldType.select,
      defaultValue: 'topLeft',
      options: [
        {'id': 'topLeft', 'name': 'Top Left'},
        {'id': 'topCenter', 'name': 'Top Center'},
        {'id': 'topRight', 'name': 'Top Right'},
        {'id': 'centerLeft', 'name': 'Center Left'},
        {'id': 'center', 'name': 'Center'},
        {'id': 'centerRight', 'name': 'Center Right'},
        {'id': 'bottomLeft', 'name': 'Bottom Left'},
        {'id': 'bottomCenter', 'name': 'Bottom Center'},
        {'id': 'bottomRight', 'name': 'Bottom Right'},
      ],
    ),
    PropField(name: 'padding', label: 'Padding', fieldType: FieldType.edgeInsets, defaultValue: 'all:0'),
    PropField(name: 'margin', label: 'Margin', fieldType: FieldType.edgeInsets, defaultValue: 'all:0'),
    PropField(
      name: 'borderRadius',
      label: 'Border Radius (All Corners)',
      fieldType: FieldType.number,
      defaultValue: 0.0,
    ),
    PropField(
      name: 'borderWidth',
      label: 'Border Width (All Sides)',
      fieldType: FieldType.number,
      defaultValue: 0.0,
    ),
    PropField(
      name: 'borderColor',
      label: 'Border Color',
      fieldType: FieldType.color,
      defaultValue: '#000000',
    ),
    PropField(name: 'shadowColor', label: 'Shadow Color', fieldType: FieldType.color, defaultValue: null),
    PropField(name: 'shadowOffsetX', label: 'Shadow Offset X', fieldType: FieldType.number, defaultValue: 0.0),
    PropField(name: 'shadowOffsetY', label: 'Shadow Offset Y', fieldType: FieldType.number, defaultValue: 2.0),
    PropField(name: 'shadowBlurRadius', label: 'Shadow Blur Radius', fieldType: FieldType.number, defaultValue: 4.0),
    PropField(name: 'shadowSpreadRadius', label: 'Shadow Spread Radius', fieldType: FieldType.number, defaultValue: 0.0),
    PropField(
      name: 'gradientType',
      label: 'Gradient Type',
      fieldType: FieldType.select,
      defaultValue: 'none',
      options: [
        {'id': 'none', 'name': 'None'},
        {'id': 'linear', 'name': 'Linear'},
      ],
    ),
    PropField(name: 'gradientColor1', label: 'Gradient Color 1', fieldType: FieldType.color, defaultValue: '#FFFFFFFF'),
    PropField(name: 'gradientColor2', label: 'Gradient Color 2', fieldType: FieldType.color, defaultValue: '#FF000000'),
    PropField(
        name: 'gradientBeginAlignment',
        label: 'Gradient Begin Align',
        fieldType: FieldType.select,
        defaultValue: 'topLeft',
        options: [
          {'id': 'topLeft', 'name': 'Top Left'}, {'id': 'topCenter', 'name': 'Top Center'}, {'id': 'topRight', 'name': 'Top Right'},
          {'id': 'centerLeft', 'name': 'Center Left'}, {'id': 'center', 'name': 'Center'}, {'id': 'centerRight', 'name': 'Center Right'},
          {'id': 'bottomLeft', 'name': 'Bottom Left'}, {'id': 'bottomCenter', 'name': 'Bottom Center'}, {'id': 'bottomRight', 'name': 'Bottom Right'},
        ]
    ),
    PropField(
        name: 'gradientEndAlignment',
        label: 'Gradient End Align',
        fieldType: FieldType.select,
        defaultValue: 'bottomRight',
        options: [
          {'id': 'topLeft', 'name': 'Top Left'}, {'id': 'topCenter', 'name': 'Top Center'}, {'id': 'topRight', 'name': 'Top Right'},
          {'id': 'centerLeft', 'name': 'Center Left'}, {'id': 'center', 'name': 'Center'}, {'id': 'centerRight', 'name': 'Center Right'},
          {'id': 'bottomLeft', 'name': 'Bottom Left'}, {'id': 'bottomCenter', 'name': 'Bottom Center'}, {'id': 'bottomRight', 'name': 'Bottom Right'},
        ]
    ),
  ],
  childPolicy: ChildAcceptancePolicy.single,
  builder: (WidgetNode node, WidgetRef ref, Widget Function(WidgetNode childNode) renderChild) {
    final props = node.props;

    final double? width = (props['width'] as num?)?.toDouble();
    final double? height = (props['height'] as num?)?.toDouble();

    final String? backgroundColorString = props['backgroundColor'] as String?;
    Color? bgColor = (backgroundColorString != null && backgroundColorString.isNotEmpty)
        ? ComponentUtil.parseColor(backgroundColorString)
        : null;

    final AlignmentGeometry? alignment = (props['alignment'] != null)
        ? ComponentUtil.parseAlignment(props['alignment']?.toString())
        : null;

    final EdgeInsetsGeometry padding = ComponentUtil.parseEdgeInsets(props['padding']?.toString());
    final EdgeInsetsGeometry margin = ComponentUtil.parseEdgeInsets(props['margin']?.toString());

    final double borderRadiusValue = (props['borderRadius'] as num?)?.toDouble() ?? 0.0;
    final double borderWidthValue = (props['borderWidth'] as num?)?.toDouble() ?? 0.0;
    final String? borderColorString = props['borderColor'] as String?;

    Color? borderColorVal;
    if (borderWidthValue > 0 && borderColorString != null && borderColorString.isNotEmpty) {
      borderColorVal = ComponentUtil.parseColor(borderColorString);
    } else if (borderWidthValue > 0) {
      borderColorVal = ComponentUtil.parseColor('#000000');
    }

    final String? shadowColorString = props['shadowColor'] as String?;
    final Color? shadowColorVal = (shadowColorString != null && shadowColorString.isNotEmpty)
        ? ComponentUtil.parseColor(shadowColorString)
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

      final Color color1 = ComponentUtil.parseColor(color1String);
      final Color color2 = ComponentUtil.parseColor(color2String);

      if ((color1String != null && color1String.isNotEmpty) || (color2String != null && color2String.isNotEmpty)){
        gradient = LinearGradient(
          colors: [color1, color2],
          begin: ComponentUtil.parseAlignment(props['gradientBeginAlignment'] as String?),
          end: ComponentUtil.parseAlignment(props['gradientEndAlignment'] as String?),
        );
      }
    }

    if (gradient != null) {
      bgColor = null;
    }

    BoxDecoration? decoration;
    bool hasDecoration = bgColor != null ||
        borderRadiusValue > 0 ||
        borderWidthValue > 0 ||
        boxShadows != null ||
        gradient != null;

    if (hasDecoration) {
      decoration = BoxDecoration(
        color: bgColor,
        gradient: gradient,
        borderRadius: borderRadiusValue > 0 ? BorderRadius.circular(borderRadiusValue) : null,
        border: borderWidthValue > 0
            ? Border.all(
          color: borderColorVal ?? Colors.black,
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
);