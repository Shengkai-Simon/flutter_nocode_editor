import 'package:flutter/material.dart';
import 'layout/editor_scaffold.dart';

class EditorApp extends StatelessWidget {
  const EditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: EditorScaffold(),
    );
  }
}