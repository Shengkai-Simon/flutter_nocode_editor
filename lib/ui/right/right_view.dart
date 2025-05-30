import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/components/core/widget_node.dart';
import '../../editor/components/core/component_registry.dart';
import '../../editor/properties/core/property_definition.dart';
import '../../state/editor_state.dart';
import '../../utils/parsing_util.dart';

class RightView extends ConsumerWidget {
  const RightView({super.key});

  static const Set<PropertyCategory> _switchableCategories = {
    PropertyCategory.background,
    PropertyCategory.border,
    PropertyCategory.shadow,
  };

  bool _isPropertyGroupEffectivelyEnabled(
      PropertyCategory category,
      Map<String, dynamic> props,
      ) {
    switch (category) {
      case PropertyCategory.background:
        final String? bgColor = props['backgroundColor'] as String?;
        final bool hasBgColor = bgColor != null && bgColor.isNotEmpty && ParsingUtil.parseColor(bgColor).alpha != 0;
        final String? gradientType = props['gradientType'] as String?;
        final bool hasGradient = gradientType != null && gradientType != 'none';
        return hasBgColor || hasGradient;
      case PropertyCategory.border:
        return (props['borderWidth'] as num? ?? 0) > 0;
      case PropertyCategory.shadow:
        final String? shadowColor = props['shadowColor'] as String?;
        return shadowColor != null && shadowColor.isNotEmpty && ParsingUtil.parseColor(shadowColor).alpha != 0;
      default:
        return true;
    }
  }

  Map<String, dynamic> _applyDefaultsForEnabledGroup(
      PropertyCategory category,
      Map<String, dynamic> currentProps,
      ) {
    final newProps = Map<String, dynamic>.from(currentProps);

    switch (category) {
      case PropertyCategory.background:
        if (!_isPropertyGroupEffectivelyEnabled(PropertyCategory.background, newProps)) {
          newProps['backgroundColor'] = '#FFF0F0F0';
          newProps['gradientType'] = 'none';
        } else {
          if (newProps['backgroundColor'] == null && (newProps['gradientType'] == null || newProps['gradientType'] == 'none')) {
            newProps['backgroundColor'] = '#FFF0F0F0';
          }
        }
        break;
      case PropertyCategory.border:
        if (!_isPropertyGroupEffectivelyEnabled(PropertyCategory.border, newProps)) {
          newProps['borderWidth'] = 1.0;
          newProps['borderColor'] = '#FF000000';
        } else {
          if ((newProps['borderWidth'] as num? ?? 0) <= 0) {
            newProps['borderWidth'] = 1.0;
          }
          newProps['borderColor'] ??= '#FF000000';
        }
        break;
      case PropertyCategory.shadow:
        if (!_isPropertyGroupEffectivelyEnabled(PropertyCategory.shadow, newProps)) {
          newProps['shadowColor'] = '#8A000000';
          newProps['shadowOffsetX'] ??= 0.0;
          newProps['shadowOffsetY'] ??= 2.0;
          newProps['shadowBlurRadius'] ??= 4.0;
          newProps['shadowSpreadRadius'] ??= 0.0;
        } else {
          newProps['shadowColor'] ??= '#8A000000';
        }
        break;
      default:
        break;
    }
    return newProps;
  }

  Map<String, dynamic> _applyDefaultsForDisabledGroup(
      PropertyCategory category,
      Map<String, dynamic> currentProps,
      ) {
    final newProps = Map<String, dynamic>.from(currentProps);
    switch (category) {
      case PropertyCategory.background:
        newProps['backgroundColor'] = null;
        newProps['gradientType'] = 'none';
        newProps.remove('gradientColor1');
        newProps.remove('gradientColor2');
        newProps.remove('gradientBeginAlignment');
        newProps.remove('gradientEndAlignment');
        break;
      case PropertyCategory.border:
        newProps['borderWidth'] = 0.0;
        break;
      case PropertyCategory.shadow:
        newProps['shadowColor'] = null;
        break;
      default:
        break;
    }
    return newProps;
  }

