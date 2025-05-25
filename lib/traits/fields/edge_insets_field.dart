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

  bool _isAllMode = false;
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
    final normalized = edgeInsetsStr.toLowerCase().replaceAll(' ', '');
    bool newIsAllMode = false;

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
        newIsAllMode = true;
      } catch (_) {
        _clearAllControllersToZero();
        newIsAllMode = false;
      }
    } else {
      newIsAllMode = false;
      String toParse = normalized;
      if (normalized.startsWith('only:')) {
        toParse = normalized.substring(5);
      }

      final RegExp lReg = RegExp(r'l(-?[\d.]+)');
      final RegExp tReg = RegExp(r't(-?[\d.]+)');
      final RegExp rReg = RegExp(r'r(-?[\d.]+)');
      final RegExp bReg = RegExp(r'b(-?[\d.]+)');

      double l = double.tryParse(lReg.firstMatch(toParse)?.group(1) ?? '0') ?? 0;
      double t = double.tryParse(tReg.firstMatch(toParse)?.group(1) ?? '0') ?? 0;
      double r = double.tryParse(rReg.firstMatch(toParse)?.group(1) ?? '0') ?? 0;
      double b = double.tryParse(bReg.firstMatch(toParse)?.group(1) ?? '0') ?? 0;

      _updateControllerTextIfNeeded(_leftController, _formatDouble(l));
      _updateControllerTextIfNeeded(_topController, _formatDouble(t));
      _updateControllerTextIfNeeded(_rightController, _formatDouble(r));
      _updateControllerTextIfNeeded(_bottomController, _formatDouble(b));

      if (_formatDouble(l) == _formatDouble(t) &&
          _formatDouble(l) == _formatDouble(r) &&
          _formatDouble(l) == _formatDouble(b)) {
        _updateControllerTextIfNeeded(_allController, _formatDouble(l));
      } else {
        _updateControllerTextIfNeeded(_allController, '');
      }
    }

    if (_isAllMode != newIsAllMode) {
      if (mounted) {
        setState(() { _isAllMode = newIsAllMode; });
      } else {
        _isAllMode = newIsAllMode;
      }
    }
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

    if (!_isAllMode) {
      if (mounted) setState(() { _isAllMode = true; }); else _isAllMode = true;
    }

    final allValueText = _allController.text;
    _isProgrammaticUpdate = true;
    _updateControllerTextIfNeeded(_leftController, allValueText);
    _updateControllerTextIfNeeded(_topController, allValueText);
    _updateControllerTextIfNeeded(_rightController, allValueText);
    _updateControllerTextIfNeeded(_bottomController, allValueText);
    _isProgrammaticUpdate = false;

    _triggerOnChange();
  }

  void _onIndividualControllerTextChangedByUser() {
    if (_isProgrammaticUpdate) return;

    if (_isAllMode) {
      _isProgrammaticUpdate = true;
      _updateControllerTextIfNeeded(_allController, '');
      _isProgrammaticUpdate = false;
      if (mounted) {
        setState(() { _isAllMode = false; });
      } else {
        _isAllMode = false;
      }
    } else {
      _isProgrammaticUpdate = true;
      if (_leftController.text == _topController.text &&
          _leftController.text == _rightController.text &&
          _leftController.text == _bottomController.text) {
        _updateControllerTextIfNeeded(_allController, _leftController.text);
      } else {
        _updateControllerTextIfNeeded(_allController, '');
      }
      _isProgrammaticUpdate = false;
    }
    _triggerOnChange();
  }

  void _triggerOnChange() {
    if (_isProgrammaticUpdate || !mounted) return;

    String newValue;
    if (_isAllMode) {
      final allVal = double.tryParse(_allController.text) ?? 0;
      newValue = 'all:${_formatDouble(allVal)}';
    } else {
      final l = double.tryParse(_leftController.text) ?? 0;
      final t = double.tryParse(_topController.text) ?? 0;
      final r = double.tryParse(_rightController.text) ?? 0;
      final b = double.tryParse(_bottomController.text) ?? 0;
      newValue = 'only:L${_formatDouble(l)}T${_formatDouble(t)}R${_formatDouble(r)}B${_formatDouble(b)}';
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
          decoration: InputDecoration(labelText: label, isDense: true, border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0)),
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          onTap: () { if (controller.text.isNotEmpty) { controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length); } },
        ),
      ),
    );
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
                Expanded(child: Text(widget.label, style: Theme.of(context).textTheme.labelLarge)),
                const SizedBox(width: 8),
                Text("All:", style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 4),
                SizedBox(
                  width: 70,
                  child: TextFormField(
                    controller: _allController,
                    decoration: InputDecoration(isDense: true, border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0)),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    onTap: () {
                      if (!_isAllMode) {
                        _isProgrammaticUpdate = true;
                        if (_leftController.text == _topController.text &&
                            _leftController.text == _rightController.text &&
                            _leftController.text == _bottomController.text &&
                            _leftController.text.isNotEmpty) {
                          _updateControllerTextIfNeeded(_allController, _leftController.text);
                        } else {
                          _updateControllerTextIfNeeded(_allController, '');
                        }
                        _isProgrammaticUpdate = false;

                        if (mounted) {
                          setState(() { _isAllMode = true; });
                        } else {
                          _isAllMode = true;
                        }
                      }
                      if (_allController.text.isNotEmpty) {
                        _allController.selection = TextSelection(baseOffset: 0, extentOffset: _allController.text.length);
                      } else {
                        _allController.selection = TextSelection.fromPosition(const TextPosition(offset: 0));
                      }
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