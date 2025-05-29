import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EdgeInsetsField extends StatefulWidget {
  final String label;
  final String value;
  final void Function(String) onChanged;

  const EdgeInsetsField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<EdgeInsetsField> createState() => _EdgeInsetsFieldState();
}

class _EdgeInsetsFieldState extends State<EdgeInsetsField> {
  late TextEditingController _leftController;
  late TextEditingController _topController;
  late TextEditingController _rightController;
  late TextEditingController _bottomController;
  late TextEditingController _allController;

  bool _isProgrammaticUpdate = false;

  @override
  void initState() {
    super.initState();
    _leftController = TextEditingController();
    _topController = TextEditingController();
    _rightController = TextEditingController();
    _bottomController = TextEditingController();
    _allController = TextEditingController();

    _parseValueAndSetControllers(widget.value);

    _allController.addListener(_onAllControllerTextChangedByUser);
    _leftController.addListener(_onIndividualControllerTextChangedByUser);
    _topController.addListener(_onIndividualControllerTextChangedByUser);
    _rightController.addListener(_onIndividualControllerTextChangedByUser);
    _bottomController.addListener(_onIndividualControllerTextChangedByUser);
  }

  @override
  void didUpdateWidget(covariant EdgeInsetsField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _isProgrammaticUpdate = true;
      _parseValueAndSetControllers(widget.value);
      _isProgrammaticUpdate = false;
    }
  }

  void _updateControllerTextIfNeeded(TextEditingController controller, String newText) {
    if (controller.text != newText) {
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.fromPosition(TextPosition(offset: newText.length)),
      );
    }
  }

  String _formatDouble(double val) {
    if (val == val.truncateToDouble()) {
      return val.truncate().toString();
    }
    return val.toStringAsFixed(1);
  }

  void _parseValueAndSetControllers(String edgeInsetsStr) {
    _isProgrammaticUpdate = true;

    final normalized = edgeInsetsStr.toLowerCase().replaceAll(' ', '');

    if (normalized.startsWith('all:')) {
      try {
        final valStr = normalized.substring(4);
        final valDouble = double.tryParse(valStr) ?? 0;
        final formattedVal = _formatDouble(valDouble);

        _updateControllerTextIfNeeded(_allController, formattedVal);
        _updateControllerTextIfNeeded(_leftController, formattedVal);
        _updateControllerTextIfNeeded(_topController, formattedVal);
        _updateControllerTextIfNeeded(_rightController, formattedVal);
        _updateControllerTextIfNeeded(_bottomController, formattedVal);
      } catch (_) {
        _clearAllControllersToZero();
      }
    } else {
      String toParse = normalized;
      if (normalized.startsWith('only:')) {
        toParse = normalized.substring(5);
      }

      final RegExp lReg = RegExp(r'l(-?[\d.]+)');
      final RegExp tReg = RegExp(r't(-?[\d.]+)');
      final RegExp rReg = RegExp(r'r(-?[\d.]+)');
      final RegExp bReg = RegExp(r'b(-?[\d.]+)');

      double l = 0, t = 0, r = 0, b = 0;

      bool hasExplicitL = lReg.hasMatch(toParse);
      bool hasExplicitT = tReg.hasMatch(toParse);
      bool hasExplicitR = rReg.hasMatch(toParse);
      bool hasExplicitB = bReg.hasMatch(toParse);

      if (hasExplicitL || hasExplicitT || hasExplicitR || hasExplicitB) {
        l = double.tryParse(lReg.firstMatch(toParse)?.group(1) ?? '0') ?? 0;
        t = double.tryParse(tReg.firstMatch(toParse)?.group(1) ?? '0') ?? 0;
        r = double.tryParse(rReg.firstMatch(toParse)?.group(1) ?? '0') ?? 0;
        b = double.tryParse(bReg.firstMatch(toParse)?.group(1) ?? '0') ?? 0;
      } else {
        final parts = toParse.split(',');
        if (parts.length == 4) {
          l = double.tryParse(parts[0]) ?? 0;
          t = double.tryParse(parts[1]) ?? 0;
          r = double.tryParse(parts[2]) ?? 0;
          b = double.tryParse(parts[3]) ?? 0;
        } else if (parts.length == 1 && parts[0].isNotEmpty && double.tryParse(parts[0]) != null) {
          final singleVal = double.tryParse(parts[0])!;
          l = t = r = b = singleVal;
        } else {
          l = t = r = b = 0;
        }
      }

      final String lStr = _formatDouble(l);
      final String tStr = _formatDouble(t);
      final String rStr = _formatDouble(r);
      final String bStr = _formatDouble(b);

      _updateControllerTextIfNeeded(_leftController, lStr);
      _updateControllerTextIfNeeded(_topController, tStr);
      _updateControllerTextIfNeeded(_rightController, rStr);
      _updateControllerTextIfNeeded(_bottomController, bStr);

      if (lStr == tStr && lStr == rStr && lStr == bStr && double.tryParse(lStr) != null) {
        _updateControllerTextIfNeeded(_allController, lStr);
      } else {
        _updateControllerTextIfNeeded(_allController, '--');
      }
    }
    _isProgrammaticUpdate = false;
  }

  void _clearAllControllersToZero() {
    _updateControllerTextIfNeeded(_allController, "0");
    _updateControllerTextIfNeeded(_leftController, "0");
    _updateControllerTextIfNeeded(_topController, "0");
    _updateControllerTextIfNeeded(_rightController, "0");
    _updateControllerTextIfNeeded(_bottomController, "0");
  }

  void _onAllControllerTextChangedByUser() {
    if (_isProgrammaticUpdate) return;

    final String allText = _allController.text;

    if (allText == '--') {
      return;
    }

    if (_validateNumericInput(allText, isAllField: true) != null && allText.isNotEmpty) {
      return;
    }

    final double valDouble = (allText.isEmpty) ? 0 : double.tryParse(allText) ?? 0;
    final String valueToSet = _formatDouble(valDouble);

    _isProgrammaticUpdate = true;
    _updateControllerTextIfNeeded(_leftController, valueToSet);
    _updateControllerTextIfNeeded(_topController, valueToSet);
    _updateControllerTextIfNeeded(_rightController, valueToSet);
    _updateControllerTextIfNeeded(_bottomController, valueToSet);

    if (double.tryParse(allText) != null && _allController.text != valueToSet) {
      _updateControllerTextIfNeeded(_allController, valueToSet);
    }
    _isProgrammaticUpdate = false;

    _triggerOnChange();
  }

  void _onIndividualControllerTextChangedByUser() {
    if (_isProgrammaticUpdate) return;

    final String lText = _leftController.text;
    final String tText = _topController.text;
    final String rText = _rightController.text;
    final String bText = _bottomController.text;

    if (_validateNumericInput(lText) != null ||
        _validateNumericInput(tText) != null ||
        _validateNumericInput(rText) != null ||
        _validateNumericInput(bText) != null) {
      _isProgrammaticUpdate = true;
      _updateControllerTextIfNeeded(_allController, '--');
      _isProgrammaticUpdate = false;
      return;
    }

    final double lVal = double.tryParse(lText) ?? 0;
    final double tVal = double.tryParse(tText) ?? 0;
    final double rVal = double.tryParse(rText) ?? 0;
    final double bVal = double.tryParse(bText) ?? 0;

    _isProgrammaticUpdate = true;
    if (lVal == tVal && lVal == rVal && lVal == bVal) {
      _updateControllerTextIfNeeded(_allController, _formatDouble(lVal));
    } else {
      _updateControllerTextIfNeeded(_allController, '--');
    }
    _isProgrammaticUpdate = false;

    _triggerOnChange();
  }

  void _triggerOnChange() {
    if (_isProgrammaticUpdate || !mounted) return;

    String newValue;
    final String allText = _allController.text;

    final lVal = double.tryParse(_leftController.text) ?? 0;
    final tVal = double.tryParse(_topController.text) ?? 0;
    final rVal = double.tryParse(_rightController.text) ?? 0;
    final bVal = double.tryParse(_bottomController.text) ?? 0;

    final bool ltrbAreEqual = (lVal == tVal && lVal == rVal && lVal == bVal);

    final double? allValParsed = (allText.isNotEmpty && allText != '--')
        ? double.tryParse(allText)
        : null;

    if (allValParsed != null &&
        allValParsed == lVal &&
        allValParsed == tVal &&
        allValParsed == rVal &&
        allValParsed == bVal) {
      newValue = 'all:${_formatDouble(allValParsed)}';
    } else if (ltrbAreEqual) {
      newValue = 'all:${_formatDouble(lVal)}';
    } else {
      newValue = 'only:L${_formatDouble(lVal)}T${_formatDouble(tVal)}R${_formatDouble(rVal)}B${_formatDouble(bVal)}';
    }

    widget.onChanged(newValue);
  }

  @override
  void dispose() {
    _leftController.removeListener(_onIndividualControllerTextChangedByUser);
    _topController.removeListener(_onIndividualControllerTextChangedByUser);
    _rightController.removeListener(_onIndividualControllerTextChangedByUser);
    _bottomController.removeListener(_onIndividualControllerTextChangedByUser);
    _allController.removeListener(_onAllControllerTextChangedByUser);

    _leftController.dispose();
    _topController.dispose();
    _rightController.dispose();
    _bottomController.dispose();
    _allController.dispose();
    super.dispose();
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            isDense: true,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            errorStyle: const TextStyle(fontSize: 9, height: 0.8),
            errorMaxLines: 1,
          ),
          textAlign: TextAlign.center,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) => _validateNumericInput(value),
          onTap: () {
            if (controller.text.isNotEmpty) {
              controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
            }
          },
        ),
      ),
    );
  }

  String? _validateNumericInput(String? value, {bool isAllField = false}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (isAllField && value == '--') {
      return null;
    }
    if (double.tryParse(value) == null) {
      return 'Invalid';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.2,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: Text(widget.label, style: Theme
                    .of(context)
                    .textTheme
                    .labelLarge)),
                const SizedBox(width: 8),
                Text("All:", style: Theme
                    .of(context)
                    .textTheme
                    .bodyMedium),
                const SizedBox(width: 4),
                SizedBox(
                  width: 70,
                  child: TextFormField(
                    controller: _allController,
                    decoration: InputDecoration(
                      isDense: true,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 8.0),
                      errorStyle: const TextStyle(fontSize: 9, height: 0.8),
                      errorMaxLines: 1,
                    ),
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: false),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                    ],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) =>
                        _validateNumericInput(value, isAllField: true),
                    onTap: () {
                      _isProgrammaticUpdate =
                      true;
                      if (_allController.text == '--') {
                        _allController.text = '';
                      } else if (_allController.text.isNotEmpty) {
                        _allController.selection = TextSelection(
                            baseOffset: 0, extentOffset: _allController.text
                            .length);
                      }
                      _isProgrammaticUpdate = false;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTextField("L", _leftController),
                _buildTextField("T", _topController),
                _buildTextField("R", _rightController),
                _buildTextField("B", _bottomController),
              ],
            ),
          ],
        ),
      ),
    );
  }
}