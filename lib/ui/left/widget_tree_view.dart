import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/components/core/widget_node.dart';
import '../../editor/components/core/component_registry.dart';
import '../../editor/components/core/component_definition.dart';
import '../../state/editor_state.dart';
import '../../editor/components/core/widget_node_utils.dart';
import '../../constants/app_constants.dart';

class WidgetTreeView extends ConsumerWidget {
  const WidgetTreeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WidgetNode rootNode = ref.watch(canvasTreeProvider);
    final String? selectedNodeId = ref.watch(selectedNodeIdProvider);
    final selectedNodeNotifier = ref.read(selectedNodeIdProvider.notifier);
    final String? currentHoveredId = ref.watch(hoveredNodeIdProvider);

    List<Widget> buildTreeNodes(WidgetNode node, int depth, WidgetNode currentRootForChecks) {
      List<Widget> widgets = [];

      final RegisteredComponent? rc = registeredComponents[node.type];
      final String displayName = rc?.displayName ?? node.type;
      final IconData iconData = rc?.icon ?? Icons.device_unknown;

      final bool isActuallySelected = node.id == selectedNodeId;
      final bool isNodeGloballyHovered = node.id == currentHoveredId;
      final bool showHoverEffectInTreeItem = isNodeGloballyHovered && !isActuallySelected;

      final Color selectedColor = Theme.of(context).colorScheme.primary;
      final Color hoverEffectColor = kRendererHoverBorderColor;

      Widget treeItemContent = ListTile(
        dense: true,
        leading: Icon(
          iconData,
          size: 20,
          color: isActuallySelected
              ? selectedColor
              : (showHoverEffectInTreeItem ? hoverEffectColor : Theme.of(context).textTheme.bodySmall?.color),
        ),
        title: Text(
          displayName,
          style: TextStyle(
            fontWeight: isActuallySelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
            color: isActuallySelected
                ? selectedColor
                : (showHoverEffectInTreeItem ? hoverEffectColor : Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ),
        selected: isActuallySelected,
        onTap: () {
          if (node.id != rootNode.id) {
            selectedNodeNotifier.state = node.id;
          } else {
            selectedNodeNotifier.state = null;
          }
          ref.read(hoveredNodeIdProvider.notifier).state = null;
        },
      );

      bool canBeDragged = node.id != rootNode.id && rc != null;
      Widget finalInteractiveItem = canBeDragged
          ? LongPressDraggable<String>(
        data: node.id,
        feedback: Material(
          elevation: 4.0,
          color: Colors.transparent,
          child: Opacity(
            opacity: 0.8,
            child: Container(
              padding: EdgeInsets.only(left: depth * 1.0),
              width: MediaQuery.of(context).size.width * 0.25,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListTile(dense: true, leading: Icon(iconData, size:20), title: Text(displayName, style: const TextStyle(fontSize: 13))),
            ),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.4, child: treeItemContent),
        child: treeItemContent,
      )
          : treeItemContent;

      Widget dragTargetVisualBuilder(BuildContext context, List<String?> candidateDragData, List<dynamic> rejectedDragData) {
        bool isAnotherNodeDraggingOverThis = candidateDragData.isNotEmpty && candidateDragData.first != node.id;
        bool canThisNodeAcceptDraggedNode = false;

        if (isAnotherNodeDraggingOverThis && rc != null && rc.childPolicy != ChildAcceptancePolicy.none) {
          final String? draggedNodeIdFromCandidate = candidateDragData.first;
          if (draggedNodeIdFromCandidate != null) {
            if (!isAncestor(currentRootForChecks, draggedNodeIdFromCandidate, node.id)) {
              if (rc.childPolicy == ChildAcceptancePolicy.single && node.children.isNotEmpty) {
                canThisNodeAcceptDraggedNode = false;
              } else {
                canThisNodeAcceptDraggedNode = true;
              }
            }
          }
        }

        Color? resolvedItemBackgroundColor;
        Border? resolvedItemBorder;

        if (isAnotherNodeDraggingOverThis) {
          if (canThisNodeAcceptDraggedNode) {
            resolvedItemBackgroundColor = Colors.green.withOpacity(0.1);
            resolvedItemBorder = Border.all(color: Colors.greenAccent.shade400.withOpacity(0.7), width: 1.0);
          } else {
            resolvedItemBackgroundColor = Colors.red.withOpacity(0.08);
            resolvedItemBorder = Border.all(color: Colors.redAccent.shade400.withOpacity(0.7), width: 1.0);
          }
        } else if (isActuallySelected) {
          resolvedItemBackgroundColor = selectedColor.withOpacity(0.12);
        } else if (showHoverEffectInTreeItem) {
          resolvedItemBackgroundColor = hoverEffectColor.withOpacity(0.1);
        }

        return Container(
          margin: EdgeInsets.only(left: depth * 16.0),
          padding: const EdgeInsets.symmetric(vertical: 0.5),
          decoration: BoxDecoration(
            color: resolvedItemBackgroundColor,
            border: resolvedItemBorder,
            borderRadius: BorderRadius.circular(4),
          ),
          child: finalInteractiveItem,
        );
      }

      Widget dragTargetForItem = (node.id == rootNode.id && rc?.type == 'Container')
          ? finalInteractiveItem
          : DragTarget<String>(
        builder: dragTargetVisualBuilder,
        onWillAcceptWithDetails: (DragTargetDetails<String> details) {
          final String draggedNodeId = details.data;
          if (draggedNodeId == node.id) return false;

          final targetNodeDefinition = registeredComponents[node.type];
          if (targetNodeDefinition == null || targetNodeDefinition.childPolicy == ChildAcceptancePolicy.none) return false;

          if (targetNodeDefinition.childPolicy == ChildAcceptancePolicy.single && node.children.isNotEmpty) {
            bool draggedIsCurrentChild = node.children.any((child) => child.id == draggedNodeId);
            if (!draggedIsCurrentChild) return false;
          }

          if (isAncestor(currentRootForChecks, draggedNodeId, node.id)) return false;
          return true;
        },
        onAcceptWithDetails: (DragTargetDetails<String> details) {
          final String draggedNodeId = details.data;
          final String targetParentId = node.id;

          final currentTree = ref.read(canvasTreeProvider);
          final WidgetNode? nodeToMove = findNodeById(currentTree, draggedNodeId);
          if (nodeToMove == null) return;

          final treeAfterRemoval = removeNodeById(currentTree, draggedNodeId);
          final finalTree = addNodeAsChildRecursive(treeAfterRemoval, targetParentId, nodeToMove);

          ref.read(canvasTreeProvider.notifier).state = finalTree;
          ref.read(selectedNodeIdProvider.notifier).state = draggedNodeId;
          ref.read(hoveredNodeIdProvider.notifier).state = null;
        },
      );

      Widget itemWithMouseRegionForHover = MouseRegion(
        onEnter: (_) {
          ref.read(hoveredNodeIdProvider.notifier).state = node.id;
        },
        onExit: (_) {
          if (ref.read(hoveredNodeIdProvider) == node.id) {
            ref.read(hoveredNodeIdProvider.notifier).state = null;
          }
        },
        cursor: SystemMouseCursors.click,
        child: dragTargetForItem,
      );

      widgets.add(itemWithMouseRegionForHover);

      if (node.children.isNotEmpty) {
        for (var child in node.children) {
          widgets.addAll(buildTreeNodes(child, depth + 1, currentRootForChecks));
        }
      }
      return widgets;
    }

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: buildTreeNodes(rootNode, 0, rootNode),
    );
  }
}