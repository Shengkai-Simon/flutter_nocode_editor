import 'package:flutter/material.dart';

import '../services/issue_reporter_service.dart';

class ParsingUtil {

  static T _handleUnrecognizedValueAndReport<T>({
    required String? inputValue,
    required T defaultValue,
    required String propertyTypeName,
    required String parsingMethodName,
    bool reportNullAsWarning = false,
  }) {
    String warningMessage = "";
    final String source = "ParsingUtil.$parsingMethodName";

    if (inputValue != null && inputValue.isNotEmpty) {
      warningMessage = 'Unrecognized $propertyTypeName string "$inputValue". Falling back to default.';
    } else if (inputValue == null && reportNullAsWarning) {
      warningMessage = '$propertyTypeName value was null. Falling back to default.';
    }

    if (warningMessage.isNotEmpty) {
      IssueReporterService().reportWarning(warningMessage, source: source);
    }
    return defaultValue;
  }


  static TextInputType parseTextInputType(String? inputTypeString, {TextInputType defaultType = TextInputType.text}) {
    switch (inputTypeString?.toLowerCase()) {
      case 'text': return TextInputType.text;
      case 'multiline': return TextInputType.multiline;
      case 'number': return TextInputType.number;
      case 'phone': return TextInputType.phone;
      case 'datetime': return TextInputType.datetime;
      case 'emailAddress': return TextInputType.emailAddress;
      case 'url': return TextInputType.url;
      case 'visiblePassword': return TextInputType.visiblePassword;
      case 'name': return TextInputType.name;
      case 'streetAddress': return TextInputType.streetAddress;
      case 'none': return TextInputType.none;
      default:
        return _handleUnrecognizedValueAndReport(
          inputValue: inputTypeString,
          defaultValue: defaultType,
          propertyTypeName: "TextInputType",
          parsingMethodName: "TextInputType",
        );
    }
  }

  static Clip parseClipBehavior(String? clipString) {
    switch (clipString?.toLowerCase()) {
      case 'none': return Clip.none;
      case 'hardedge': return Clip.hardEdge;
      case 'antialias': return Clip.antiAlias;
      case 'antialiaswithsavelayer': return Clip.antiAliasWithSaveLayer;
      default:
        return _handleUnrecognizedValueAndReport(
          inputValue: clipString,
          defaultValue: Clip.hardEdge,
          propertyTypeName: "Clip",
          parsingMethodName: "ClipBehavior",
        );
    }
  }

  static Axis parseAxis(String? axisString, {Axis defaultAxis = Axis.horizontal}) {
    if (axisString == null || axisString.isEmpty) return defaultAxis;
    switch(axisString.toLowerCase()){
      case 'horizontal': return Axis.horizontal;
      case 'vertical': return Axis.vertical;
      default:
        return _handleUnrecognizedValueAndReport(
          inputValue: axisString,
          defaultValue: defaultAxis,
          propertyTypeName: "Axis",
          parsingMethodName: "Axis",
        );
    }
  }

  static WrapAlignment parseWrapAlignment(String? alignmentString, {WrapAlignment defaultAlignment = WrapAlignment.start}) {
    switch (alignmentString?.toLowerCase()) {
      case 'start': return WrapAlignment.start;
      case 'end': return WrapAlignment.end;
      case 'center': return WrapAlignment.center;
      case 'spacebetween': return WrapAlignment.spaceBetween;
      case 'spacearound': return WrapAlignment.spaceAround;
      case 'spaceevenly': return WrapAlignment.spaceEvenly;
      default:
        return _handleUnrecognizedValueAndReport(
          inputValue: alignmentString,
          defaultValue: defaultAlignment,
          propertyTypeName: "WrapAlignment",
          parsingMethodName: "WrapAlignment",
        );
    }
  }

