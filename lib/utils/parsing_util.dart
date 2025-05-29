import 'package:flutter/material.dart';

class ParsingUtil {

  static TextInputType parseTextInputType(String? inputTypeString, {TextInputType defaultType = TextInputType.text}) {
    switch (inputTypeString?.toLowerCase()) {
      case 'text': return TextInputType.text;
      case 'multiline': return TextInputType.multiline;
      case 'number': return TextInputType.number;
      case 'phone': return TextInputType.phone;
      case 'datetime': return TextInputType.datetime;
      case 'emailaddress': return TextInputType.emailAddress;
      case 'url': return TextInputType.url;
      case 'visiblepassword': return TextInputType.visiblePassword;
      case 'name': return TextInputType.name;
      case 'streetaddress': return TextInputType.streetAddress;
      case 'none': return TextInputType.none;
      default: return defaultType;
    }
  }

  static Clip parseClipBehavior(String? clipString) {
    switch (clipString?.toLowerCase()) {
      case 'none': return Clip.none;
      case 'hardedge': return Clip.hardEdge;
      case 'antialias': return Clip.antiAlias;
      case 'antialiaswithsavelayer': return Clip.antiAliasWithSaveLayer;
      default: return Clip.hardEdge;
    }
  }

  static Axis parseAxis(String? axisString, {Axis defaultAxis = Axis.horizontal}) {
    if (axisString == 'vertical') return Axis.vertical;
    return defaultAxis;
  }

  static WrapAlignment parseWrapAlignment(String? alignmentString, {WrapAlignment defaultAlignment = WrapAlignment.start}) {
    switch (alignmentString?.toLowerCase()) {
      case 'start': return WrapAlignment.start;
      case 'end': return WrapAlignment.end;
      case 'center': return WrapAlignment.center;
      case 'spacebetween': return WrapAlignment.spaceBetween;
      case 'spacearound': return WrapAlignment.spaceAround;
      case 'spaceevenly': return WrapAlignment.spaceEvenly;
      default: return defaultAlignment;
    }
  }

  static WrapCrossAlignment parseWrapCrossAlignment(String? crossAlignmentString, {WrapCrossAlignment defaultAlignment = WrapCrossAlignment.start}) {
    switch (crossAlignmentString?.toLowerCase()) {
      case 'start': return WrapCrossAlignment.start;
      case 'end': return WrapCrossAlignment.end;
      case 'center': return WrapCrossAlignment.center;
      default: return defaultAlignment;
    }
  }

  static ImageRepeat parseImageRepeat(String? repeat) {
    switch (repeat?.toLowerCase()) {
      case 'repeat':
        return ImageRepeat.repeat;
      case 'repeatx':
        return ImageRepeat.repeatX;
      case 'repeaty':
        return ImageRepeat.repeatY;
      case 'norepeat':
        return ImageRepeat.noRepeat;
      default:
        return ImageRepeat.noRepeat;
    }
  }

  /// Parses a string into a FontWeight enum value.
  static FontWeight parseFontWeight(String? weight) {
    switch (weight?.toLowerCase()) {
      case 'bold':
        return FontWeight.bold;
      case 'normal':
        return FontWeight.normal;
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400': // normal
        return FontWeight.w400;
      case 'w500':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700': // bold
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      case 'w900':
        return FontWeight.w900;
      default:
        return FontWeight.normal;
    }
  }

  /// Parses a string into a FontStyle enum value.
  static FontStyle parseFontStyle(String? style) {
    switch (style?.toLowerCase()) {
      case 'italic':
        return FontStyle.italic;
      case 'normal':
        return FontStyle.normal;
      default:
        return FontStyle.normal;
    }
  }

  /// Parses a string into a TextOverflow enum value.
  static TextOverflow parseTextOverflow(String? overflow) {
    switch (overflow?.toLowerCase()) {
      case 'clip':
        return TextOverflow.clip;
      case 'fade':
        return TextOverflow.fade;
      case 'ellipsis':
        return TextOverflow.ellipsis;
      case 'visible':
        return TextOverflow.visible;
      default:
        return TextOverflow.clip;
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
      default: return TextAlign.start;
    }
  }

