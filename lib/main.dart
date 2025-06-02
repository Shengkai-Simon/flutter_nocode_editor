import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_editor/services/issue_reporter_service.dart';
import 'package:flutter_editor/ui/common/app_error_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'constants/app_constants.dart';
import 'ui/left/left_view.dart';
import 'ui/canvas/canvas_view.dart';
import 'ui/right/right_view.dart';

void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    AppErrorHandler.initialize();

    runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );
  }, (error, stackTrace) {

    print('Unhandled error caught by runZonedGuarded:');
    print('Error: $error');
    print('StackTrace: $stackTrace');

    IssueReporterService().reportError(
      "An unhandled error occurred outside of Flutter's typical framework error handling.",
      source: "runZonedGuarded",
      error: error,
      stackTrace: stackTrace,
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Visual Editor',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const EditorScaffold(),
    );
  }
}

class EditorScaffold extends StatelessWidget {
  const EditorScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Row(
        children: [
          SizedBox(width: kLeftPanelWidth, child: LeftView()),
          Expanded(child: CanvasView()),
          SizedBox(width: kRightPanelWidth, child: RightView()),
        ],
      ),
    );
  }
}