import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../utils/parsing_util.dart';

class ColorPickerField extends StatelessWidget {
  final String label;
  final String value;
  final void Function(String) onChanged;

  const ColorPickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isValueSet = value.isNotEmpty;
    final ThemeData theme = Theme.of(context);

    Color swatchDisplayColorIfInvalid = theme.disabledColor;
    if (label.toLowerCase().contains('background')) {
      swatchDisplayColorIfInvalid = theme.colorScheme.primary.withOpacity(0.3);
    } else if (label.toLowerCase().contains('foreground') ||
        label.toLowerCase().contains('text')) {
      swatchDisplayColorIfInvalid = theme.colorScheme.onPrimary.withOpacity(
        0.3,
      );
    }

    Color currentDisplayColor = ParsingUtil.parseColor(value, defaultColor: swatchDisplayColorIfInvalid);

    if (isValueSet && currentDisplayColor.alpha == 0) {
      currentDisplayColor = currentDisplayColor.withAlpha(50);
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
              color: currentDisplayColor,
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: !isValueSet ? Icon(Icons.palette_outlined, size: 18,
              color: theme.disabledColor.withOpacity(0.7),) : null,
          ),
          if (isValueSet)
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              tooltip: "Clear Color",
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                onChanged('');
              },
            ),
        ],
      ),
      onTap: () {
        Color pickerInitialColor = ParsingUtil.parseColor(
          value,
          defaultColor: Colors.white,
        );
        if (pickerInitialColor.alpha == 0 && isValueSet) {
          pickerInitialColor = pickerInitialColor.withAlpha(255);
        } else if (!isValueSet) {
          if (label.toLowerCase().contains('background')) {
            pickerInitialColor = theme.colorScheme.primary;
          } else if (label.toLowerCase().contains('foreground') ||
              label.toLowerCase().contains('text')) {
            pickerInitialColor =
                theme.textTheme.bodyLarge?.color ?? Colors.black;
          }
        }

        Color tempPickedColor = pickerInitialColor;

        showDialog(
          context: context,
          builder: (dialogContext) {
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
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    final newHex =
                        '#${tempPickedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
                    onChanged(newHex);
                    Navigator.of(dialogContext).pop();
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
