import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberInputField extends StatefulWidget {
  final String label;
  final num? value;
  final void Function(num?) onCommit;
  final void Function(num?)? onUpdate;
  final bool allowDecimal;

  const NumberInputField({
    super.key,
    required this.label,
    this.value,
    required this.onCommit,
    this.onUpdate,
    this.allowDecimal = true,
  });

  @override
  State<NumberInputField> createState() => _NumberInputFieldState();
}

class _NumberInputFieldState extends State<NumberInputField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toString() ?? '');
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NumberInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final String newText = widget.value?.toString() ?? '';
      if (newText != _controller.text) {
        _controller.text = newText;
      }
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _commitChange();
    }
  }

  void _commitChange() {
    final num? newValue = num.tryParse(_controller.text);
    widget.onCommit(newValue);
  }

  void _handleUpdate(String text) {
    if (widget.onUpdate != null) {
      final num? newValue = num.tryParse(text);
      widget.onUpdate!(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: widget.allowDecimal),
          inputFormatters: <TextInputFormatter>[
            if (widget.allowDecimal)
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
            else
              FilteringTextInputFormatter.digitsOnly
          ],
          onChanged: _handleUpdate,
          onFieldSubmitted: (_) => _commitChange(),
        ),
      ],
    );
  }
}
