import 'package:flutter/material.dart';
import 'package:flutter_editor/ui/left/widget_tree_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../editor/components/core/widget_node.dart';
import '../../editor/components/core/component_registry.dart';
import '../../editor/components/core/component_definition.dart';
import '../../state/editor_state.dart';

class LeftView extends ConsumerWidget {
  const LeftView({super.key});

  // Helper to get a display name for the category
  String _getCategoryDisplayName(ComponentCategory category) {
    switch (category) {
      case ComponentCategory.layout:
        return 'Layout Widgets';
      case ComponentCategory.content:
        return 'Content & Display';
      case ComponentCategory.input:
        return 'Input & Controls';
      case ComponentCategory.other:
      return 'Other Widgets';
    }
  }

  Widget _buildAddComponentSection(BuildContext context, WidgetRef ref) {
    final uuid = const Uuid();
    final allComponents = registeredComponents.values.toList();

    final Map<ComponentCategory, List<RegisteredComponent>> categorizedComponents = {};
    for (var component in allComponents) {
      (categorizedComponents[component.category] ??= []).add(component);
    }

    final List<ComponentCategory> categoryOrder = [
      ComponentCategory.layout,
      ComponentCategory.content,
      ComponentCategory.input,
      ComponentCategory.other,
    ];

    List<Widget> sectionWidgets = [];

    for (var category in categoryOrder) {
      final componentsInCategory = categorizedComponents[category];
      if (componentsInCategory != null && componentsInCategory.isNotEmpty) {
        sectionWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 12.0, right: 12.0, bottom: 8.0),
            child: Text(
              _getCategoryDisplayName(category),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
          ),
        );

        sectionWidgets.add(
          GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: componentsInCategory.map((rc) {
              return GestureDetector(
                onTap: () {
                  final newComponentRc = registeredComponents[rc.type];
                  if (newComponentRc == null) return;

                  final newNode = WidgetNode(
                    id: uuid.v4(),
                    type: newComponentRc.type,
                    props: Map<String, dynamic>.from(newComponentRc.defaultProps),
                    children: [],
                  );

                  final selectedId = ref.read(selectedNodeIdProvider);
                  final currentTree = ref.read(canvasTreeProvider);

                  WidgetNode? targetParentNode;
                  RegisteredComponent? targetParentRc;

                  if (selectedId == null) {
                    targetParentNode = currentTree;
                    targetParentRc = registeredComponents[currentTree.type];
                  } else {
                    targetParentNode = _findNodeInTreeById(currentTree, selectedId);
                    if (targetParentNode != null) {
                      targetParentRc = registeredComponents[targetParentNode.type];
                    }
                  }

                  if (targetParentNode == null || targetParentRc == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Cannot add component: Target parent not found or is invalid.",
                        ),
                        backgroundColor: Colors.redAccent,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    return;
                  }

                  bool canAddChild = true;
                  String restrictionMessage = "";

                  switch (targetParentRc.childPolicy) {
                    case ChildAcceptancePolicy.none:
                      restrictionMessage = "'${targetParentRc.displayName}' cannot accept any children.";
                      canAddChild = false;
                      break;
                    case ChildAcceptancePolicy.single:
                      if (targetParentNode.children.isNotEmpty) {
                        restrictionMessage = "'${targetParentRc.displayName}' can only hold one child. "
                            "Please remove the existing child or select a different parent.";
                        canAddChild = false;
                      } else {
                        canAddChild = true;
                      }
                      break;
                    case ChildAcceptancePolicy.multiple:
                      canAddChild = true;
                      break;
                  }
                  if (!canAddChild) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(restrictionMessage),
                        backgroundColor: Colors.orangeAccent,
                      ),
                    );
                    return;
                  }

                  final newTree = _addChildToTree(currentTree, targetParentNode.id, newNode);

                  ref.read(canvasTreeProvider.notifier).state = newTree;
                  ref.read(selectedNodeIdProvider.notifier).state = newNode.id;
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).cardColor,
                    border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(rc.icon ?? Icons.extension, size: 24, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 4),
                      Text(
                        rc.displayName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }
    }

    if (sectionWidgets.isEmpty) {
      return const Center(child: Text("No components available."));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(12, 16, 12, 8),
          child: Text(
            'Components',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 12.0),
            children: sectionWidgets,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(leftPanelModeProvider);
    final modeNotifier = ref.read(leftPanelModeProvider.notifier);

    return Row(
      children: [
        Container(
          width: 56,
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              IconButton(
                icon: const Icon(Icons.add_box_outlined),
                tooltip: 'Add Widgets',
                isSelected: currentMode == LeftPanelMode.addWidgets,
                selectedIcon: const Icon(Icons.add_box),
                onPressed: () => modeNotifier.state = LeftPanelMode.addWidgets,
                color: currentMode == LeftPanelMode.addWidgets ? Theme.of(context).colorScheme.primary : null,
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: const Icon(Icons.account_tree_outlined),
                tooltip: 'Widget Tree',
                isSelected: currentMode == LeftPanelMode.widgetTree,
                selectedIcon: const Icon(Icons.account_tree),
                onPressed: () => modeNotifier.state = LeftPanelMode.widgetTree,
                color: currentMode == LeftPanelMode.widgetTree ? Theme.of(context).colorScheme.primary : null,
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: const Icon(Icons.layers_outlined),
                tooltip: 'Pages',
                isSelected: currentMode == LeftPanelMode.pages,
                selectedIcon: const Icon(Icons.layers),
                onPressed: () => modeNotifier.state = LeftPanelMode.pages,
                color: currentMode == LeftPanelMode.pages ? Theme.of(context).colorScheme.primary : null,
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: switch (currentMode) {
            LeftPanelMode.addWidgets => _buildAddComponentSection(context, ref),
            LeftPanelMode.widgetTree => const WidgetTreeView(),
            LeftPanelMode.pages      => const Center(child: Text("Page Management (Coming Soon!)")),
          },
        ),
      ],
    );
  }

  WidgetNode? _findNodeInTreeById(WidgetNode root, String id) {
    if (root.id == id) return root;
    for (final child in root.children) {
      final found = _findNodeInTreeById(child, id);
      if (found != null) return found;
    }
    return null;
  }

  WidgetNode _addChildToTree(WidgetNode root, String actualParentId, WidgetNode newChild) {
    if (root.id == actualParentId) {
      return root.copyWith(children: [...root.children, newChild]);
    }

    return root.copyWith(
      children: root.children.map((c) => _addChildToTree(c, actualParentId, newChild)).toList(),
    );
  }
}
