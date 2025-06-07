// Formats a string value into Dart code, handling escaping.

import 'property_definition.dart';

String? kStringCodeFormatter(dynamic value) {
  if (value == null || (value is String && value.isEmpty)) return null;
  return "'${value.toString().replaceAll("'", "\\'").replaceAll("\n", "\\n")}'";
}

// Formats a numeric value.
String? kNumberCodeFormatter(dynamic value) {
  if (value == null) return null;
  if (value is String && num.tryParse(value) != null) return num.parse(value).toString();
  if (value is num) return value.toString();
  return null;
}

// Formats a boolean value.
String? kBooleanCodeFormatter(dynamic value) {
  if (value == null || value is! bool) return null;
  return value.toString();
}

// Formats a hex color string into a `Color(0x...)` expression.
String? kColorCodeFormatter(dynamic value) {
  if (value == null || value is! String || value.isEmpty) return null;
  String hex = value.toUpperCase().replaceFirst('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  if (hex.length == 8) return "const Color(0x$hex)";
  return null; // Invalid format
}

// Formats an EdgeInsets string into an `EdgeInsets` expression.
String? kEdgeInsetsCodeFormatter(dynamic value) {
  if (value == null || value is! String || value.isEmpty) return "EdgeInsets.zero";
  final normalized = value.toLowerCase().replaceAll(' ', '');
  if (normalized.startsWith('all:')) {
    final val = double.tryParse(normalized.substring(4)) ?? 0.0;
    return "const EdgeInsets.all($val)";
  } else if (normalized.startsWith('symmetric:')) {
    double h = 0.0, v = 0.0;
    final parts = normalized.substring(10).split(',');
    for (var part in parts) {
      if (part.startsWith('h')) h = double.tryParse(part.substring(1)) ?? 0.0;
      if (part.startsWith('v')) v = double.tryParse(part.substring(1)) ?? 0.0;
    }
    return "const EdgeInsets.symmetric(horizontal: $h, vertical: $v)";
  } else if (normalized.startsWith('only:')) {
    final RegExp lReg = RegExp(r'l(-?[\d.]+)');
    final RegExp tReg = RegExp(r't(-?[\d.]+)');
    final RegExp rReg = RegExp(r'r(-?[\d.]+)');
    final RegExp bReg = RegExp(r'b(-?[\d.]+)');
    final content = normalized.substring(5);
    final l = double.tryParse(lReg.firstMatch(content)?.group(1) ?? '0') ?? 0.0;
    final t = double.tryParse(tReg.firstMatch(content)?.group(1) ?? '0') ?? 0.0;
    final r = double.tryParse(rReg.firstMatch(content)?.group(1) ?? '0') ?? 0.0;
    final b = double.tryParse(bReg.firstMatch(content)?.group(1) ?? '0') ?? 0.0;
    return "const EdgeInsets.only(left: $l, top: $t, right: $r, bottom: $b)";
  }
  return "EdgeInsets.zero";
}

// Creates a generic formatter for enums.
PropValueToCodeFormatter kEnumCodeFormatter(String enumClassName) {
  return (value) {
    if (value == null || (value is String && value.isEmpty)) return null;
    return '$enumClassName.$value';
  };
}