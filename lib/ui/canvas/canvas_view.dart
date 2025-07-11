import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/editor_state.dart';
import 'widget_renderer.dart';
import 'canvas_toolbar.dart';

class CanvasView extends ConsumerWidget {
  const CanvasView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tree = ref.watch(activeCanvasTreeProvider);

    return Column(
      children: [
        const CanvasToolbar(),
        Expanded(
          child: GestureDetector(
            onTap: () {
              ref.read(selectedNodeIdProvider.notifier).state = null;
              ref.read(hoveredNodeIdProvider.notifier).state = null;
            },
            child: Container(
              color: Theme.of(context).canvasColor,
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: WidgetRenderer(node: tree),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