  static EdgeInsetsGeometry parseEdgeInsets(String? value) {
    if (value == null || value.isEmpty) return EdgeInsets.zero;
    String normalizedValue = value.toLowerCase().replaceAll(' ', '');

    try {
      if (normalizedValue.startsWith('all:')) {
        final doubleVal = double.tryParse(normalizedValue.substring(4));
        return EdgeInsets.all(doubleVal ?? 0);
      } else if (normalizedValue.startsWith('symmetric:')) {
        normalizedValue = normalizedValue.substring(10);
        double vertical = 0;
        double horizontal = 0;
        final parts = normalizedValue.split(',');
        for (var part in parts) {
          if (part.startsWith('v')) {
            vertical = double.tryParse(part.substring(1)) ?? 0;
          } else if (part.startsWith('h')) {
            horizontal = double.tryParse(part.substring(1)) ?? 0;
          }
        }
        return EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal);
      } else if (normalizedValue.startsWith('only:')) {
        normalizedValue = normalizedValue.substring(5);
      }

      final RegExp lReg = RegExp(r'l(-?[\d.]+)');
      final RegExp tReg = RegExp(r't(-?[\d.]+)');
      final RegExp rReg = RegExp(r'r(-?[\d.]+)');
      final RegExp bReg = RegExp(r'b(-?[\d.]+)');

      bool hasL = lReg.hasMatch(normalizedValue);
      bool hasT = tReg.hasMatch(normalizedValue);
      bool hasR = rReg.hasMatch(normalizedValue);
      bool hasB = bReg.hasMatch(normalizedValue);

      if (hasL || hasT || hasR || hasB) {
        double left = double.tryParse(lReg.firstMatch(normalizedValue)?.group(1) ?? '0') ?? 0;
        double top = double.tryParse(tReg.firstMatch(normalizedValue)?.group(1) ?? '0') ?? 0;
        double right = double.tryParse(rReg.firstMatch(normalizedValue)?.group(1) ?? '0') ?? 0;
        double bottom = double.tryParse(bReg.firstMatch(normalizedValue)?.group(1) ?? '0') ?? 0;
        return EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
      }
      final parts = normalizedValue.split(',');
      if (parts.length == 4) {
        return EdgeInsets.only(
          left: double.tryParse(parts[0]) ?? 0,
          top: double.tryParse(parts[1]) ?? 0,
          right: double.tryParse(parts[2]) ?? 0,
          bottom: double.tryParse(parts[3]) ?? 0,
        );
      }
      if (parts.length == 1) {
        final singleVal = double.tryParse(parts[0]);
        if (singleVal != null) {
          return EdgeInsets.all(singleVal);
        }
      }
    } catch (e) {
      print('Error parsing EdgeInsets string "$value" (normalized: "$normalizedValue"): $e. Falling back to EdgeInsets.zero.');
      return EdgeInsets.zero;
    }
    print('Warning: Could not parse EdgeInsets string "$value" (normalized: "$normalizedValue") into a known format. Falling back to EdgeInsets.zero.');
    return EdgeInsets.zero;
  }

  /// Helper function to parse alignment string
  static AlignmentGeometry parseAlignment(String? alignStr) {
    if (alignStr == null || alignStr.isEmpty) {
      return Alignment.center;
    }
    switch (alignStr) {
      case 'topLeft':
        return Alignment.topLeft;
      case 'topCenter':
        return Alignment.topCenter;
      case 'topRight':
        return Alignment.topRight;
      case 'centerLeft':
        return Alignment.centerLeft;
      case 'center':
        return Alignment.center;
      case 'centerRight':
        return Alignment.centerRight;
      case 'bottomLeft':
        return Alignment.bottomLeft;
      case 'bottomCenter':
        return Alignment.bottomCenter;
      case 'bottomRight':
        return Alignment.bottomRight;
      default:
        print('Warning: Unrecognized alignment string "$alignStr". Falling back to Alignment.center.');
        return Alignment.center;
    }
  }

  static MainAxisAlignment parseMainAxisAlignment(String? value) {
    switch (value) {
      case 'start':
        return MainAxisAlignment.start;
      case 'end':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'spaceBetween':
        return MainAxisAlignment.spaceBetween;
      case 'spaceAround':
        return MainAxisAlignment.spaceAround;
      case 'spaceEvenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        print('Warning: Unrecognized MainAxisAlignment string "$value". Falling back to MainAxisAlignment.start.');
        return MainAxisAlignment.start;
    }
  }

  static CrossAxisAlignment parseCrossAxisAlignment(String? value) {
    switch (value) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'end':
        return CrossAxisAlignment.end;
      case 'center':
        return CrossAxisAlignment.center;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      case 'baseline':
        return CrossAxisAlignment.baseline;
      default:
        print('Warning: Unrecognized CrossAxisAlignment string "$value". Falling back to CrossAxisAlignment.center.');
        return CrossAxisAlignment.center;
    }
  }

  static MainAxisSize parseMainAxisSize(String? value) {
    switch (value) {
      case 'min':
        return MainAxisSize.min;
      case 'max':
        return MainAxisSize.max;
      default:
        print('Warning: Unrecognized MainAxisSize string "$value". Falling back to MainAxisSize.max.');
        return MainAxisSize.max;
    }
  }

  /// Converts a hex color string to a Flutter Color. Returns a default color if parsing fails or input is empty/null.
  static Color parseColor(String? hex, {Color defaultColor = Colors.black}) {
    if (hex == null || hex.isEmpty) {
      return defaultColor;
    }

    final cleanHex = hex.replaceFirst('#', '');

    try {
      if (cleanHex.length == 6) {
        return Color(int.parse('FF$cleanHex', radix: 16));
      } else if (cleanHex.length == 8) {
        return Color(int.parse(cleanHex, radix: 16));
      } else {
        print('Warning: Invalid hex color string length for "$hex" (cleaned: "$cleanHex"). Using default.');
        return defaultColor;
      }
    } on FormatException catch (e) {
      print('Warning: Malformed hex color string "$hex" (cleaned: "$cleanHex"): $e. Using default.');
      return defaultColor;
    } catch (e) {
      print('Error parsing hex color string "$hex": $e. Using default.');
      return defaultColor;
    }
  }
}