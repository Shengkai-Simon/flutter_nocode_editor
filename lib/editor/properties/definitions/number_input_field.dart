import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberInputField extends StatefulWidget {
  final String label;
  final String value;
  final void Function(String) onCommit;
  final void Function(String)? onUpdate;

  const NumberInputField({
    super.key,
    required this.label,
    required this.value,
    required this.onCommit,
    this.onUpdate,
  });

  @override
  State<NumberInputField> createState() => _NumberInputFieldState();
}

class _NumberInputFieldState extends State<NumberInputField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late String _lastCommittedValue;

  @override
  void initState() {
    super.initState();
    _lastCommittedValue = widget.value;
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NumberInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the parent widget rebuilds (e.g., due to undo/redo or live updates),
    // update the controller's text if it doesn't match the current value.
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  void _onFocusChange() {
    // Commit the change when the text field loses focus.
    if (!_focusNode.hasFocus) {
      _commitChange();
    }
  }

  void _commitChange() {
    if (_controller.text == _lastCommittedValue) return;
    // Only call the parent's onCommit when the editing is complete.
    _lastCommittedValue = _controller.text;
    widget.onCommit(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onUpdate,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
          errorMaxLines: 2,
        ),
        // The onChanged callback is now removed from here to prevent chatty history.
        onFieldSubmitted: (_) => _commitChange(),
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
}
