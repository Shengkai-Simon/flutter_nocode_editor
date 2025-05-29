import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/components/core/widget_node.dart';
import '../../editor/components/core/component_registry.dart';
import '../../editor/properties/core/property_definition.dart';
import '../../state/editor_state.dart';

class RightView extends ConsumerWidget {
  const RightView({super.key});

  // Helper function to get a displayable string name for a PropertyCategory
  String _getPropertyCategoryDisplayName(PropertyCategory category) {
    switch (category) {
      case PropertyCategory.general: return 'General';
      case PropertyCategory.sizing: return 'Sizing';
      case PropertyCategory.spacing: return 'Spacing';
      case PropertyCategory.layout: return 'Layout';
      case PropertyCategory.flexLayout: return 'Flex Layout';
      case PropertyCategory.appearance: return 'Appearance';
      case PropertyCategory.fill: return 'Fill & Background';
      case PropertyCategory.border: return 'Border';
      case PropertyCategory.shadow: return 'Shadow';
      case PropertyCategory.gradient: return 'Gradient';
      case PropertyCategory.textStyle: return 'Text Style';
      case PropertyCategory.imageSource: return 'Image Source';
      case PropertyCategory.imageAppearance: return 'Image Appearance';
      case PropertyCategory.behavior: return 'Behavior';
      case PropertyCategory.value: return 'Value';
      case PropertyCategory.data: return 'Data';
    }
  }

  WidgetNode _removeNodeById(WidgetNode root, String targetId) {
    if (root.id == targetId) {
      return root;
    }
    final newChildren = <WidgetNode>[];
    bool childRemoved = false;
    for (final child in root.children) {
      if (child.id == targetId) {
        childRemoved = true;
        continue;
      }
      newChildren.add(_removeNodeById(child, targetId));
    }

    if (childRemoved) {
      return root.copyWith(children: newChildren);
    }

    bool childrenInstancesChanged = false;
    if (newChildren.length == root.children.length) {
      for (int i = 0; i < newChildren.length; i++) {
        if (!identical(newChildren[i], root.children[i])) {
          childrenInstancesChanged = true;
          break;
        }
      }
    }

    if (childrenInstancesChanged) {
      return root.copyWith(children: newChildren);
    }

    return root;
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

    final Map<PropertyCategory, List<PropField>> categorizedFields = {};

    for (var field in rc.propFields) {
      final category = field.propertyCategory;
      (categorizedFields[category] ??= []).add(field);
    }

    List<Widget> propertyWidgets = [];

    propertyWidgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Editing: ${rc.displayName}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (node.id != tree.id)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: 'Delete ${rc.displayName}',
                onPressed: () {
                  final currentGlobalTree = ref.read(canvasTreeProvider);
                  if (currentGlobalTree.id == node.id) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Cannot delete the root canvas node."))
                    );
                    return;
                  }
                  final newTree = _removeNodeById(currentGlobalTree, node.id);
                  ref.read(canvasTreeProvider.notifier).state = newTree;
                  ref.read(selectedNodeIdProvider.notifier).state = null;
                },
              ),
          ],
        )
    );
    propertyWidgets.add(const Divider(height: 20));

    List<Widget> buildFieldWidgets(List<PropField> fields) {
      return fields.map((field) {
        final dynamic rawPropValue = node.props[field.name];
        final dynamic currentValueForEditor = rawPropValue ?? field.defaultValue;

        onChanged(dynamic newValueFromField) {
          final Map<String, dynamic> updatedProps = Map<String, dynamic>.from(node.props);
          updatedProps[field.name] = newValueFromField;

          final updatedNode = node.copyWith(props: updatedProps);
          final currentGlobalTree = ref.read(canvasTreeProvider);
          final newGlobalTree = _replaceNodeInTree(currentGlobalTree, updatedNode);
          ref.read(canvasTreeProvider.notifier).state = newGlobalTree;
        }

        if (field.editorBuilder != null) {
          return field.editorBuilder!(
            context,
            node.props,
            field,
            currentValueForEditor,
            onChanged,
          );
        } else {
          print("Warning: No editorBuilder for property '${field.name}' in '${rc.displayName}'.");
          return ListTile(
            title: Text(field.label),
            subtitle: Text(currentValueForEditor?.toString() ?? 'N/A (No editor)'),
          );
        }
      }).toList();
    }

    for (var categoryEnumValue in kPropertyCategoryOrder) {
      if (categorizedFields.containsKey(categoryEnumValue) && categorizedFields[categoryEnumValue]!.isNotEmpty) {
        propertyWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
            child: Text(
              _getPropertyCategoryDisplayName(categoryEnumValue),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
            ),
          ),
        );
        propertyWidgets.addAll(buildFieldWidgets(categorizedFields[categoryEnumValue]!));
        propertyWidgets.add(const SizedBox(height: 8));
      }
    }

    final Set<PropertyCategory> orderedCategories = Set.from(kPropertyCategoryOrder);
    categorizedFields.forEach((categoryEnumValue, fieldsList) {
      if (!orderedCategories.contains(categoryEnumValue) && fieldsList.isNotEmpty) {
        propertyWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
            child: Text(
              _getPropertyCategoryDisplayName(categoryEnumValue),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
          ),
        );
        propertyWidgets.addAll(buildFieldWidgets(fieldsList));
        propertyWidgets.add(const SizedBox(height: 8));
      }
    });


    return ListView(
      padding: const EdgeInsets.all(16),
      children: propertyWidgets,
    );
  }
}