  static WrapCrossAlignment parseWrapCrossAlignment(String? crossAlignmentString, {WrapCrossAlignment defaultAlignment = WrapCrossAlignment.start}) {
    switch (crossAlignmentString?.toLowerCase()) {
      case 'start': return WrapCrossAlignment.start;
      case 'end': return WrapCrossAlignment.end;
      case 'center': return WrapCrossAlignment.center;
      default:
        return _handleUnrecognizedValueAndReport(
          inputValue: crossAlignmentString,
          defaultValue: defaultAlignment,
          propertyTypeName: "WrapCrossAlignment",
          parsingMethodName: "WrapCrossAlignment",
        );
    }
  }

  static ImageRepeat parseImageRepeat(String? repeat) {
    switch (repeat?.toLowerCase()) {
      case 'repeat': return ImageRepeat.repeat;
      case 'repeatx': return ImageRepeat.repeatX;
      case 'repeaty': return ImageRepeat.repeatY;
      case 'norepeat': return ImageRepeat.noRepeat;
      default:
        return _handleUnrecognizedValueAndReport(
          inputValue: repeat,
          defaultValue: ImageRepeat.noRepeat,
          propertyTypeName: "ImageRepeat",
          parsingMethodName: "ImageRepeat",
        );
    }
  }

  /// Parses a string into a FontWeight enum value.
  static FontWeight parseFontWeight(String? weight) {
    switch (weight?.toLowerCase()) {
      case 'bold': return FontWeight.bold;
      case 'normal': return FontWeight.normal;
      case 'w100': return FontWeight.w100;
      case 'w200': return FontWeight.w200;
      case 'w300': return FontWeight.w300;
      case 'w400': return FontWeight.w400; // normal
      case 'w500': return FontWeight.w500;
      case 'w600': return FontWeight.w600;
      case 'w700': return FontWeight.w700; // bold
      case 'w800': return FontWeight.w800;
      case 'w900': return FontWeight.w900;
      default:
        return _handleUnrecognizedValueAndReport(
          inputValue: weight,
          defaultValue: FontWeight.normal,
          propertyTypeName: "FontWeight",
          parsingMethodName: "FontWeight",
        );
    }
  }

  /// Parses a string into a FontStyle enum value.
  static FontStyle parseFontStyle(String? style) {
    switch (style?.toLowerCase()) {
      case 'italic': return FontStyle.italic;
      case 'normal': return FontStyle.normal;
      default:
        return _handleUnrecognizedValueAndReport(
          inputValue: style,
          defaultValue: FontStyle.normal,
          propertyTypeName: "FontStyle",
          parsingMethodName: "FontStyle",
        );
    }
  }

  /// Parses a string into a TextOverflow enum value.
  static TextOverflow parseTextOverflow(String? overflow) {
    switch (overflow?.toLowerCase()) {
      case 'clip': return TextOverflow.clip;
      case 'fade': return TextOverflow.fade;
      case 'ellipsis': return TextOverflow.ellipsis;
      case 'visible': return TextOverflow.visible;
      default:
        return _handleUnrecognizedValueAndReport(
          inputValue: overflow,
          defaultValue: TextOverflow.clip,
          propertyTypeName: "TextOverflow",
          parsingMethodName: "TextOverflow",
        );

    }
  }

  static TextAlign parseTextAlign(String? align) {
    switch (align) {
      case 'left': return TextAlign.left;
      case 'right': return TextAlign.right;
      case 'center': return TextAlign.center;
      case 'justify': return TextAlign.justify;
      case 'start': return TextAlign.start;
      case 'end': return TextAlign.end;
      default:
        return _handleUnrecognizedValueAndReport(
          inputValue: align,
          defaultValue: TextAlign.start,
          propertyTypeName: "TextAlign",
          parsingMethodName: "TextAlign",
        );
    }
  }

