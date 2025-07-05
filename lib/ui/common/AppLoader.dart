import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';
import '../../state/editor_state.dart';

/// This widget is the new entry point of the application.
/// It decides which global UI to show based on the presence of a project ID
/// in the URL and the state of the API request.
class AppLoader extends ConsumerWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Directly read the project ID from the browser's URL at startup.
    final projectId = Uri.base.queryParameters['id'];

    // Case 1: No project ID in the URL.
    if (projectId == null || projectId.isEmpty) {
      return const InvalidIdScreen();
    }

    // Case 2: Project ID exists, watch the state of the data provider.
    final asyncProject = ref.watch(projectProvider(projectId));

    return asyncProject.when(
      loading: () => const LoadingScreen(),
      error:
          (err, stack) => ErrorScreen(
            errorMessage: err.toString(),
            onRetry: () => ref.invalidate(projectProvider(projectId)),
          ),
      data: (projectNode) {
        // Data successfully loaded, initialize the editor state.
        // We use a post-frame callback to ensure the state update doesn't
        // conflict with the current build cycle.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            ref
                .read(historyManagerProvider.notifier)
                .resetWithInitialState(projectNode);
          }
        });
        // Show the main editor UI.
        return const EditorScaffold();
      },
    );
  }
}

/// A screen shown when the project ID is missing from the URL.
class InvalidIdScreen extends StatelessWidget {
  const InvalidIdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link_off, color: Colors.orange, size: 60),
            SizedBox(height: 20),
            Text('Invalid project links', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text(
              'Please follow the correct link to the editor.',
              style: TextStyle(color: Colors.grey),
            ),
            // In a real app, this button might execute JavaScript
            // to close the window or navigate back.
            SizedBox(height: 30),
            // ElevatedButton(onPressed: () {}, child: const Text('back')),
          ],
        ),
      ),
    );
  }
}

/// A global loading screen.
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading project...', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

/// A global error screen with a retry button.
class ErrorScreen extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorScreen({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 20),
            const Text(
              'The project failed to load',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
