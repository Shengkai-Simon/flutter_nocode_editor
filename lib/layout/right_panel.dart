import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/component_registry.dart';
import '../core/editor_state.dart';
import '../core/widget_node.dart';
import '../traits/fields/color_picker_field.dart';
import '../traits/fields/dropdown_field.dart';
import '../traits/fields/edge_insets_field.dart';
import '../traits/fields/number_input_field.dart';
import '../traits/fields/switch_field.dart';
import '../traits/fields/text_input_field.dart';

class RightPanel extends ConsumerWidget {
  const RightPanel({super.key});

  WidgetNode _removeNodeById(WidgetNode root, String targetId) {
    if (root.id == targetId) {
      return root;
    }
    final newChildren = <WidgetNode>[];
    bool childRemoved = false;
    for (final child in root.children) {
      if (child.id == targetId) {
        childRemoved = true;
        continue; // Skip adding this child
      }
      newChildren.add(_removeNodeById(child, targetId));
    }
    if (childRemoved || newChildren.length != root.children.length) {
      return root.copyWith(children: newChildren);
    }
    return root;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedNodeIdProvider);
    final tree = ref.watch(canvasTreeProvider);
    final WidgetNode? node = _findNodeById(tree, selectedId);

    if (node == null) {
      return const Center(child: Text("Select a widget to edit its properties."));
    }

    final rc = registeredComponents[node.type];
    if (rc == null) {
      return Center(child: Text("Unknown component type: ${node.type}"));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Editing: ${rc.displayName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (node.id != tree.id)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete',
                onPressed: () {
                  final currentTree = ref.read(canvasTreeProvider);
                  if (currentTree.id == node.id) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Cannot delete the root canvas node."))
                    );
                    return;
                  }
                  final newTree = _removeNodeById(currentTree, node.id);

                  ref.read(canvasTreeProvider.notifier).state = newTree;
                  ref.read(selectedNodeIdProvider.notifier).state = null;
                },
              ),
          ],
        ),
        const Divider(),
        const SizedBox(height: 16),
        ...rc.propFields.map((field) {
          final dynamic rawPropValue = node.props[field.name];
          final dynamic currentValueForEditor = rawPropValue ?? field.defaultValue;

          onChanged(dynamic newValueFromField) {
            final Map<String, dynamic> updatedProps = Map<String, dynamic>.from(node.props);
            dynamic processedValue = newValueFromField;
            if (newValueFromField == null && field.defaultValue == null) {
              updatedProps.remove(field.name);
            } else {
              updatedProps[field.name] = processedValue;
            }

            final updatedNode = node.copyWith(props: updatedProps);
            final currentGlobalTree = ref.read(canvasTreeProvider);
            final newGlobalTree = _replaceNodeInTree(currentGlobalTree, updatedNode);
            ref.read(canvasTreeProvider.notifier).state = newGlobalTree;
          }

          if (field.editorBuilder != null) {
            return field.editorBuilder!(
              context,
              field,
              currentValueForEditor,
              onChanged,
            );
          } else {
            print("Warning: No editorBuilder defined for property '${field.name}' of type '${field.fieldType}' in component '${rc.displayName}'.");
            return ListTile(
              title: Text(field.label),
              subtitle: Text(currentValueForEditor?.toString() ?? 'N/A (No editor)'),
            );
          }
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

  WidgetNode _replaceNodeInTree(WidgetNode root, WidgetNode updated) {
    if (root.id == updated.id) return updated;
    return root.copyWith(
      children: root.children.map((c) => _replaceNodeInTree(c, updated)).toList(),
    );
  }
}