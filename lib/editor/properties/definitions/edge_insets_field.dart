import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils/parsing_util.dart';

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

    // Add listeners for focus and text changes
    void setupControllerAndFocus({
      required TextEditingController controller,
      required FocusNode focusNode,
    }) {
      controller.addListener(_onIndividualFieldChanged);
      focusNode.addListener(() {
        if (!focusNode.hasFocus) {
          _onFocusLost();
        }
      });
    }
    setupControllerAndFocus(controller: _leftController, focusNode: _leftFocus);
    setupControllerAndFocus(controller: _topController, focusNode: _topFocus);
    setupControllerAndFocus(controller: _rightController, focusNode: _rightFocus);
    setupControllerAndFocus(controller: _bottomController, focusNode: _bottomFocus);

    _allController.addListener(_onAllFieldChanged);
    _allFocus.addListener(() {
      if (!_allFocus.hasFocus) {
        _onFocusLost();
      }
    });
  }

  @override
  void didUpdateWidget(EdgeInsetsField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _lastCommittedValue) {
      _lastCommittedValue = widget.value;
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

  void _parseValueAndSetControllers(String value) {
    _isProgrammaticUpdate = true;
    
    // *** REUSE a central parser ***
    final EdgeInsetsGeometry geometry = ParsingUtil.parseEdgeInsets(value);

    if (geometry is EdgeInsets) {
      final String left = _formatDouble(geometry.left);
      final String top = _formatDouble(geometry.top);
      final String right = _formatDouble(geometry.right);
      final String bottom = _formatDouble(geometry.bottom);

      _updateControllerTextIfNeeded(_leftController, left);
      _updateControllerTextIfNeeded(_topController, top);
      _updateControllerTextIfNeeded(_rightController, right);
      _updateControllerTextIfNeeded(_bottomController, bottom);
      
      if (geometry.left == geometry.top && geometry.left == geometry.right && geometry.left == geometry.bottom) {
           _updateControllerTextIfNeeded(_allController, left);
      } else {
           _updateControllerTextIfNeeded(_allController, '--');
      }
    } else {
      // Fallback for unknown geometry types or parsing errors.
      _updateControllerTextIfNeeded(_allController, '--');
      _updateControllerTextIfNeeded(_leftController, '');
      _updateControllerTextIfNeeded(_topController, '');
      _updateControllerTextIfNeeded(_rightController, '');
      _updateControllerTextIfNeeded(_bottomController, '');
    }
    
    _isProgrammaticUpdate = false;
  }

  void _onAllFieldChanged() {
    if (_isProgrammaticUpdate) return;
    if (_allController.text == '--') return;
    
    _isProgrammaticUpdate = true;
    final allValue = _allController.text;
    _updateControllerTextIfNeeded(_leftController, allValue);
    _updateControllerTextIfNeeded(_topController, allValue);
    _updateControllerTextIfNeeded(_rightController, allValue);
    _updateControllerTextIfNeeded(_bottomController, allValue);
    _isProgrammaticUpdate = false;
    _updateParentWidget();
  }

  void _onIndividualFieldChanged() {
    if (_isProgrammaticUpdate) return;
    
    _isProgrammaticUpdate = true;
    final left = _leftController.text;
    final top = _topController.text;
    final right = _rightController.text;
    final bottom = _bottomController.text;

    if (left == top && left == right && left == bottom && left.isNotEmpty) {
      _updateControllerTextIfNeeded(_allController, left);
    } else {
      _updateControllerTextIfNeeded(_allController, '--');
    }
    _isProgrammaticUpdate = false;

    _updateParentWidget();
  }

  void _updateParentWidget() {
    final String newValue = _buildCurrentStringValue();
    
    if (widget.onUpdate != null) {
      widget.onUpdate!(newValue);
    }
    _lastCommittedValue = newValue;
  }
  
  void _onFocusLost() {
    final finalValue = _buildCurrentStringValue();
    if(finalValue != widget.value) {
      widget.onCommit(finalValue);
    }
  }

  String _buildCurrentStringValue() {
    final left = _leftController.text;
    final top = _topController.text;
    final right = _rightController.text;
    final bottom = _bottomController.text;
    final all = _allController.text;

    if (all.isNotEmpty && all != '--') {
      final allParsed = double.tryParse(all) ?? 0;
      return 'all:${_formatDouble(allParsed)}';
    } 
    
    List<String> parts = [];
    final lNum = double.tryParse(left);
    final tNum = double.tryParse(top);
    final rNum = double.tryParse(right);
    final bNum = double.tryParse(bottom);

    if(lNum != null && lNum != 0) parts.add('L${_formatDouble(lNum)}');
    if(tNum != null && tNum != 0) parts.add('T${_formatDouble(tNum)}');
    if(rNum != null && rNum != 0) parts.add('R${_formatDouble(rNum)}');
    if(bNum != null && bNum != 0) parts.add('B${_formatDouble(bNum)}');
      
    if (parts.isEmpty) {
      return 'all:0';
    } else {
      return 'only:${parts.join(',')}';
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
    return val == val.truncateToDouble() ? val.truncate().toString() : val.toStringAsFixed(1);
  }

  String? _validateNumericInput(String? value, {bool isAllField = false}) {
    if (value == null || value.isEmpty || (isAllField && value == '--')) return null;
    return double.tryParse(value) == null ? 'Invalid' : null;
  }

  // --- Widget Build ---

  Widget _buildTextField(String label, TextEditingController controller, FocusNode focusNode) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          onChanged: (_) => _onIndividualFieldChanged(),
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
                    onChanged: (_) => _onAllFieldChanged(),
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
                _buildTextField("L", _leftController, _leftFocus),
                _buildTextField("T", _topController, _topFocus),
                _buildTextField("R", _rightController, _rightFocus),
                _buildTextField("B", _bottomController, _bottomFocus),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
