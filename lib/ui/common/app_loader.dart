import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:js_interop';

import '../../main.dart';
import '../../providers/communication_providers.dart';
import '../../providers/project_providers.dart';
import '../../services/project_api_service.dart';
import '../../state/editor_state.dart';

// Define the type required to interact with the browser's window.location API
@JS('window')
@staticInterop
class Window {}

extension WindowExtension on Window {
  external Location get location;
}

@JS()
@staticInterop
class Location {}

extension LocationExtension on Location {
  external set href(JSString href);
}

// Define a top-level getter to access the global 'window' object
@JS('window')
external Window get window;

/// This widget is the new entry point of the application.
/// It decides which global UI to show based on the presence of a project ID
/// in the URL and the state of the API request.
class AppLoader extends ConsumerWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // As soon as the provider is listened to, it will be activated and start processing messages
    ref.watch(iframeMessageCoordinatorProvider);

    final communicationService = ref.watch(iframeCommunicationServiceProvider);
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
      error: (err, stack) {
        if (err is SessionExpiredException) {
          return RedirectingScreen(message: err.toString());
        } else {
          return ErrorScreen(
            errorMessage: err.toString(),
            onRetry: () => ref.invalidate(projectProvider(projectId)),
          );
        }
      },
      data: (projectNode) {
        // Data successfully loaded, initialize the editor state.
        // We use a post-frame callback to ensure the state update doesn't
        // conflict with the current build cycle.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            ref
                .read(historyManagerProvider.notifier)
                .resetWithInitialState(projectNode);

            // After the data is successfully loaded and the state is initialized, a "flutterReady" message is sent
            communicationService.sendFlutterReady();
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.link_off, color: Colors.orange, size: 60),
            const SizedBox(height: 20),
            const Text('Invalid project links', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            const Text(
              'Please follow the correct link to the editor.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),

            ElevatedButton.icon(
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Return to the main app'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () {
                // Call JS Interop to change the browser URL
                window.location.href = '/react'.toJS;
              },
            ),
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

/// A screen shown when the session has expired, which then redirects
/// the user back to the main React application.
class RedirectingScreen extends StatefulWidget {
  final String message;
  const RedirectingScreen({super.key, required this.message});

  @override
  State<RedirectingScreen> createState() => _RedirectingScreenState();
}

class _RedirectingScreenState extends State<RedirectingScreen> {
  @override
  void initState() {
    super.initState();
    // After the interface is built, there is a short delay and then the jump is performed
    // This ensures that the user sees the prompt
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        window.location.href = '/react'.toJS;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(widget.message, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            const Text('You will be redirected to the login page after 3 seconds...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
