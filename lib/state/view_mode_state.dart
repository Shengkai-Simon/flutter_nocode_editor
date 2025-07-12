import 'package:flutter_riverpod/flutter_riverpod.dart';

// This provider is at the heart of the entire application view switch
final mainViewProvider = StateProvider<MainView>((ref) => MainView.overview);

// Define the type of main view: Project Overview or Page Editor
enum MainView {
  overview,
  editor,
}