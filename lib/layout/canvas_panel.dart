import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/editor_state.dart';
import '../renderer/widget_renderer.dart';
import 'canvas_toolbar.dart';

class CanvasPanel extends ConsumerWidget {
  const CanvasPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tree = ref.watch(canvasTreeProvider);

    return Column(
      children: [
        const CanvasToolbar(),
        Expanded(
          child: Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.all(16),
            alignment: Alignment.topLeft,
            child: WidgetRenderer(node: tree),
          ),
        ),
      ],
    );
  }
}
