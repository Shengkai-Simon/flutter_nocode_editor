import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/editor_state.dart';
import 'canvas_toolbar.dart';
import 'widget_renderer.dart';

class CanvasView extends ConsumerWidget {
  const CanvasView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tree = ref.watch(canvasTreeProvider);

    return Column(
      children: [
        const CanvasToolbar(),
        Expanded(
          child: GestureDetector(
            onTap: () {
              // When click on an empty area of the canvas, all selected and hover states are deselected
              ref.read(selectedNodeIdProvider.notifier).state = null;
              ref.read(hoveredNodeIdProvider.notifier).state = null;
            },
            child: Container(
              color: Colors.grey[200],
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(16),
              alignment: Alignment.topLeft,
              child: WidgetRenderer(node: tree),
            ),
          ),
        ),
      ],
    );
  }
}