import 'package:flutter/material.dart';

class ComponentUtil {

  static EdgeInsetsGeometry parseEdgeInsets(String? value) {
    if (value == null || value.isEmpty) return EdgeInsets.zero;
    String normalizedValue = value.toLowerCase().replaceAll(' ', '');

    try {
      if (normalizedValue.startsWith('all:')) {
        final doubleVal = double.tryParse(normalizedValue.substring(4));
        return EdgeInsets.all(doubleVal ?? 0);
      } else if (normalizedValue.startsWith('symmetric:')) {
        normalizedValue = normalizedValue.substring(10); // remove "symmetric:"
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

  /// hex color → Flutter Color
  static Color parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.black;
    final cleanHex = hex.replaceFirst('#', '');
    try {
      if (cleanHex.length == 6) {
        return Color(int.parse('FF$cleanHex', radix: 16));
      } else if (cleanHex.length == 8) {
        return Color(int.parse(cleanHex, radix: 16));
      } else {
        print('Warning: Invalid hex color string length for "$hex" (cleaned: "$cleanHex"). Must be 6 or 8 characters after #. Falling back to Colors.black.');
        return Colors.black;
      }
    } on FormatException catch (e) {
      print('Warning: Malformed hex color string "$hex" (cleaned: "$cleanHex"): $e. Falling back to Colors.black.');
      return Colors.black;
    } catch (e) {
      print('Error parsing hex color string "$hex": $e. Falling back to Colors.black.');
      return Colors.black;
    }
  }
}
