import 'package:flutter/material.dart';

class DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<Map<String, String>> options;
  final void Function(String) onChanged;

  const DropdownField({super.key, required this.label, required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      // Set isExpanded to true. This allows the dropdown to fill the available
      // horizontal space. The selected item text will automatically be handled
      // to prevent overflow, typically by using an ellipsis.
      isExpanded: true,
      items: options.map((opt) {
        return DropdownMenuItem(
          value: opt['id'],
          // For the items in the dropdown menu, we also ensure long text
          // doesn't cause issues by using an ellipsis.
          child: Text(
            opt['name'] ?? '',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
