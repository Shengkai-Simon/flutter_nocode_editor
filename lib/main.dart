import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_editor/services/issue_reporter_service.dart';
import 'package:flutter_editor/ui/common/app_error_handler.dart';
import 'package:flutter_editor/ui/common/app_loader.dart';
import 'package:flutter_editor/ui/global/global_view.dart';
import 'package:flutter_editor/ui/left/left_tool_bar.dart';
import 'package:flutter_editor/state/view_mode_state.dart';
import 'package:flutter_editor/utils/file_io_web.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'constants/app_constants.dart';
import 'state/editor_state.dart';
import 'ui/canvas/canvas_toolbar.dart';
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
      IssueReporterService().reportError("An unhandled error occurred.", source: "runZonedGuarded", error: error, stackTrace: stackTrace);
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

// AppShell Top-level layout
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: Row(
        children: [
          // On the left is the dynamic toolbar
          LeftToolBar(),
          // On the right is the main content area
          Expanded(child: MainContentArea()),
        ],
      ),
    );
  }
}

// The main content area, which displays different views depending on the status
class MainContentArea extends ConsumerWidget {
  const MainContentArea({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentView = ref.watch(mainViewProvider);
    // Use the AnimatedSwitcher for smooth transitions
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: switch (currentView) {
        MainView.overview => const GlobalViewScaffold(key: ValueKey('Overview')),
        MainView.editor => const EditorScaffold(key: ValueKey('Editor')),
      },
    );
  }
}

// Create a container with an AppBar for GlobalView (overview page).
class GlobalViewScaffold extends ConsumerWidget {
  const GlobalViewScaffold({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Overview'),
        actions: [
          IconButton(icon: const Icon(Icons.save_alt_outlined), tooltip: 'Save Project', onPressed: () => saveProjectToFile(ref)),
          IconButton(icon: const Icon(Icons.file_upload_outlined), tooltip: 'Load Project', onPressed: () => loadProjectFromFile(ref)),
          const SizedBox(width: 16),
        ],
      ),
      body: const GlobalView(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(projectStateProvider.notifier).addPage();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Page'),
      ),
    );
  }
}

// EditorScaffold Editor.
class EditorScaffold extends ConsumerWidget {
  const EditorScaffold({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedNodeId = ref.watch(selectedNodeIdProvider);
    final isRightPanelVisible = selectedNodeId != null;

    return Row(
      children: [
        // The left panel, which is part of the editor
        SizedBox(width: kLeftPanelWidth, child: const LeftView()),
        const VerticalDivider(width: 1, thickness: 1),
        // Central area
        Expanded(
          child: Column(
            children: [
              const CanvasToolbar(),
              const Divider(height: 1, thickness: 1),
              Expanded(
                child: Row(
                  children: [
                    const Expanded(
                      child: CanvasView(),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Material(
                        elevation: 8.0,
                        child: Container(
                          width: isRightPanelVisible ? kRightPanelWidth : 0,
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1,
                              ),
                            ),
                          ),
                          child: ClipRect(
                            child: const RightView(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
