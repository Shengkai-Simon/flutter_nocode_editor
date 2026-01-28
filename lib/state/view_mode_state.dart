import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_editor/state/editor_state.dart';

// This provider is now derived from the main project state.
// It reflects the `view` property of the current ProjectState.
final mainViewProvider = Provider<MainView>((ref) {
  return ref.watch(projectStateProvider.select((s) => s.view));
});

// Define the type of main view: Project Overview or Page Editor
enum MainView {
  overview,
  editor,
}
