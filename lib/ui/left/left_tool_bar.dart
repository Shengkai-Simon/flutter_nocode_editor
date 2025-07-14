import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/editor_state.dart';
import '../../state/view_mode_state.dart';

class LeftToolBar extends ConsumerWidget {
  const LeftToolBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentView = ref.watch(mainViewProvider);
    final viewNotifier = ref.read(mainViewProvider.notifier);
    final leftPanelNotifier = ref.read(leftPanelModeProvider.notifier);
    final currentLeftPanel = ref.watch(leftPanelModeProvider);

    // Depending on whether or not you are in editor mode, decide whether to enable editor-related buttons
    final bool inEditorMode = currentView == MainView.editor;

    return Container(
      width: 56,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          // Project Overview button
          IconButton(
            icon: const Icon(Icons.dashboard_outlined),
            tooltip: 'Project Overview',
            isSelected: currentView == MainView.overview,
            selectedIcon: const Icon(Icons.dashboard),
            onPressed: () => viewNotifier.state = MainView.overview,
          ),
          const Divider(indent: 12, endIndent: 12, height: 1),
          const SizedBox(height: 8),
          // Here are the buttons that are only enabled in editor mode
          // Add Component button
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Add Widgets',
            isSelected: inEditorMode && currentLeftPanel == LeftPanelMode.addWidgets,
            selectedIcon: const Icon(Icons.add_box),
            // If not in editor mode, the button will be disabled (onPressed: null)
            onPressed: inEditorMode ? () {
              viewNotifier.state = MainView.editor;
              leftPanelNotifier.state = LeftPanelMode.addWidgets;
            } : null,
          ),
          const SizedBox(height: 8),
          // Component Tree button
          IconButton(
            icon: const Icon(Icons.account_tree_outlined),
            tooltip: 'Widget Tree',
            isSelected: inEditorMode && currentLeftPanel == LeftPanelMode.widgetTree,
            selectedIcon: const Icon(Icons.account_tree),
            onPressed: inEditorMode ? () {
              viewNotifier.state = MainView.editor;
              leftPanelNotifier.state = LeftPanelMode.widgetTree;
            } : null,
          ),
          const SizedBox(height: 8),
          // Page Management button
          IconButton(
            icon: const Icon(Icons.layers_outlined),
            tooltip: 'Pages',
            isSelected: inEditorMode && currentLeftPanel == LeftPanelMode.pages,
            selectedIcon: const Icon(Icons.layers),
            onPressed: inEditorMode ? () {
              viewNotifier.state = MainView.editor;
              leftPanelNotifier.state = LeftPanelMode.pages;
            } : null,
          ),
        ],
      ),
    );
  }
}