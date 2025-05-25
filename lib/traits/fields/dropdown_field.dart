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
      items: options.map((opt) => DropdownMenuItem(value: opt['id'], child: Text(opt['name'] ?? ''))).toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}