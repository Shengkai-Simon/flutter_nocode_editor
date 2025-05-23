import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/editor_state.dart';
import '../core/widget_node.dart';

class RightPanel extends ConsumerWidget {
  const RightPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedNodeIdProvider);
    final tree = ref.watch(canvasTreeProvider);
    final node = _findNodeById(tree, selectedId);

    if (node == null) {
      return const Center(child: Text("Select a widget to edit its properties."));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Editing: ${node.type}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...node.props.entries.map((entry) {
          return _buildPropField(
            context,
            ref,
            node,
            entry.key,
            entry.value?.toString() ?? '',
          );
        }),
      ],
    );
  }

  WidgetNode? _findNodeById(WidgetNode root, String? id) {
    if (id == null) return null;
    if (root.id == id) return root;
    for (final child in root.children) {
      final result = _findNodeById(child, id);
      if (result != null) return result;
    }
    return null;
  }

  Widget _buildPropField(
      BuildContext context,
      WidgetRef ref,
      WidgetNode node,
      String propKey,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(labelText: propKey),
        onChanged: (newVal) {
          final updatedProps = {...node.props, propKey: newVal};
          final updatedNode = node.copyWith(props: updatedProps);
          final tree = ref.read(canvasTreeProvider);
          final newTree = _replaceNodeInTree(tree, updatedNode);
          ref.read(canvasTreeProvider.notifier).state = newTree;
        },
      ),
    );
  }

  WidgetNode _replaceNodeInTree(WidgetNode root, WidgetNode updated) {
    if (root.id == updated.id) return updated;
    return root.copyWith(
      children: root.children.map((c) => _replaceNodeInTree(c, updated)).toList(),
    );
  }
}
