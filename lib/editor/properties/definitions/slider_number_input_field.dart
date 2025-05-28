import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class SliderNumberInputField extends StatefulWidget {
  final String label;
  final double value;
  final void Function(double) onChanged;
  final double minValue;
  final double maxValue;
  final int? divisions;
  final int decimalPlaces;

  const SliderNumberInputField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
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
  late double _currentValue;

  bool _isUpdatingTextInternally = false;

  @override
  void initState() {
    super.initState();
    _currentValue = _roundToDecimalPlaces(widget.value.clamp(widget.minValue, widget.maxValue), widget.decimalPlaces);
    _textController = TextEditingController(text: _currentValue.toStringAsFixed(widget.decimalPlaces));
  }

  double _roundToDecimalPlaces(double value, int places) {
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  void _updateValue(double newValue, {bool fromSlider = false, bool fromTextField = false}) {
    final double roundedValue = _roundToDecimalPlaces(newValue.clamp(widget.minValue, widget.maxValue), widget.decimalPlaces);

    if (_currentValue == roundedValue && !fromTextField) {
      if (fromTextField && _textController.text != roundedValue.toStringAsFixed(widget.decimalPlaces)) {
        _isUpdatingTextInternally = true;
        _textController.text = roundedValue.toStringAsFixed(widget.decimalPlaces);
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length),
        );
        _isUpdatingTextInternally = false;
      }
      return;
    }


    setState(() {
      _currentValue = roundedValue;
      if (!fromTextField || _textController.text != roundedValue.toStringAsFixed(widget.decimalPlaces)) {
        _isUpdatingTextInternally = true;
        _textController.text = roundedValue.toStringAsFixed(widget.decimalPlaces);
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length),
        );
        _isUpdatingTextInternally = false;
      }
    });
    widget.onChanged(roundedValue);
  }


  @override
  void didUpdateWidget(SliderNumberInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && _roundToDecimalPlaces(widget.value, widget.decimalPlaces) != _currentValue) {
      _updateValue(widget.value);
    } else if (widget.decimalPlaces != oldWidget.decimalPlaces) {
      _updateValue(_currentValue);
    }
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
                  onChanged: (newValue) {
                    _updateValue(newValue, fromSlider: true);
                  },
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 70 + (widget.decimalPlaces * 5.0),
                child: Focus(
                  onFocusChange: (hasFocus) {
                    if (!hasFocus && !_isUpdatingTextInternally) {
                      final double? parsedValue = double.tryParse(_textController.text);
                      _updateValue(parsedValue ?? _currentValue, fromTextField: true);
                    }
                  },
                  child: TextFormField(
                    controller: _textController,
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
                    onFieldSubmitted: (textValue) {
                      if (_isUpdatingTextInternally) return;
                      final double? parsedValue = double.tryParse(textValue);
                      _updateValue(parsedValue ?? _currentValue, fromTextField: true);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}