  static EdgeInsetsGeometry parseEdgeInsets(String? value) {
    if (value == null || value.isEmpty) return EdgeInsets.zero;
    String normalizedValue = value.toLowerCase().replaceAll(' ', '');

    try {
      final RegExp singleSideRegExp = RegExp(r'^(l|t|r|b):(-?[\d.]+)$');
      if (singleSideRegExp.hasMatch(normalizedValue)) {
        final match = singleSideRegExp.firstMatch(normalizedValue)!;
        final side = match.group(1)!;
        final valStr = match.group(2)!;
        final val = double.tryParse(valStr);
        if (val == null) {
          IssueReporterService().reportWarning('Invalid number for EdgeInsets $side: "$valStr". Using 0.', source: "ParsingUtil.EdgeInsets");
          return EdgeInsets.zero;
        }
        switch (side) {
          case 'l': return EdgeInsets.only(left: val);
          case 't': return EdgeInsets.only(top: val);
          case 'r': return EdgeInsets.only(right: val);
          case 'b': return EdgeInsets.only(bottom: val);
        }
      }
      if (normalizedValue.startsWith('all:')) {
        final valStr = normalizedValue.substring(4);
        final doubleVal = double.tryParse(valStr);
        if (doubleVal == null) IssueReporterService().reportWarning('Invalid number for EdgeInsets.all: "$valStr". Using 0.', source: "ParsingUtil.EdgeInsets");
        return EdgeInsets.all(doubleVal ?? 0);
      } else if (normalizedValue.startsWith('symmetric:')) {
        normalizedValue = normalizedValue.substring(10);
        double vertical = 0;
        double horizontal = 0;
        final parts = normalizedValue.split(',');
        for (var part in parts) {
          if (part.startsWith('v')) {
            final val = double.tryParse(part.substring(1));
            if (val == null) IssueReporterService().reportWarning('Invalid number for symmetric vertical padding: "${part.substring(1)}". Using 0.');
            vertical = val ?? 0;
          } else if (part.startsWith('h')) {
            final val = double.tryParse(part.substring(1));
            if (val == null) IssueReporterService().reportWarning('Invalid number for symmetric horizontal padding: "${part.substring(1)}". Using 0.');
            horizontal = val ?? 0;
          }
        }
        return EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal);
      } else if (normalizedValue.startsWith('only:')) {
        normalizedValue = normalizedValue.substring(5);
        final RegExp lReg = RegExp(r'l(-?[\d.]+)');
        final RegExp tReg = RegExp(r't(-?[\d.]+)');
        final RegExp rReg = RegExp(r'r(-?[\d.]+)');
        final RegExp bReg = RegExp(r'b(-?[\d.]+)');
        double parseSide(RegExp reg, String input, String sideName) {
          final match = reg.firstMatch(input);
          if (match == null) return 0;
          final valStr = match.group(1);
          final val = double.tryParse(valStr ?? '0');
          if (val == null) IssueReporterService().reportWarning('Invalid number for EdgeInsets.only $sideName: "$valStr". Using 0.');
          return val ?? 0;
        }
        double left = parseSide(lReg, normalizedValue, 'left');
        double top = parseSide(tReg, normalizedValue, 'top');
        double right = parseSide(rReg, normalizedValue, 'right');
        double bottom = parseSide(bReg, normalizedValue, 'bottom');
        return EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
      }

      final parts = normalizedValue.split(',');
      if (parts.length == 4) {
        return EdgeInsets.fromLTRB(
            double.tryParse(parts[0]) ?? 0, double.tryParse(parts[1]) ?? 0,
            double.tryParse(parts[2]) ?? 0, double.tryParse(parts[3]) ?? 0
        );
      }
      if (parts.length == 1 && double.tryParse(parts[0]) != null) {
        return EdgeInsets.all(double.parse(parts[0]));
      }

    } catch (e) {
      IssueReporterService().reportWarning('Error parsing EdgeInsets string "$value": $e. Falling back to EdgeInsets.zero.', source: "ParsingUtil.EdgeInsets");
      return EdgeInsets.zero;
    }
    IssueReporterService().reportWarning('Could not parse EdgeInsets string "$value" into any known format. Falling back to EdgeInsets.zero.', source: "ParsingUtil.EdgeInsets");
    return EdgeInsets.zero;
  }


  /// Helper function to parse alignment string
  static AlignmentGeometry parseAlignment(String? alignStr) {
    if (alignStr == null || alignStr.isEmpty) {
      return Alignment.center;
    }
    switch (alignStr) {
      case 'topLeft': return Alignment.topLeft;
      case 'topCenter': return Alignment.topCenter;
      case 'topRight': return Alignment.topRight;
      case 'centerLeft': return Alignment.centerLeft;
      case 'center': return Alignment.center;
      case 'centerRight': return Alignment.centerRight;
      case 'bottomLeft': return Alignment.bottomLeft;
      case 'bottomCenter': return Alignment.bottomCenter;
      case 'bottomRight': return Alignment.bottomRight;
      default:
        return _handleUnrecognizedValueAndReport(
          inputValue: alignStr,
          defaultValue: Alignment.center,
          propertyTypeName: "AlignmentGeometry",
          parsingMethodName: "Alignment",
        );
    }
  }

  static MainAxisAlignment parseMainAxisAlignment(String? value) {
    switch (value) {
      case 'start': return MainAxisAlignment.start;
      case 'end': return MainAxisAlignment.end;
      case 'center': return MainAxisAlignment.center;
      case 'spaceBetween': return MainAxisAlignment.spaceBetween;
      case 'spaceAround': return MainAxisAlignment.spaceAround;
      case 'spaceEvenly': return MainAxisAlignment.spaceEvenly;
      default:
        return _handleUnrecognizedValueAndReport(
          inputValue: value,
          defaultValue: MainAxisAlignment.start,
          propertyTypeName: "MainAxisAlignment",
          parsingMethodName: "MainAxisAlignment",
        );
    }
  }

  static CrossAxisAlignment parseCrossAxisAlignment(String? value) {
    switch (value) {
      case 'start': return CrossAxisAlignment.start;
      case 'end': return CrossAxisAlignment.end;
      case 'center': return CrossAxisAlignment.center;
      case 'stretch': return CrossAxisAlignment.stretch;
      case 'baseline': return CrossAxisAlignment.baseline;
      default:
        return _handleUnrecognizedValueAndReport(
          inputValue: value,
          defaultValue: CrossAxisAlignment.center,
          propertyTypeName: "CrossAxisAlignment",
          parsingMethodName: "CrossAxisAlignment",
        );
    }
  }

  static MainAxisSize parseMainAxisSize(String? value) {
    switch (value) {
      case 'min': return MainAxisSize.min;
      case 'max': return MainAxisSize.max;
      default:
        return _handleUnrecognizedValueAndReport(
          inputValue: value,
          defaultValue: MainAxisSize.max,
          propertyTypeName: "MainAxisSize",
          parsingMethodName: "MainAxisSize",
        );
    }
  }

  /// Converts a hex color string to a Flutter Color. Returns a default color if parsing fails or input is empty/null.
  static Color parseColor(String? hex, {Color defaultColor = Colors.black}) {
    if (hex == null || hex.isEmpty) return defaultColor;
    final cleanHex = hex.replaceFirst('#', '');
    try {
      if (cleanHex.length == 6) return Color(int.parse('FF$cleanHex', radix: 16));
      if (cleanHex.length == 8) return Color(int.parse(cleanHex, radix: 16));
      IssueReporterService().reportWarning('Invalid hex color string length for "$hex". Using default color.', source: "ParsingUtil.Color");
      return defaultColor;
    } catch (e) {
      IssueReporterService().reportWarning('Error parsing hex color string "$hex": $e. Using default color.', source: "ParsingUtil.Color");
      return defaultColor;
    }
  }
}