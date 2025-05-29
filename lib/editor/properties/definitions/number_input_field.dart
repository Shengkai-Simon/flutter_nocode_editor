import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberInputField extends StatefulWidget {
  final String label;
  final String value;
  final void Function(String) onChanged;

  const NumberInputField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<NumberInputField> createState() => _NumberInputFieldState();
}

class _NumberInputFieldState extends State<NumberInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(NumberInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
          errorMaxLines: 2,
        ),
        onChanged: widget.onChanged,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null || value.isEmpty) return null;
          final double? numValue = double.tryParse(value);
          if (numValue == null) return 'Invalid number format (e.g., 12.34)';
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}