import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerField extends StatelessWidget {
  final String label;
  final String value;
  final void Function(String) onChanged;

  const ColorPickerField({super.key, required this.label, required this.value, required this.onChanged});

  Color _parseHexToColor(String? hex, Color defaultColor) {
    if (hex == null || hex.isEmpty) return defaultColor;
    final String cleanHex = hex.replaceFirst('#', '');

    try {
      if (cleanHex.length == 8) {
        return Color(int.parse(cleanHex, radix: 16));
      } else if (cleanHex.length == 6) {
        return Color(int.parse('FF$cleanHex', radix: 16));
      }
      print('Warning: Invalid hex color string length for "$hex" (cleaned: "$cleanHex"). Falling back to default color.');
    } on FormatException catch (e) {
      print('Warning: Malformed hex color string "$hex" (cleaned: "$cleanHex"): $e. Falling back to default color.');
    } catch (e) {
      print('Error parsing hex color string "$hex": $e. Falling back to default color.');
    }
    return defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    final bool isValueSet = value.isNotEmpty;
    final ThemeData theme = Theme.of(context);

    Color swatchDisplayColor;
    if (isValueSet) {
      swatchDisplayColor = _parseHexToColor(value, theme.disabledColor);
    } else {
      if (label.toLowerCase().contains('background')) {
        swatchDisplayColor = theme.colorScheme.primary.withOpacity(0.6);
      } else if (label.toLowerCase().contains('foreground') || label.toLowerCase().contains('text')) {
        swatchDisplayColor = theme.colorScheme.onPrimary.withOpacity(0.6);
      } else {
        swatchDisplayColor = Colors.grey.shade400;
      }
    }

    return ListTile(
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: swatchDisplayColor,
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: !isValueSet ? Icon(Icons.grid_on, size: 18,
              color: theme.disabledColor.withOpacity(0.5),) : null,
          ),
        ],
      ),
      onTap: () {
        Color pickerInitialColor;
        if (isValueSet) {
          pickerInitialColor = _parseHexToColor(value, theme.colorScheme.primary);
        } else {
          if (label.toLowerCase().contains('background')) {
            pickerInitialColor = theme.colorScheme.primary;
          } else if (label.toLowerCase().contains('foreground') || label.toLowerCase().contains('text')) {
            pickerInitialColor = theme.colorScheme.onPrimary;
          } else {
            pickerInitialColor = Colors.white;
          }
        }

        Color tempPickedColor = pickerInitialColor;

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Pick $label"),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: tempPickedColor,
                  onColorChanged: (color) {
                    tempPickedColor = color;
                  },
                  enableAlpha: true,
                  pickerAreaHeightPercent: 0.8,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    final newHex = '#${tempPickedColor.value.toRadixString(16).padLeft(8, '0')}';
                    onChanged(newHex);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}