import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EdgeInsetsField extends StatefulWidget {
  final String label;
  final String value;
  final void Function(String) onCommit;
  final void Function(String)? onUpdate;

  const EdgeInsetsField({
    super.key,
    required this.label,
    required this.value,
    required this.onCommit,
    this.onUpdate,
  });

  @override
  State<EdgeInsetsField> createState() => _EdgeInsetsFieldState();
}

class _EdgeInsetsFieldState extends State<EdgeInsetsField> {
  late final TextEditingController _leftController;
  late final TextEditingController _topController;
  late final TextEditingController _rightController;
  late final TextEditingController _bottomController;
  late final TextEditingController _allController;

  late final FocusNode _leftFocus;
  late final FocusNode _topFocus;
  late final FocusNode _rightFocus;
  late final FocusNode _bottomFocus;
  late final FocusNode _allFocus;

  bool _isProgrammaticUpdate = false;
  late String _lastCommittedValue;

  @override
  void initState() {
    super.initState();
    _leftController = TextEditingController();
    _topController = TextEditingController();
    _rightController = TextEditingController();
    _bottomController = TextEditingController();
    _allController = TextEditingController();

    _leftFocus = FocusNode();
    _topFocus = FocusNode();
    _rightFocus = FocusNode();
    _bottomFocus = FocusNode();
    _allFocus = FocusNode();

    _lastCommittedValue = widget.value;
    _parseValueAndSetControllers(widget.value);

    // Add listeners to commit changes when focus is lost
    _leftFocus.addListener(() => _handleFocusChange(_leftFocus));
    _topFocus.addListener(() => _handleFocusChange(_topFocus));
    _rightFocus.addListener(() => _handleFocusChange(_rightFocus));
    _bottomFocus.addListener(() => _handleFocusChange(_bottomFocus));
    _allFocus.addListener(() => _handleFocusChange(_allFocus));
  }