  // Helper function to get a displayable string name for a PropertyCategory
  String _getPropertyCategoryDisplayName(PropertyCategory category) {
    switch (category) {
    // Core Attributes
      case PropertyCategory.general:
        return 'General'; // e.g., Text content, Button text, Radio item value
      case PropertyCategory.value:
        return 'Value'; // e.g., Switch state, Slider position, TextField input
      case PropertyCategory.dataSource:
        return 'Data Source'; // e.g., Dropdown items

    // Layout & Sizing
      case PropertyCategory.sizing:
        return 'Sizing & Dimensions'; // e.g., Width, Height, Flex factor
      case PropertyCategory.spacing:
        return 'Spacing & Indentation'; // e.g., Margin, Padding, Divider indents
      case PropertyCategory.layout:
        return 'Layout & Alignment'; // e.g., Child alignment, Row/Column axis controls, Wrap properties

    // Visual Styling
      case PropertyCategory.appearance:
        return 'Appearance'; // e.g., Icon choice, active/inactive colors, elevation, clip behavior
      case PropertyCategory.textStyle:
        return 'Text Style'; // e.g., Font properties, text alignment
      case PropertyCategory.background: // Merged 'fill' and 'gradient'
        return 'Background & Fill'; // e.g., Background color, gradients
      case PropertyCategory.border:
        return 'Border & Corners'; // e.g., Border properties, corner radius
      case PropertyCategory.shadow:
        return 'Shadow'; // e.g., Box shadows, elevation shadows

    // Specific Component Types
      case PropertyCategory.image: // Merged 'imageSource' and 'imageAppearance'
        return 'Image Properties'; // e.g., Image source, fit, repeat

    // Behavior & Interaction
      case PropertyCategory.behavior:
        return 'Interaction & Behavior'; // Returns 'myCategory' from 'PropertyCategory.myCategory'
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

    // Editing: Component Name & Delete Button
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
                      const SnackBar(content: Text("Cannot delete the root canvas node.")));
                  return;
                }
                ref.read(selectedNodeIdProvider.notifier).state = null;
                final newTree = _removeNodeById(currentGlobalTree, node.id);
                ref.read(canvasTreeProvider.notifier).state = newTree;

              },
            ),
        ],
      ),
    );
    propertyWidgets.add(const Divider(height: 20));

    // Function to build property fields for a category
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

    // Iterate through ordered categories to build UI sections
    for (var categoryEnumValue in kPropertyCategoryOrder) {
      if (categorizedFields.containsKey(categoryEnumValue) &&
          categorizedFields[categoryEnumValue]!.isNotEmpty) {

        bool isSwitchable = _switchableCategories.contains(categoryEnumValue);
        bool isEffectivelyEnabled = true;

        if (isSwitchable) {
          isEffectivelyEnabled = _isPropertyGroupEffectivelyEnabled(
            categoryEnumValue,
            node.props,
          );
        }

        // Title Section (with Switch for switchable categories)
        final titleWidget = Text(
          _getPropertyCategoryDisplayName(categoryEnumValue),
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary),
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
                        Map<String, dynamic> newProps;
                        if (newState) {
                          newProps = _applyDefaultsForEnabledGroup(
                            categoryEnumValue,
                            node.props,
                          );
                        } else {
                          newProps = _applyDefaultsForDisabledGroup(
                            categoryEnumValue,
                            node.props,
                          );
                        }
                        final updatedNode = node.copyWith(props: newProps);
                        final currentGlobalTree = ref.read(canvasTreeProvider);
                        final newGlobalTree = _replaceNodeInTree(currentGlobalTree, updatedNode);
                        ref.read(canvasTreeProvider.notifier).state = newGlobalTree;
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
          propertyWidgets.addAll(buildFieldWidgets(categorizedFields[categoryEnumValue]!));
        }
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
              "${_getPropertyCategoryDisplayName(categoryEnumValue)} (Unordered)",
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