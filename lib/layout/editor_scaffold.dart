import 'package:flutter/material.dart';
import 'left_panel.dart';
import 'canvas_panel.dart';
import 'right_panel.dart';

class EditorScaffold extends StatelessWidget {
  const EditorScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 250,
          child: LeftPanel(),
        ),
        const Expanded(
          child: CanvasPanel(),
        ),
        const SizedBox(
          width: 300,
          child: RightPanel(),
        ),
      ],
    );
  }
}