  @override
  void didUpdateWidget(covariant EdgeInsetsField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      // When the parent widget rebuilds (e.g., due to undo/redo or live updates),
      // update the controllers without triggering a new history record.
      _parseValueAndSetControllers(widget.value);
    }
  }

  @override
  void dispose() {
    _leftController.dispose();
    _topController.dispose();
    _rightController.dispose();
    _bottomController.dispose();
    _allController.dispose();

    _leftFocus.dispose();
    _topFocus.dispose();
    _rightFocus.dispose();
    _bottomFocus.dispose();
    _allFocus.dispose();
    super.dispose();
  }

  void _handleFocusChange(FocusNode focusNode) {
    if (!focusNode.hasFocus) {
      _commitChange();
    }
  }

  String _getCurrentValueAsString() {
    final lVal = double.tryParse(_leftController.text) ?? 0;
    final tVal = double.tryParse(_topController.text) ?? 0;
    final rVal = double.tryParse(_rightController.text) ?? 0;
    final bVal = double.tryParse(_bottomController.text) ?? 0;

    final bool areAllEqual = (lVal == tVal && lVal == rVal && lVal == bVal);

    if (areAllEqual) {
      return 'all:${_formatDouble(lVal)}';
    } else {
      return 'only:L${_formatDouble(lVal)}T${_formatDouble(tVal)}R${_formatDouble(rVal)}B${_formatDouble(bVal)}';
    }
  }

  void _handleUpdate() {
    if (_isProgrammaticUpdate) return;
    widget.onUpdate?.call(_getCurrentValueAsString());
  }

  /// Commits the current state of the text fields to the parent widget,
  /// which in turn records a single history entry.
  void _commitChange() {
    if (_isProgrammaticUpdate || !mounted) return;

    final newValue = _getCurrentValueAsString();

    if (newValue == _lastCommittedValue) return;

    // Only call onCommit when the final value is submitted.
    _lastCommittedValue = newValue;
    widget.onCommit(newValue);
  }

  /// Updates the internal state of the L/T/R/B fields based on the "All" field.
  /// This does NOT record history.
  void _syncIndividualFieldsFromAll(String allText) {
    if (_isProgrammaticUpdate) return;
    if (allText == '--' || _validateNumericInput(allText, isAllField: true) != null) return;

    final double valDouble = (allText.isEmpty) ? 0 : double.tryParse(allText) ?? 0;
    final String valueToSet = _formatDouble(valDouble);

    _isProgrammaticUpdate = true;
    _updateControllerTextIfNeeded(_leftController, valueToSet);
    _updateControllerTextIfNeeded(_topController, valueToSet);
    _updateControllerTextIfNeeded(_rightController, valueToSet);
    _updateControllerTextIfNeeded(_bottomController, valueToSet);
    _isProgrammaticUpdate = false;

    _handleUpdate();
  }

  /// Updates the internal state of the "All" field based on the L/T/R/B fields.
  /// This does NOT record history.
  void _syncAllFieldFromIndividuals() {
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
      _handleUpdate();
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
    _handleUpdate();
  }

  // --- Helper Methods ---

  void _parseValueAndSetControllers(String edgeInsetsStr) {
    _isProgrammaticUpdate = true;
    final normalized = edgeInsetsStr.toLowerCase().replaceAll(' ', '');

    if (normalized.startsWith('all:')) {
      final valStr = normalized.substring(4);
      final valDouble = double.tryParse(valStr) ?? 0;
      final formattedVal = _formatDouble(valDouble);
      _updateControllerTextIfNeeded(_allController, formattedVal);
      _updateControllerTextIfNeeded(_leftController, formattedVal);
      _updateControllerTextIfNeeded(_topController, formattedVal);
      _updateControllerTextIfNeeded(_rightController, formattedVal);
      _updateControllerTextIfNeeded(_bottomController, formattedVal);
    } else {
      String toParse = normalized.startsWith('only:') ? normalized.substring(5) : normalized;
      final l = double.tryParse(RegExp(r'l(-?[\d.]+)').firstMatch(toParse)?.group(1) ?? '0') ?? 0;
      final t = double.tryParse(RegExp(r't(-?[\d.]+)').firstMatch(toParse)?.group(1) ?? '0') ?? 0;
      final r = double.tryParse(RegExp(r'r(-?[\d.]+)').firstMatch(toParse)?.group(1) ?? '0') ?? 0;
      final b = double.tryParse(RegExp(r'b(-?[\d.]+)').firstMatch(toParse)?.group(1) ?? '0') ?? 0;

      _updateControllerTextIfNeeded(_leftController, _formatDouble(l));
      _updateControllerTextIfNeeded(_topController, _formatDouble(t));
      _updateControllerTextIfNeeded(_rightController, _formatDouble(r));
      _updateControllerTextIfNeeded(_bottomController, _formatDouble(b));

      if (l == t && l == r && l == b) {
        _updateControllerTextIfNeeded(_allController, _formatDouble(l));
      } else {
        _updateControllerTextIfNeeded(_allController, '--');
      }
    }
    _isProgrammaticUpdate = false;
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
    return val == val.truncateToDouble() ? val.truncate().toString() : val.toStringAsFixed(1);
  }

  String? _validateNumericInput(String? value, {bool isAllField = false}) {
    if (value == null || value.isEmpty || (isAllField && value == '--')) return null;
    return double.tryParse(value) == null ? 'Invalid' : null;
  }

  // --- Widget Build ---

  Widget _buildTextField(String label, TextEditingController controller, FocusNode focusNode, Function(String) onChanged) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          onFieldSubmitted: (_) => _commitChange(),
          decoration: InputDecoration(
            labelText: label,
            isDense: true,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            errorStyle: const TextStyle(fontSize: 9, height: 0.8),
            errorMaxLines: 1,
          ),
          textAlign: TextAlign.center,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) => _validateNumericInput(value),
          onTap: () => controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length),
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
                    focusNode: _allFocus,
                    onChanged: _syncIndividualFieldsFromAll,
                    onFieldSubmitted: (_) => _commitChange(),
                    decoration: InputDecoration(
                      isDense: true,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                      errorStyle: const TextStyle(fontSize: 9, height: 0.8),
                      errorMaxLines: 1,
                    ),
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => _validateNumericInput(value, isAllField: true),
                    onTap: () {
                      if (_allController.text == '--') _allController.clear();
                      _allController.selection = TextSelection(baseOffset: 0, extentOffset: _allController.text.length);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTextField("L", _leftController, _leftFocus, (_) => _syncAllFieldFromIndividuals()),
                _buildTextField("T", _topController, _topFocus, (_) => _syncAllFieldFromIndividuals()),
                _buildTextField("R", _rightController, _rightFocus, (_) => _syncAllFieldFromIndividuals()),
                _buildTextField("B", _bottomController, _bottomFocus, (_) => _syncAllFieldFromIndividuals()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
