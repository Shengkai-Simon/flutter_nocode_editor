import 'package:recase/recase.dart';

/// Converts the given string to UpperCamelCase (PascalCase)。
/// Example: "hello world" -> "HelloWorld"
String toUpperCamelCase(String text) {
  return ReCase(text).pascalCase;
}

/// Converts the given string to snake_case。
/// Example: "Hello World" -> "hello_world"
String toSnakeCase(String text) {
  return ReCase(text).snakeCase;
}