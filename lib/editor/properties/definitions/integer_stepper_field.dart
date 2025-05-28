import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntegerStepperField extends StatefulWidget {
  final String label;
  final int? value;
  final void Function(int? newValue) onChanged;
  final int? minValue;
  final int? maxValue;
  final int step;

  const IntegerStepperField({
    super.key,
    required this.label,
    this.value,
    required this.onChanged,
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

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _textController = TextEditingController(text: _currentValue?.toString() ?? '');
    _focusNode = FocusNode();

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(IntegerStepperField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _currentValue) {
      _updateValue(widget.value, fromInput: false);
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _handleTextSubmit(_textController.text);
    }
  }

  void _updateValue(int? newValue, {bool fromInput = true}) {
    int? validatedValue = newValue;

    if (validatedValue != null) {
      if (widget.minValue != null && validatedValue < widget.minValue!) {
        validatedValue = widget.minValue;
      }
      if (widget.maxValue != null && validatedValue! > widget.maxValue!) {
        validatedValue = widget.maxValue;
      }
    }

    bool valueChanged = _currentValue != validatedValue;

    setState(() {
      _currentValue = validatedValue;
      if (fromInput || _textController.text != (_currentValue?.toString() ?? '')) {
        if (_textController.text != (_currentValue?.toString() ?? '')) {
          _textController.text = _currentValue?.toString() ?? '';
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: _textController.text.length),
          );
        }
      }
    });

    if (valueChanged) {
      widget.onChanged(_currentValue);
    } else if (fromInput && newValue != validatedValue) {
      widget.onChanged(validatedValue);
    }
  }

  void _handleTextSubmit(String text) {
    if (text.isEmpty) {
      _updateValue(null);
    } else {
      final int? parsedValue = int.tryParse(text);
      _updateValue(parsedValue);
    }
  }

  void _increment() {
    int currentValueForIncrement = _currentValue ?? (widget.minValue ?? 0) - widget.step;
    int newValue = currentValueForIncrement + widget.step;
    _updateValue(newValue);
  }

  void _decrement() {
    int currentValueForDecrement = _currentValue ?? (widget.minValue ?? widget.step) + widget.step;
    int newValue = currentValueForDecrement - widget.step;
    _updateValue(newValue);
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
                  onFieldSubmitted: _handleTextSubmit,
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