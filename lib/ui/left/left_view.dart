import 'package:flutter/material.dart';
import 'package:flutter_editor/ui/left/widget_tree_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../editor/components/core/component_model.dart';
import '../../editor/components/core/component_registry.dart';
import '../../editor/properties/core/property_meta.dart';
import '../../state/editor_state.dart';

class LeftView extends ConsumerWidget {
  const LeftView({super.key});

  Widget _buildAddComponentSection(BuildContext context, WidgetRef ref) {
    final uuid = const Uuid();
    final componentList = registeredComponents.values.toList();

    void addComponent(String newComponentType) {
      final newComponentRc = registeredComponents[newComponentType];
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

      bool canAddChild = false;
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
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      final newTree = _addChildToTree(currentTree, targetParentNode.id, newNode);

      ref.read(canvasTreeProvider.notifier).state = newTree;
      ref.read(selectedNodeIdProvider.notifier).state = newNode.id;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Components',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            padding: const EdgeInsets.all(12),
            children: componentList.map((rc) {
              return GestureDetector(
                onTap: () => addComponent(rc.type),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(rc.icon ?? Icons.extension, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              rc.displayName,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWidgetTreeViewSection(BuildContext context, WidgetRef ref) {
    return const WidgetTreeView();
  }

  Widget _buildPagesViewSection(BuildContext context, WidgetRef ref) {
    return const Center(child: Text("Page Management (Coming Soon!)"));
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
        // Content Area
        Expanded(
          child: switch (currentMode) {
            LeftPanelMode.addWidgets => _buildAddComponentSection(context, ref),
            LeftPanelMode.widgetTree => _buildWidgetTreeViewSection(context, ref),
            LeftPanelMode.pages      => _buildPagesViewSection(context, ref),
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
