import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/editor_state.dart';
import '../core/widget_node.dart';

class LeftPanel extends ConsumerWidget {
  const LeftPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uuid = const Uuid();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Add Widget', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            final newNode = WidgetNode(
              id: uuid.v4(),
              type: 'Text',
              props: {
                'text': 'New Text',
                'fontSize': '16',
                'color': '#000000',
              },
              children: [],
            );

            final current = ref.read(canvasTreeProvider);
            final updated = current.copyWith(children: [...current.children, newNode]);
            ref.read(canvasTreeProvider.notifier).state = updated;
            ref.read(selectedNodeIdProvider.notifier).state = newNode.id;
          },
          child: const Text('Text'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            final newNode = WidgetNode(
              id: uuid.v4(),
              type: 'Container',
              props: {
                'width': '200',
                'height': '100',
                'backgroundColor': '#eeeeee',
              },
              children: [],
            );

            final current = ref.read(canvasTreeProvider);
            final updated = current.copyWith(children: [...current.children, newNode]);
            ref.read(canvasTreeProvider.notifier).state = updated;
            ref.read(selectedNodeIdProvider.notifier).state = newNode.id;
          },
          child: const Text('Container'),
        ),
      ],
    );
  }
}
