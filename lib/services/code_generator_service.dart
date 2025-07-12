import 'package:dart_style/dart_style.dart';
import '../editor/components/core/widget_node.dart';
import '../editor/components/core/component_definition.dart';
import '../editor/models/page_node.dart';
import '../editor/properties/core/property_definition.dart';
import '../state/editor_state.dart';
import '../utils/string_utils.dart';
import '../services/issue_reporter_service.dart';

/// A service that generates executable Flutter/Dart code from a WidgetNode tree.
class CodeGeneratorService {
  final Map<String, RegisteredComponent> _registeredComponents;
  final _formatter = DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion);

  CodeGeneratorService(this._registeredComponents);

  /// Generate all Dart files for the entire project.
  /// Returns a map where key is the file name and value is the file content.
  Map<String, String> generateProjectCode(ProjectState project) {
    final Map<String, String> generatedFiles = {};

    // 1. Generate a separate file for each page
    for (final page in project.pages) {
      final pageClassName = toUpperCamelCase(page.name);
      final pageFileName = '${toSnakeCase(page.name)}.dart';
      final pageCode = _generatePageCode(page.tree, pageClassName);
      generatedFiles[pageFileName] = pageCode;
    }

    // 2. Generate a main.dart file
    final initialPage = project.pages.firstWhere(
            (p) => p.id == project.activePageId,
        orElse: () => project.pages.first
    );
    final initialPageClassName = toUpperCamelCase(initialPage.name);
    final initialPageFileName = toSnakeCase(initialPage.name);

    final mainCode = _generateMainDartCode(
        initialPageClassName, initialPageFileName);
    generatedFiles['main.dart'] = mainCode;

    return generatedFiles;
  }

  /// Generate Dart code strings for individual pages。
  String generateSinglePageFile(PageNode page) {
    final pageClassName = toUpperCamelCase(page.name);
    // We simply reuse existing proprietary methods
    return _generatePageCode(page.tree, pageClassName);
  }

  String _formatCode(String unformattedCode) {
    try {
      return _formatter.format(unformattedCode);
    } on FormatterException catch (e) {
      IssueReporterService().reportError(
        "Failed to format generated Dart code.",
        source: "CodeGeneratorService", error: e,
      );
      return "// DART CODE FORMATTING FAILED: $e\n\n$unformattedCode";
    }
  }

  /// Generate unformatted Dart code for individual pages。
  String _generatePageCode(WidgetNode rootNode, String pageClassName) {
    final widgetCode = _generateWidgetCodeRecursive(rootNode);
    final unformattedCode = """
    import 'package:flutter/material.dart';

   
    class $pageClassName extends StatelessWidget {
      const $pageClassName({super.key});

    @override
    Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
            title: const Text('$pageClassName'),
    ),
    body: $widgetCode,
    );
    }
    }
    """;
    return _formatCode(unformattedCode);
  }

  /// The code to generate the main.dart file.
  String _generateMainDartCode(String initialPageClassName,
      String initialPageFileName) {
    final unformattedCode = """
    import 'package:flutter/material.dart';
    import './$initialPageFileName';
    
    void main() {
      runApp(const MyApp());
    }
    
    class MyApp extends StatelessWidget {
      const MyApp({super.key});
    
      @override
      Widget build(BuildContext context) {
        return MaterialApp(
          title: 'Flutter Project',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          home: const $initialPageClassName(),
        );
      }
    }
    """;
    return _formatCode(unformattedCode);
  }

  /// The main dispatcher. It chooses a generation strategy based on the widget type.
  String _generateWidgetCodeRecursive(WidgetNode node) {
    final RegisteredComponent? rc = _registeredComponents[node.type];
    if (rc == null) return "const Text('Unknown Widget: ${node.type}')";

    switch (node.type) {
      case 'Text':
        return _generateTextWidgetCode(node, rc);
      case 'Container':
        return _generateContainerWidgetCode(node, rc);
      case 'ElevatedButton':
        return _generateElevatedButtonCode(node, rc);
      case 'Image':
        return _generateImageCode(node, rc);
      case 'TextField':
        return _generateTextFieldCode(node, rc);
      case 'Checkbox':
        return _generateCheckboxCode(node, rc);
      case 'Icon':
        return _generateIconCode(node, rc);
      case 'Card':
        return _generateCardWidgetCode(node, rc);
      case 'Switch':
        return _generateSwitchCode(node, rc);
      case 'Slider':
        return _generateSliderCode(node, rc);
      case 'AspectRatio':
        return _generateAspectRatioCode(node, rc);
      case 'DropdownButton':
        return _generateDropdownButtonCode(node, rc);
      case 'Expanded':
      case 'Flexible':
        return _generateFlexibleCode(node, rc);
      case 'Padding':
        return _generatePaddingCode(node, rc);
      case 'Radio':
        return _generateRadioCode(node, rc);
      default:
        return _generateGenericWidgetCode(node, rc);
    }
  }

  // =======================================================================
  // Specialized Generators for Complex Widgets (No indentation logic needed)
  // =======================================================================

  String _generateTextWidgetCode(WidgetNode node, RegisteredComponent rc) {
    final formattedText = _getFormattedProp(node, rc.propFields, 'text') ?? "''";
    final namedArgs = _collectDirectProps(node, rc, ['textAlign', 'softWrap', 'maxLines', 'overflow']);
    final textStyleCode = _generateTextStyleCode(node, rc.propFields);
    if (textStyleCode != null) {
      namedArgs.add(textStyleCode);
    }
    return "Text($formattedText, ${namedArgs.join(', ')})";
  }

  String _generateContainerWidgetCode(WidgetNode node, RegisteredComponent rc) {
    final directProps = _collectDirectProps(node, rc, ['width', 'height', 'alignment', 'margin', 'padding']);
    final decorationCode = _generateBoxDecorationCode(node, rc.propFields);
    final backgroundColor = _getFormattedProp(node, rc.propFields, 'backgroundColor');

    if (decorationCode != null) {
      directProps.add(decorationCode);
    } else if (backgroundColor != null) {
      directProps.add("color: $backgroundColor");
    }

    _addChildrenToProps(node, rc, directProps);

    return "Container(${directProps.join(', ')})";
  }

  String _generateElevatedButtonCode(WidgetNode node, RegisteredComponent rc) {
    final props = <String>["onPressed: () {}"];
    final styleCode = _generateButtonStyleCode(node, rc.propFields);
    if (styleCode != null) {
      props.add(styleCode);
    }

    if (node.children.isNotEmpty) {
      props.add("child: ${_generateWidgetCodeRecursive(node.children.first)}");
    } else {
      final buttonText = _getFormattedProp(node, rc.propFields, 'buttonText') ?? "''";
      props.add("child: Text($buttonText)");
    }

    return "ElevatedButton(${props.join(', ')})";
  }

  String _generateImageCode(WidgetNode node, RegisteredComponent rc) {
    final imageType = node.props['imageType'] ?? 'network';
    final src = _getFormattedProp(node, rc.propFields, 'src') ?? "''";
    final constructor = imageType == 'network' ? 'Image.network' : 'Image.asset';
    final directProps = _collectDirectProps(node, rc, ['width', 'height', 'fit', 'alignment', 'repeat', 'semanticLabel']);
    return "$constructor($src, ${directProps.join(', ')})";
  }

  String _generateTextFieldCode(WidgetNode node, RegisteredComponent rc) {
    final directProps = _collectDirectProps(node, rc, ['obscureText', 'keyboardType', 'maxLines', 'minLines', 'maxLength']);
    directProps.addAll(["readOnly: true", "enabled: false"]);

    final decorationProps = _collectDirectProps(node, rc, ['hintText', 'labelText']);
    if (decorationProps.isNotEmpty) {
      decorationProps.add("border: const OutlineInputBorder()");
      directProps.add("decoration: InputDecoration(${decorationProps.join(', ')})");
    } else {
      directProps.add("decoration: const InputDecoration(border: OutlineInputBorder())");
    }

    final styleCode = _generateTextStyleCode(node, rc.propFields);
    if (styleCode != null) {
      directProps.add(styleCode);
    }

    return "TextField(${directProps.join(', ')})";
  }

  String _generateCheckboxCode(WidgetNode node, RegisteredComponent rc) {
    final props = _collectDirectProps(node, rc, ['tristate', 'activeColor', 'checkColor', 'splashRadius']);
    final value = _getFormattedProp(node, rc.propFields, 'value', useDefault: true) ?? 'false';
    props.add("value: $value");
    props.add("onChanged: null");
    return "Checkbox(${props.join(', ')})";
  }

  String _generateIconCode(WidgetNode node, RegisteredComponent rc) {
    final iconData = _getFormattedProp(node, rc.propFields, 'iconName', useDefault: true) ?? 'Icons.error';
    final namedArgs = _collectDirectProps(node, rc, ['size', 'color']);
    return "Icon($iconData, ${namedArgs.join(', ')})";
  }

  String _generateCardWidgetCode(WidgetNode node, RegisteredComponent rc) {
    final props = _collectDirectProps(node, rc, ['backgroundColor', 'shadowColor', 'elevation', 'margin']);
    final borderRadius = node.props['borderRadius'];
    if (borderRadius is num && borderRadius > 0) {
      props.add("shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular($borderRadius))");
    }
    for (var i = 0; i < props.length; i++) {
      if (props[i].startsWith('backgroundColor:')) {
        props[i] = props[i].replaceFirst('backgroundColor:', 'color:');
      }
    }
    _addChildrenToProps(node, rc, props);
    return "Card(${props.join(', ')})";
  }

  String _generateSwitchCode(WidgetNode node, RegisteredComponent rc) {
    final props = _collectDirectProps(node, rc, ['activeColor', 'activeTrackColor', 'inactiveThumbColor', 'inactiveTrackColor']);
    final value = _getFormattedProp(node, rc.propFields, 'value', useDefault: true) ?? 'false';
    props.add("value: $value");
    props.add("onChanged: (bool val) {}");
    return "Switch(${props.join(', ')})";
  }

  String _generateSliderCode(WidgetNode node, RegisteredComponent rc) {
    final props = _collectDirectProps(node, rc, ['min', 'max', 'divisions', 'activeColor', 'inactiveColor', 'thumbColor']);
    final min = node.props['min'] as num? ?? 0.0;
    final max = node.props['max'] as num? ?? 1.0;
    num currentValue = node.props['value'] as num? ?? 0.5;
    if (currentValue < min) currentValue = min;
    if (currentValue > max) currentValue = max;

    props.add("value: ${currentValue.toDouble()}");
    props.add("onChanged: (double val) {}");
    return "Slider(${props.join(', ')})";
  }

  String _generateAspectRatioCode(WidgetNode node, RegisteredComponent rc) {
    final props = <String>[];
    final aspectRatio = _getFormattedProp(node, rc.propFields, 'aspectRatio', useDefault: true) ?? '1.0';
    props.add("aspectRatio: $aspectRatio");
    _addChildrenToProps(node, rc, props);
    return "AspectRatio(${props.join(', ')})";
  }

  String _generateDropdownButtonCode(WidgetNode node, RegisteredComponent rc) {
    final props = _collectDirectProps(node, rc, ['selectedValue', 'hintText', 'isExpanded']);
    final itemsString = node.props['itemsString'] as String? ?? '';
    final items = itemsString.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final itemsCode = items.map((item) => "DropdownMenuItem(value: '$item', child: Text('$item'))").join(', ');
    props.add("items: [$itemsCode]");
    props.add("onChanged: (val) {}");
    final styleCode = _generateTextStyleCode(node, rc.propFields);
    if(styleCode != null) {
      props.add(styleCode);
    }
    return "DropdownButton(${props.join(', ')})";
  }

  String _generateFlexibleCode(WidgetNode node, RegisteredComponent rc) {
    final props = _collectDirectProps(node, rc, ['flex', 'fit']);
    if (node.children.isEmpty) {
      props.add("child: const SizedBox.shrink()");
    } else {
      _addChildrenToProps(node, rc, props);
    }
    return "${rc.type}(${props.join(', ')})";
  }

  String _generatePaddingCode(WidgetNode node, RegisteredComponent rc) {
    final props = <String>[];
    final padding = _getFormattedProp(node, rc.propFields, 'padding', useDefault: true) ?? 'EdgeInsets.zero';
    props.add("padding: $padding");
    _addChildrenToProps(node, rc, props);
    return "Padding(${props.join(', ')})";
  }

  String _generateRadioCode(WidgetNode node, RegisteredComponent rc) {
    final props = _collectDirectProps(node, rc, ['activeColor']);
    final itemValue = _getFormattedProp(node, rc.propFields, 'itemValue', useDefault: true) ?? "''";
    final isSelected = node.props['isSelectedInGroup'] as bool? ?? false;
    final groupValue = isSelected ? itemValue : "'__unselected_${itemValue.hashCode}__'";

    props.add("value: $itemValue");
    props.add("groupValue: $groupValue");
    props.add("onChanged: (val) {}");
    return "Radio(${props.join(', ')})";
  }

  // =======================================================================
  // Generic Generator and Reusable Helpers
  // =======================================================================

  String _generateGenericWidgetCode(WidgetNode node, RegisteredComponent rc) {
    final propStrings = _collectDirectProps(node, rc, rc.propFields.map((f) => f.name).toList());
    _addChildrenToProps(node, rc, propStrings);
    return "${rc.type}(${propStrings.join(', ')})";
  }

  String? _generateTextStyleCode(WidgetNode node, List<PropField> allPropFields) {
    final stylePropsMap = <String, String>{};
    const stylePropNames = ['fontSize', 'fontWeight', 'fontStyle', 'textColor'];
    for (var propName in stylePropNames) {
      final formattedValue = _getFormattedProp(node, allPropFields, propName);
      if (formattedValue != null) {
        final styleKey = (propName == 'textColor') ? 'color' : propName;
        stylePropsMap[styleKey] = "$styleKey: $formattedValue";
      }
    }
    if (stylePropsMap.isEmpty) return null;
    return "style: const TextStyle(${stylePropsMap.values.join(', ')})";
  }

  String? _generateBoxDecorationCode(WidgetNode node, List<PropField> allPropFields) {
    final decoPropsMap = <String, String>{};
    final propsToTest = ['backgroundColor', 'borderRadius', 'borderWidth', 'shadowColor', 'gradientType'];
    bool hasAnyDecoProp = propsToTest.any((p) => node.props[p] != null && node.props[p] != _findPropByName(allPropFields, p)?.defaultValue);

    if (!hasAnyDecoProp) return null;

    final gradientType = node.props['gradientType'];
    if (gradientType == 'linear') {
      final color1 = _getFormattedProp(node, allPropFields, 'gradientColor1') ?? 'Colors.transparent';
      final color2 = _getFormattedProp(node, allPropFields, 'gradientColor2') ?? 'Colors.transparent';
      final begin = _getFormattedProp(node, allPropFields, 'gradientBeginAlignment') ?? 'Alignment.centerLeft';
      final end = _getFormattedProp(node, allPropFields, 'gradientEndAlignment') ?? 'Alignment.centerRight';
      decoPropsMap['gradient'] = 'gradient: LinearGradient(colors: [$color1, $color2], begin: $begin, end: $end)';
    } else {
      final color = _getFormattedProp(node, allPropFields, 'backgroundColor');
      if (color != null) decoPropsMap['color'] = 'color: $color';
    }

    final radius = _getFormattedProp(node, allPropFields, 'borderRadius');
    if (radius != null && radius != '0.0') decoPropsMap['borderRadius'] = 'borderRadius: BorderRadius.circular($radius)';

    final borderWidth = node.props['borderWidth'];
    if (borderWidth is num && borderWidth > 0) {
      final borderColor = _getFormattedProp(node, allPropFields, 'borderColor') ?? 'Colors.black';
      decoPropsMap['border'] = 'border: Border.all(color: $borderColor, width: $borderWidth)';
    }

    final shadowColor = _getFormattedProp(node, allPropFields, 'shadowColor');
    if (shadowColor != null) {
      final offsetX = _getFormattedProp(node, allPropFields, 'shadowOffsetX') ?? '0.0';
      final offsetY = _getFormattedProp(node, allPropFields, 'shadowOffsetY') ?? '0.0';
      final blur = _getFormattedProp(node, allPropFields, 'shadowBlurRadius') ?? '0.0';
      final spread = _getFormattedProp(node, allPropFields, 'shadowSpreadRadius') ?? '0.0';
      decoPropsMap['boxShadow'] = 'boxShadow: [BoxShadow(color: $shadowColor, offset: Offset($offsetX, $offsetY), blurRadius: $blur, spreadRadius: $spread)]';
    }

    if (decoPropsMap.isEmpty) return null;
    return "decoration: BoxDecoration(${decoPropsMap.values.join(', ')})";
  }

  String? _generateButtonStyleCode(WidgetNode node, List<PropField> allPropFields) {
    final stylePropsMap = <String, String>{};
    const stylePropNames = ['backgroundColor', 'foregroundColor', 'elevation', 'padding'];
    for (var propName in stylePropNames) {
      final formattedValue = _getFormattedProp(node, allPropFields, propName);
      if (formattedValue != null) {
        stylePropsMap[propName] = "$propName: MaterialStateProperty.all($formattedValue)";
      }
    }
    if (stylePropsMap.isEmpty) return null;
    return "style: ButtonStyle(${stylePropsMap.values.join(', ')})";
  }

  String? _getFormattedProp(WidgetNode node, List<PropField> allPropFields, String propName, {bool useDefault = false}) {
    final propValue = node.props[propName];
    final propField = _findPropByName(allPropFields, propName);

    if (propField == null) return null;

    // If we must use a value (for required params), use prop value or default value.
    if (useDefault) {
      final valueToFormat = propValue ?? propField.defaultValue;
      if (valueToFormat == null) return null;
      return _formatValue(valueToFormat, propField);
    }

    // Otherwise, only format if the value is not the default.
    if (propValue != null && propValue != propField.defaultValue) {
      return _formatValue(propValue, propField);
    }

    return null;
  }

  String? _formatValue(dynamic propValue, PropField propField) {
    if (propField.fieldType == FieldType.string && propValue is String) {
      final escaped = propValue
          .replaceAll('\\', '\\\\')
          .replaceAll("'", "\\'")
          .replaceAll('\n', '\\n')
          .replaceAll('\$', '\\\$');
      return "'$escaped'";
    }
    return propField.toCode?.call(propValue);
  }

  List<String> _collectDirectProps(WidgetNode node, RegisteredComponent rc, List<String> propNames) {
    final props = <String>[];
    for (var propName in propNames) {
      final formattedValue = _getFormattedProp(node, rc.propFields, propName);
      if (formattedValue != null) {
        props.add("$propName: $formattedValue");
      }
    }
    return props;
  }

  void _addChildrenToProps(WidgetNode node, RegisteredComponent rc, List<String> propStrings) {
    if (rc.childPolicy == ChildAcceptancePolicy.single && node.children.isNotEmpty) {
      propStrings.add("child: ${_generateWidgetCodeRecursive(node.children.first)}");
    } else if (rc.childPolicy == ChildAcceptancePolicy.multiple && node.children.isNotEmpty) {
      final childrenCode = node.children.map((child) => _generateWidgetCodeRecursive(child)).toList();
      propStrings.add("children: <Widget>[${childrenCode.join(', ')}]");
    }
  }

  PropField? _findPropByName(List<PropField> fields, String name) {
    try {
      return fields.firstWhere((f) => f.name == name);
    } catch (e) {
      return null;
    }
  }
}
