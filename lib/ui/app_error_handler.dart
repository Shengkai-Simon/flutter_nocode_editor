import 'package:flutter/foundation.dart';
import '../services/issue_reporter_service.dart';

class AppErrorHandler {
  static bool _isFrameworkErrorHandlerInitialized = false;

  static void initialize() {
    if (_isFrameworkErrorHandlerInitialized) return;

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      IssueReporterService().reportFlutterError(details);
    };

    _isFrameworkErrorHandlerInitialized = true;
  }

}