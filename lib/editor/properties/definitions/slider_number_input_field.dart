import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class SliderNumberInputField extends StatefulWidget {
  final String label;
  final double value;
  final void Function(double) onCommit;
  final void Function(double)? onUpdate;
  final double minValue;
  final double maxValue;
  final int? divisions;
  final int decimalPlaces;

  const SliderNumberInputField({
    super.key,
    required this.label,
    required this.value,
    required this.onCommit,
    this.onUpdate,
    required this.minValue,
    required this.maxValue,
    this.divisions,
    this.decimalPlaces = 2,
  });

  @override
  State<SliderNumberInputField> createState() => _SliderNumberInputFieldState();
}

class _SliderNumberInputFieldState extends State<SliderNumberInputField> {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  late double _currentValue;
  late double _lastCommittedValue;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _currentValue = _roundToDecimalPlaces(widget.value.clamp(widget.minValue, widget.maxValue), widget.decimalPlaces);
    _lastCommittedValue = _currentValue;
    _textController = TextEditingController(text: _currentValue.toStringAsFixed(widget.decimalPlaces));

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SliderNumberInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the value passed from the parent widget changes, update the local state.
    // This ensures the UI reflects the state after an undo/redo action or a live update from another source.
    final double roundedWidgetValue = _roundToDecimalPlaces(widget.value, widget.decimalPlaces);
    if (widget.value != oldWidget.value && roundedWidgetValue != _currentValue) {
      _updateValueFromWidget(widget.value);
    } else if (widget.decimalPlaces != oldWidget.decimalPlaces) {
      // Also update if formatting changes.
      _updateValueFromWidget(_currentValue);
    }
  }

  void _onFocusChange() {
    // When the text field loses focus, treat it as a final submission.
    if (!_focusNode.hasFocus) {
      _handleTextSubmit(_textController.text);
    }
  }

  double _roundToDecimalPlaces(double value, int places) {
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  /// Updates the internal state when the parent widget rebuilds with a new value.
  /// This does NOT call widget.onCommit, preventing history recording loops.
  void _updateValueFromWidget(double newValue) {
    final double roundedValue = _roundToDecimalPlaces(newValue.clamp(widget.minValue, widget.maxValue), widget.decimalPlaces);
    setState(() {
      _currentValue = roundedValue;
      final newText = roundedValue.toStringAsFixed(widget.decimalPlaces);
      if (_textController.text != newText) {
        _textController.text = newText;
      }
    });
  }

  /// Handles live updates from the Slider while the user is dragging.
  /// This only updates the local UI state and calls the onUpdate callback.
  void _handleSliderUpdate(double newValue) {
    final double roundedValue = _roundToDecimalPlaces(newValue.clamp(widget.minValue, widget.maxValue), widget.decimalPlaces);
    if (_currentValue != roundedValue) {
      setState(() {
        _currentValue = roundedValue;
        _textController.text = roundedValue.toStringAsFixed(widget.decimalPlaces);
      });
      widget.onUpdate?.call(roundedValue);
    }
  }

  /// Handles live updates from the TextFormField while the user is typing.
  void _handleTextUpdate(String text) {
    final double? parsedValue = double.tryParse(text);
    if (parsedValue != null) {
      final clampedValue = parsedValue.clamp(widget.minValue, widget.maxValue);
      widget.onUpdate?.call(clampedValue);
    }
  }

  /// Handles the final value when a text field editing is complete (on submit or focus loss).
  /// This records a single history entry by calling onCommit.
  void _handleTextSubmit(String text) {
    final double? parsedValue = double.tryParse(text);
    final double clampedValue = (parsedValue ?? _currentValue).clamp(widget.minValue, widget.maxValue);
    final double roundedValue = _roundToDecimalPlaces(clampedValue, widget.decimalPlaces);

    setState(() {
      _currentValue = roundedValue;
      if (_textController.text != roundedValue.toStringAsFixed(widget.decimalPlaces)) {
        _textController.text = roundedValue.toStringAsFixed(widget.decimalPlaces);
      }
    });

    if (_lastCommittedValue == roundedValue) return;
    _lastCommittedValue = roundedValue;
    widget.onCommit(roundedValue); // Record history
  }

  /// Handles the final value when a slider drag interaction ends.
  /// This records a single history entry by calling onCommit.
  void _handleSliderChangeEnd(double finalValue) {
    final double roundedValue = _roundToDecimalPlaces(finalValue.clamp(widget.minValue, widget.maxValue), widget.decimalPlaces);

    setState(() {
      _currentValue = roundedValue;
      if (_textController.text != roundedValue.toStringAsFixed(widget.decimalPlaces)) {
        _textController.text = roundedValue.toStringAsFixed(widget.decimalPlaces);
      }
    });

    if (_lastCommittedValue == roundedValue) return;
    _lastCommittedValue = roundedValue;
    widget.onCommit(roundedValue); // Record history
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _currentValue,
                  min: widget.minValue,
                  max: widget.maxValue,
                  divisions: widget.divisions,
                  label: _currentValue.toStringAsFixed(widget.decimalPlaces),
                  onChanged: _handleSliderUpdate, // Live UI update
                  onChangeEnd: _handleSliderChangeEnd, // Record history on end
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 70 + (widget.decimalPlaces * 5.0),
                child: TextFormField(
                  controller: _textController,
                  focusNode: _focusNode,
                  onChanged: _handleTextUpdate,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  onFieldSubmitted: _handleTextSubmit, // Record history on submit
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
