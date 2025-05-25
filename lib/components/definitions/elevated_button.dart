import 'package:flutter/material.dart';
import 'package:flutter_editor/components/utils/component_util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/component_registry.dart';
import '../../core/widget_node.dart';

final RegisteredComponent elevatedButtonComponentDefinition = RegisteredComponent(
  type: 'ElevatedButton',
  displayName: 'Button',
  icon: Icons.smart_button_outlined,
  defaultProps: {
    'buttonText': 'Click Me',
    'backgroundColor': '',
    'foregroundColor': '',
    'elevation': '2.0',
    'padding': 'symmetric:H16,V8',
  },
  propFields: [
    PropField(name: 'buttonText', label: 'Text', fieldType: FieldType.string, defaultValue: 'Click Me'),
    PropField(name: 'backgroundColor', label: 'Background Color', fieldType: FieldType.color, defaultValue: ''),
    PropField(name: 'foregroundColor', label: 'Foreground Color', fieldType: FieldType.color, defaultValue: ''),
    PropField(name: 'elevation', label: 'Elevation', fieldType: FieldType.number, defaultValue: '2.0'),
    PropField(name: 'padding', label: 'Padding (e.g., all:8)', fieldType: FieldType.edgeInsets, defaultValue: 'symmetric:H16,V8'),
  ],
  childPolicy: ChildAcceptancePolicy.single,
  builder: (
      WidgetNode node,
      WidgetRef ref,
      Widget Function(WidgetNode childNode) renderChild,
      ) {
    final props = node.props;
    final buttonText = props['buttonText']?.toString() ?? 'Button';

    final String? backgroundColorHex = props['backgroundColor']?.toString();
    final Color? backgroundColor = (backgroundColorHex != null && backgroundColorHex.isNotEmpty)
        ? ComponentUtil.parseColor(backgroundColorHex) // _parseButtonColor should be your robust global parser
        : null;

    final String? foregroundColorHex = props['foregroundColor']?.toString();
    final Color? foregroundColor = (foregroundColorHex != null && foregroundColorHex.isNotEmpty)
        ? ComponentUtil.parseColor(foregroundColorHex)
        : null;

    final double? elevation = double.tryParse(props['elevation']?.toString() ?? '');

    final String? paddingString = props['padding']?.toString();
    final EdgeInsetsGeometry? padding = (paddingString != null && paddingString.isNotEmpty)
        ? ComponentUtil.parseEdgeInsets(paddingString)
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
);