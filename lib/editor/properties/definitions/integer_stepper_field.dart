import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntegerStepperField extends StatefulWidget {
  final String label;
  final int? value;
  final void Function(int? newValue) onCommit;
  final void Function(int? newValue)? onUpdate;
  final int? minValue;
  final int? maxValue;
  final int step;

  const IntegerStepperField({
    super.key,
    required this.label,
    this.value,
    required this.onCommit,
    this.onUpdate,
    this.minValue,
    this.maxValue,
    this.step = 1,
  });

  @override
  State<IntegerStepperField> createState() => _IntegerStepperFieldState();
}

class _IntegerStepperFieldState extends State<IntegerStepperField> {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  int? _currentValue;
  int? _lastCommittedValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _lastCommittedValue = widget.value;
    _textController = TextEditingController(text: _currentValue?.toString() ?? '');
    _focusNode = FocusNode();

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(IntegerStepperField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the parent widget rebuilds (e.g., due to undo/redo),
    // update the controller's text if it doesn't match the current value.
    if (widget.value != oldWidget.value && widget.value != _currentValue) {
      _updateValue(widget.value, fromUserInput: false);
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _commitChange();
    }
  }

  void _commitChange() {
    final int? parsedValue = _textController.text.isEmpty ? null : int.tryParse(_textController.text);
    final validatedValue = _validateValue(parsedValue);

    // If the value hasn't changed, we might still need to update the text field
    // to its canonical representation (e.g., user input "05" should be "5").
    if (validatedValue == _lastCommittedValue) {
      _updateTextField(validatedValue);
      return;
    }

    _lastCommittedValue = validatedValue;
    widget.onCommit(validatedValue);
    _updateTextField(validatedValue);
  }

  int? _validateValue(int? value) {
    if (value == null) return null;
    int validated = value;
    if (widget.minValue != null && validated < widget.minValue!) {
      validated = widget.minValue!;
    }
    if (widget.maxValue != null && validated > widget.maxValue!) {
      validated = widget.maxValue!;
    }
    return validated;
  }

  void _updateTextField(int? value) {
    final textValue = value?.toString() ?? '';
    if (_textController.text != textValue) {
      _textController.text = textValue;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    }
  }

  void _updateValue(int? newValue, {bool fromUserInput = true}) {
    int? validatedValue = _validateValue(newValue);

    if (_currentValue == validatedValue) return;

    setState(() {
      _currentValue = validatedValue;
      if (!fromUserInput) {
        _updateTextField(_currentValue);
      }
    });

    if (fromUserInput) {
      widget.onUpdate?.call(_currentValue);
    }
  }

  void _handleTextUpdate(String text) {
    if (text.isEmpty) {
      _updateValue(null);
    } else {
      final int? parsedValue = int.tryParse(text);
      if (parsedValue != null) {
        _updateValue(parsedValue);
      }
    }
  }

  void _increment() {
    int currentValueForIncrement = _currentValue ?? (widget.minValue ?? 0) - widget.step;
    int newValue = currentValueForIncrement + widget.step;
    _updateValue(newValue);
    _updateTextField(_currentValue);
    _commitChange();
  }

  void _decrement() {
    int currentValueForDecrement = _currentValue ?? (widget.minValue ?? widget.step);
    if (widget.minValue != null && _currentValue == null) {
      currentValueForDecrement = widget.minValue! + widget.step;
    }
    int newValue = currentValueForDecrement - widget.step;
    _updateValue(newValue);
    _updateTextField(_currentValue);
    _commitChange();
  }

  @override
  Widget build(BuildContext context) {
    final bool canDecrement = _currentValue == null || (widget.minValue == null || _currentValue! > widget.minValue!);
    final bool canIncrement = _currentValue == null || (widget.maxValue == null || _currentValue! < widget.maxValue!);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                iconSize: 20,
                onPressed: canDecrement ? _decrement : null,
                tooltip: 'Decrement',
              ),
              Expanded(
                child: TextFormField(
                  controller: _textController,
                  focusNode: _focusNode,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  onChanged: _handleTextUpdate,
                  onFieldSubmitted: (_) => _commitChange(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 20,
                onPressed: canIncrement ? _increment : null,
                tooltip: 'Increment',
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }
}