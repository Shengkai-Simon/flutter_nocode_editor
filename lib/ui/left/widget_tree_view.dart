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

    List<Widget> buildTreeNodes(WidgetNode node, int depth, WidgetNode currentRootForChecks, WidgetRef refForRecursion) {
      List<Widget> widgets = [];

      final RegisteredComponent? rc = registeredComponents[node.type];
      final String displayName = rc?.displayName ?? node.type;
      final IconData iconData = rc?.icon ?? Icons.device_unknown;

      final Set<String> expandedIds = refForRecursion.watch(expandedNodeIdsProvider);
      final StateController<Set<String>> expandedIdsNotifier = refForRecursion.read(expandedNodeIdsProvider.notifier);

      final bool isActuallySelected = node.id == selectedNodeId;
      final bool isNodeGloballyHovered = node.id == currentHoveredId;
      final bool showHoverEffectInTreeItem = isNodeGloballyHovered && !isActuallySelected;

      final Color selectedColor = Theme.of(context).colorScheme.primary;
      final Color hoverEffectColor = kRendererHoverBorderColor;

      final bool hasChildren = node.children.isNotEmpty;
      final bool isCurrentlyExpanded = expandedIds.contains(node.id);

      Widget leadingWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (hasChildren)
            IconButton(
              icon: Icon(isCurrentlyExpanded ? Icons.arrow_drop_down : Icons.arrow_right),
              iconSize: 22.0,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              onPressed: () {
                expandedIdsNotifier.update((currentExpandedIds) {
                  final newIds = Set<String>.from(currentExpandedIds);
                  if (newIds.contains(node.id)) {
                    newIds.remove(node.id);
                  } else {
                    newIds.add(node.id);
                  }
                  return newIds;
                });
              },
            )
          else const SizedBox(width: 24.0),

          const SizedBox(width: 4),

          Icon(
            iconData,
            size: 18,
            color: isActuallySelected
                ? selectedColor
                : (showHoverEffectInTreeItem ? hoverEffectColor : Theme.of(context).iconTheme.color?.withOpacity(0.7)),
          ),
        ],
      );

      Widget treeItemContent = ListTile(
        dense: true,
        leading: leadingWidget,
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
          refForRecursion.read(hoveredNodeIdProvider.notifier).state = null;
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
              child: ListTile(dense: true, leading: Row(mainAxisSize: MainAxisSize.min, children:[if(hasChildren) Icon(isCurrentlyExpanded ? Icons.arrow_drop_down : Icons.arrow_right, size:22), SizedBox(width:4), Icon(iconData, size:18)]), title: Text(displayName, style: const TextStyle(fontSize: 13))),
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
          decoration: BoxDecoration(
            color: resolvedItemBackgroundColor,
            border: resolvedItemBorder,
            borderRadius: BorderRadius.circular(4),
          ),
          child: finalInteractiveItem,
        );
      }

      Widget dragTargetForItem = (node.id == rootNode.id && rc?.type == 'Container' )
          ? finalInteractiveItem
          : DragTarget<String>(
        builder: dragTargetVisualBuilder,
        onWillAcceptWithDetails: (DragTargetDetails<String> details) {
          final String draggedNodeId = details.data;
          if (draggedNodeId == node.id) return false;
          if (node.id == rootNode.id ) return false;

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

          final currentTree = refForRecursion.read(canvasTreeProvider);
          final WidgetNode? nodeToMove = findNodeById(currentTree, draggedNodeId);
          if (nodeToMove == null) return;

          final treeAfterRemoval = removeNodeById(currentTree, draggedNodeId);
          final finalTree = addNodeAsChildRecursive(treeAfterRemoval, targetParentId, nodeToMove);

          refForRecursion.read(canvasTreeProvider.notifier).state = finalTree;
          refForRecursion.read(selectedNodeIdProvider.notifier).state = draggedNodeId;
          refForRecursion.read(hoveredNodeIdProvider.notifier).state = null;
        },
      );

      Widget itemWithMouseRegionForHover = MouseRegion(
        onEnter: (_) {
          if (node.id != rootNode.id) {
            refForRecursion.read(hoveredNodeIdProvider.notifier).state = node.id;
          }
        },
        onExit: (_) {
          if (refForRecursion.read(hoveredNodeIdProvider) == node.id) {
            refForRecursion.read(hoveredNodeIdProvider.notifier).state = null;
          }
        },
        cursor: SystemMouseCursors.click,
        child: Container(
          margin: EdgeInsets.only(left: depth * 16.0),
          child: dragTargetForItem,
        ),
      );

      widgets.add(itemWithMouseRegionForHover);

      if (hasChildren && isCurrentlyExpanded) {
        for (var child in node.children) {
          widgets.addAll(buildTreeNodes(child, depth + 1, currentRootForChecks, refForRecursion));
        }
      }
      return widgets;
    }

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: buildTreeNodes(rootNode, 0, rootNode, ref),
    );
  }
}