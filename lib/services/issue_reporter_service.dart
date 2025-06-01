import 'dart:async';
import 'package:flutter/foundation.dart';

class IssueReporterService {
  static final IssueReporterService _instance = IssueReporterService._internal();
  factory IssueReporterService() => _instance;
  IssueReporterService._internal();

  final _errorStreamController = StreamController<String>.broadcast();
  Stream<String> get errorStream => _errorStreamController.stream;

  final _warningStreamController = StreamController<String>.broadcast();
  Stream<String> get warningStream => _warningStreamController.stream;

  void reportError(String message, {String? source, Object? error, StackTrace? stackTrace}) {
    String fullMessage = source != null ? "[$source] $message" : message;
    if (error != null) {
      fullMessage += "\n  Details: ${error.toString().split('\n').first}";
    }
    if (!_errorStreamController.isClosed) {
      _errorStreamController.add(fullMessage);
    }
    print("ISSUE REPORTER (ERROR): $fullMessage");
    if (error != null && stackTrace != null && error is! FlutterErrorDetails) {
      print("  Associated Dart Error: $error");
      print("  Associated Dart StackTrace:\n$stackTrace");
    }
  }

  void reportFlutterError(FlutterErrorDetails details) {
    String messageForUiList = "[Flutter Framework] ${details.exceptionAsString()}";
    if (!_errorStreamController.isClosed) {
      _errorStreamController.add(messageForUiList);
    }
  }

  void reportWarning(String message, {String? source}) {
    String fullMessage = source != null ? "[$source] $message" : message;
    if (!_warningStreamController.isClosed) {
      _warningStreamController.add(fullMessage);
    }
  }

  void dispose() {
    _errorStreamController.close();
    _warningStreamController.close();
  }
}