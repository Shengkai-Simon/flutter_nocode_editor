import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/component_registry.dart';
import '../core/editor_state.dart';
import '../core/widget_node.dart';
import '../traits/fields/color_picker_field.dart';
import '../traits/fields/dropdown_field.dart';
import '../traits/fields/edge_insets_field.dart';
import '../traits/fields/number_input_field.dart';
import '../traits/fields/text_input_field.dart';

class RightPanel extends ConsumerWidget {
  const RightPanel({super.key});

  WidgetNode _removeNodeById(WidgetNode root, String targetId) {
    if (root.id == targetId) {
      return root;
    }
    final newChildren = <WidgetNode>[];
    for (final child in root.children) {
      if (child.id == targetId) {
        continue;
      }
      newChildren.add(_removeNodeById(child, targetId));
    }
    return root.copyWith(children: newChildren);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedNodeIdProvider);
    final tree = ref.watch(canvasTreeProvider);
    final node = _findNodeById(tree, selectedId);

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
                  final newTree = _removeNodeById(currentTree, node.id);

                  ref.read(canvasTreeProvider.notifier).state = newTree;
                  ref.read(selectedNodeIdProvider.notifier).state = null; // De-select after deleting
                },
              ),
          ],
        ),
        const Divider(),
        const SizedBox(height: 16),
        ...rc.propFields.map((field) {
          final value = node.props[field.name]?.toString() ?? field.defaultValue?.toString() ?? '';

          print('field.fieldType: ${field.fieldType}, Field Name: ${field.name}, Value: $value');

          onChanged(String newVal) {
            final updatedProps = {...node.props, field.name: newVal};
            final updatedNode = node.copyWith(props: updatedProps);
            final currentGlobalTree = ref.read(canvasTreeProvider);
            final newGlobalTree = _replaceNodeInTree(currentGlobalTree, updatedNode); // Assuming _replaceNodeInTree is correct
            ref.read(canvasTreeProvider.notifier).state = newGlobalTree;
          }

          switch (field.fieldType) {
            case FieldType.string:
              return TextInputField(label: field.label, value: value, onChanged: onChanged);
            case FieldType.number:
              return NumberInputField(label: field.label, value: value, onChanged: onChanged);
            case FieldType.color:
              return ColorPickerField(label: field.label, value: value, onChanged: onChanged);
            case FieldType.select:
              return DropdownField(
                label: field.label,
                value: value,
                options: field.options ?? [],
                onChanged: onChanged,
              );
            case FieldType.boolean:
              return SwitchListTile(
                title: Text(field.label),
                value: value == 'true',
                onChanged: (bool checked) => onChanged(checked.toString()),
              );
            case FieldType.alignment:
              return DropdownField(
                label: field.label,
                value: value,
                options: field.options ?? [],
                onChanged: onChanged,
              );
            case FieldType.edgeInsets:
              return EdgeInsetsField(
                label: field.label,
                value: value,
                onChanged: onChanged,
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