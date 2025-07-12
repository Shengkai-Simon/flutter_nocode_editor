import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define a Provider to manage the state of the main view
final mainViewProvider = StateProvider<MainView>((ref) => MainView.overview);

// Define the type of main view
enum MainView {
  overview,
  editor,
}

class GlobalNavRail extends ConsumerWidget {
  const GlobalNavRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the mainViewProvider to determine which icon is active
    final currentView = ref.watch(mainViewProvider);
    final viewNotifier = ref.read(mainViewProvider.notifier);

    return Container(
      width: 56,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          // Project Overview navigation button
          IconButton(
            icon: const Icon(Icons.dashboard_outlined),
            tooltip: 'Project Overview',
            isSelected: currentView == MainView.overview,
            selectedIcon: const Icon(Icons.dashboard),
            onPressed: () {
              viewNotifier.state = MainView.overview;
            },
          ),
          const SizedBox(height: 8),
          // Page Editor navigation button
          IconButton(
            icon: const Icon(Icons.edit_document),
            tooltip: 'Page Editor',
            isSelected: currentView == MainView.editor,
            selectedIcon: const Icon(Icons.edit_document),
            onPressed: () {
              viewNotifier.state = MainView.editor;
            },
          ),
        ],
      ),
    );
  }
}