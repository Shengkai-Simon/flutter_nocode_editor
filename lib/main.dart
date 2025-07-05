import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_editor/services/issue_reporter_service.dart';
import 'package:flutter_editor/ui/common/AppLoader.dart';
import 'package:flutter_editor/ui/common/app_error_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'constants/app_constants.dart';
import 'state/editor_state.dart';
import 'ui/canvas/canvas_view.dart';
import 'ui/left/left_view.dart';
import 'ui/right/right_view.dart';

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      AppErrorHandler.initialize();

      runApp(const ProviderScope(child: MyApp()));
    },
    (error, stackTrace) {
      IssueReporterService().reportError(
        "An unhandled error occurred.",
        source: "runZonedGuarded",
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Visual Editor',
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      home: const AppLoader(),
    );
  }
}

class EditorScaffold extends ConsumerWidget {
  const EditorScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedNodeId = ref.watch(selectedNodeIdProvider);
    final isRightPanelVisible = selectedNodeId != null;

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              const SizedBox(width: kLeftPanelWidth, child: LeftView()),
              Expanded(
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.only(
                    right: isRightPanelVisible ? kRightPanelWidth : 0,
                  ),
                  child: const CanvasView(),
                ),
              ),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            right: isRightPanelVisible ? 0 : -(kRightPanelWidth + 1),
            top: 0,
            bottom: 0,
            child: Material(
              elevation: 8.0,
              child: Row(
                children: [
                  const VerticalDivider(width: 1, thickness: 1),
                  SizedBox(width: kRightPanelWidth, child: const RightView()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
