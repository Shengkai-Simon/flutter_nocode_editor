import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/components/core/widget_node.dart';
import '../../editor/components/core/component_registry.dart';
import '../../editor/components/core/widget_node_utils.dart';
import '../../editor/properties/core/property_definition.dart';
import '../../state/editor_state.dart';
import 'property_editor.dart';
import 'property_group_behaviors.dart';

class RightView extends ConsumerWidget {
  const RightView({super.key});

  /// A registry that maps a property category to its switchable behavior logic.
  static final Map<PropertyCategory, SwitchablePropertyGroup> _switchableGroupBehaviors = {
    PropertyCategory.background: BackgroundPropertyGroup(),
    PropertyCategory.border: BorderPropertyGroup(),
    PropertyCategory.shadow: ShadowPropertyGroup(),
  };

  // Helper function to get a displayable string name for a PropertyCategory
  String _getPropertyCategoryDisplayName(PropertyCategory category) {
    // (This function remains unchanged)
    switch (category) {
      case PropertyCategory.general:
        return 'General';
      case PropertyCategory.value:
        return 'Value';
      case PropertyCategory.dataSource:
        return 'Data Source';
      case PropertyCategory.sizing:
        return 'Sizing & Dimensions';
      case PropertyCategory.spacing:
        return 'Spacing & Indentation';
      case PropertyCategory.layout:
        return 'Layout & Alignment';
      case PropertyCategory.appearance:
        return 'Appearance';
      case PropertyCategory.textStyle:
        return 'Text Style';
      case PropertyCategory.background:
        return 'Background & Fill';
      case PropertyCategory.border:
        return 'Border & Corners';
      case PropertyCategory.shadow:
        return 'Shadow';
      case PropertyCategory.image:
        return 'Image Properties';
      case PropertyCategory.behavior:
        return 'Interaction & Behavior';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedNodeIdProvider);
    final tree = ref.watch(activeCanvasTreeProvider);
    final WidgetNode? node = findNodeById(tree, selectedId);
    final theme = Theme.of(context);

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

    // Editing: Component Name & Delete Button
    propertyWidgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Editing: ${rc.displayName}',
              style: theme.textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (node.id != tree.id)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Delete ${rc.displayName}',
              onPressed: () {
                final currentGlobalTree = ref.read(activeCanvasTreeProvider);
                if (currentGlobalTree.id == node.id) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Cannot delete the root canvas node.")));
                  return;
                }
                ref.read(selectedNodeIdProvider.notifier).state = null;
                final newTree = removeNodeById(currentGlobalTree, node.id);
                ref.read(projectStateProvider.notifier).updateActivePageTree(newTree);
              },
            ),
        ],
      ),
    );
    propertyWidgets.add(const Divider(height: 20));

    // Iterate through ordered categories to build UI sections
    for (var categoryEnumValue in kPropertyCategoryOrder) {
      if (categorizedFields.containsKey(categoryEnumValue) &&
          categorizedFields[categoryEnumValue]!.isNotEmpty) {

        bool isSwitchable = _switchableGroupBehaviors.containsKey(categoryEnumValue);
        bool isEffectivelyEnabled = true;

        if (isSwitchable) {
          isEffectivelyEnabled = _switchableGroupBehaviors[categoryEnumValue]!.isEffectivelyEnabled(node.props);
        }

        final titleWidget = Text(
          _getPropertyCategoryDisplayName(categoryEnumValue),
          style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary),
        );

        if (isSwitchable) {
          propertyWidgets.add(
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    titleWidget,
                    Switch(
                      value: isEffectivelyEnabled,
                      onChanged: (bool newState) {
                        final behavior = _switchableGroupBehaviors[categoryEnumValue]!;
                        Map<String, dynamic> newProps;
                        if (newState) {
                          newProps = behavior.getEnableDefaults(node.props);
                        } else {
                          newProps = behavior.getDisableDefaults(node.props);
                        }
                        final updatedNode = node.copyWith(props: newProps);
                        ref.read(projectStateProvider.notifier).updateWidgetNode(updatedNode);
                      },
                    ),
                  ],
                ),
              )
          );
        } else {
          propertyWidgets.add(
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
              child: titleWidget,
            ),
          );
        }

        if (isEffectivelyEnabled) {
          // Now we map each field to our new PropertyEditor widget.
          propertyWidgets.addAll(
            categorizedFields[categoryEnumValue]!.map((field) => PropertyEditor(
              key: ValueKey('${node.id}-${field.name}'),
              node: node,
              field: field,
            )),
          );
        }
        propertyWidgets.add(const SizedBox(height: 8));
      }
    }

    // This part for unordered categories remains the same
    final Set<PropertyCategory> orderedCategories = Set.from(kPropertyCategoryOrder);
    categorizedFields.forEach((categoryEnumValue, fieldsList) {
      if (!orderedCategories.contains(categoryEnumValue) && fieldsList.isNotEmpty) {
        propertyWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
            child: Text(
              "${_getPropertyCategoryDisplayName(categoryEnumValue)} (Unordered)",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
          ),
        );
        propertyWidgets.addAll(
          fieldsList.map((field) => PropertyEditor(
            key: ValueKey('${node.id}-${field.name}'),
            node: node,
            field: field,
          )),
        );
        propertyWidgets.add(const SizedBox(height: 8));
      }
    });


    return ListView(
      padding: const EdgeInsets.all(16),
      children: propertyWidgets,
    );
  }
}
