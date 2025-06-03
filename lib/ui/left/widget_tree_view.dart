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
      final bool showTreeItemSelfHoverEffect = isNodeGloballyHovered && !isActuallySelected;

      final Color selectedColor = Theme.of(context).colorScheme.primary;
      final Color hoverEffectColor = kRendererHoverBorderColor;

      final bool hasChildren = node.children.isNotEmpty;
      final bool isCurrentlyExpanded = expandedIds.contains(node.id);

      // Leading widget in ListTile: expand/collapse icon + component icon
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
          else
            const SizedBox(width: 24.0),
          const SizedBox(width: 4),
          Icon(
            iconData,
            size: 18,
            color: isActuallySelected
                ? selectedColor
                : (showTreeItemSelfHoverEffect ? hoverEffectColor : Theme.of(context).iconTheme.color?.withOpacity(0.7)),
          ),
        ],
      );

      // Main content of the tree item
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
                : (showTreeItemSelfHoverEffect ? hoverEffectColor : Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ),
        selected: isActuallySelected, // Influences ListTile's internal selected state
        onTap: () {
          if (node.id != rootNode.id) { // Root node click might have different behavior (e.g. clear selection)
            selectedNodeNotifier.state = node.id;
          } else {
            selectedNodeNotifier.state = null;
          }
          // When an item is clicked, clear any active hover state, as selection takes precedence.
          refForRecursion.read(hoveredNodeIdProvider.notifier).state = null;
        },
      );

      // Determine if the current node can be dragged (root usually cannot)
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
              child: ListTile(dense: true,
                  leading: Row(mainAxisSize: MainAxisSize.min,
                      children: [
                        if(hasChildren) Icon(isCurrentlyExpanded ? Icons.arrow_drop_down : Icons.arrow_right, size: 22),
                        SizedBox(width: 4),
                        Icon(iconData, size: 18)
                      ]),
                  title: Text(
                      displayName, style: const TextStyle(fontSize: 13))),
            ),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.4, child: treeItemContent),
        child: treeItemContent, // The actual ListTile content
      )
          : treeItemContent; // If not draggable, just the ListTile content

      // Builder for the DragTarget's visual appearance based on drag state
      Widget dragTargetVisualBuilder(BuildContext context, List<String?> candidateDragData, List<dynamic> rejectedDragDataList) {
        Color? resolvedItemBackgroundColor;
        Border? resolvedItemBorder;

        // Precedence 1: Drag hover effect (another node is being dragged over this one)
        if (candidateDragData.isNotEmpty && candidateDragData.first != node.id) {
          // An acceptable node is hovering over this target
          resolvedItemBackgroundColor = Colors.green.withOpacity(0.1);
          resolvedItemBorder = Border.all(color: Colors.greenAccent.shade400.withOpacity(0.7), width: 1.0);
        } else if (rejectedDragDataList.isNotEmpty) {
          // A rejected node is hovering over this target
          resolvedItemBackgroundColor = Colors.red.withOpacity(0.08);
          resolvedItemBorder = Border.all(color: Colors.redAccent.shade400.withOpacity(0.7), width: 1.0);
        }
        // Precedence 2: This node is selected
        else if (isActuallySelected) {
          resolvedItemBackgroundColor = selectedColor.withOpacity(0.12);
        }
        // Precedence 3: This node is globally hovered (e.g., from canvas or tree hover)
        else if (showTreeItemSelfHoverEffect) {
          resolvedItemBackgroundColor = hoverEffectColor.withOpacity(0.1);
        }

        // The Container that shows background/border for selection, hover, and drag states
        return Container(
          decoration: BoxDecoration(
            color: resolvedItemBackgroundColor,
            border: resolvedItemBorder,
            borderRadius: BorderRadius.circular(4),
          ),
          child: finalInteractiveItem, // Contains the ListTile and Draggable logic
        );
      }

      // All nodes (including root) are DragTargets to provide visual feedback (red/green).
      // The onWillAcceptWithDetails will determine actual drop acceptance.
      Widget dragTargetForItem = DragTarget<String>(
        builder: dragTargetVisualBuilder,
        onWillAcceptWithDetails: (DragTargetDetails<String> details) {
          final String draggedNodeId = details.data;

          // Rule 1: Cannot drop on itself
          if (draggedNodeId == node.id) return false;

          // Rule 2: Root node in the tree generally does not accept children via DND re-parenting
          // Its children are top-level canvas elements.
          if (node.id == rootNode.id) {
            return false;
          }

          // Rules for non-root target nodes
          final targetNodeDefinition = registeredComponents[node.type];
          if (targetNodeDefinition == null || targetNodeDefinition.childPolicy == ChildAcceptancePolicy.none) return false;

          if (targetNodeDefinition.childPolicy == ChildAcceptancePolicy.single && node.children.isNotEmpty) {
            // If target is single-child and full, reject if dragged item is not its current child.
            bool draggedIsTheCurrentSingleChild = node.children.length == 1 && node.children.first.id == draggedNodeId;
            if (!draggedIsTheCurrentSingleChild) return false;
          }

          // Rule 3: Cannot drop an ancestor onto one of its descendants
          if (isAncestor(currentRootForChecks, draggedNodeId, node.id)) return false;
          return true; // Passes all checks
        },
        onAcceptWithDetails: (DragTargetDetails<String> details) {
          // This callback is only triggered if onWillAcceptWithDetails returned true.
          // Thus, rootNode (which returns false above) won't trigger this.
          final String draggedNodeId = details.data;
          final String targetParentId = node.id; // Current node becomes the new parent

          final currentTree = refForRecursion.read(canvasTreeProvider);
          final WidgetNode? nodeToMove = findNodeById(currentTree, draggedNodeId);
          if (nodeToMove == null) return; // Should not happen if onWillAccept was true

          final treeAfterRemoval = removeNodeById(currentTree, draggedNodeId);
          final finalTree = addNodeAsChildRecursive(treeAfterRemoval, targetParentId, nodeToMove);

          refForRecursion.read(canvasTreeProvider.notifier).state = finalTree;
          refForRecursion.read(selectedNodeIdProvider.notifier).state = draggedNodeId; // Select the moved node
          refForRecursion.read(hoveredNodeIdProvider.notifier).state = null; // Clear hover after DND
        },
      );

      // Wrap the item with MouseRegion to update global hover state when this tree item is hovered.
      // This enables canvas components to highlight when their corresponding tree item is hovered.
      Widget itemWithMouseRegionForHover = MouseRegion(
        onEnter: (_) {
          // Any tree item hover (including root) updates the global hovered ID.
          // Canvas WidgetRenderer will then decide how to react to root hover.
          refForRecursion.read(hoveredNodeIdProvider.notifier).state = node.id;
        },
        onExit: (_) {
          if (refForRecursion.read(hoveredNodeIdProvider) == node.id) {
            refForRecursion.read(hoveredNodeIdProvider.notifier).state = null;
          }
        },
        cursor: SystemMouseCursors.click, // Standard click cursor for tree items
        child: Container( // This outer container applies the indentation for the tree structure
          margin: EdgeInsets.only(left: depth * 16.0),
          child: dragTargetForItem, // The DragTarget which builds the visual item
        ),
      );

      widgets.add(itemWithMouseRegionForHover);

      // Recursively build children if this node has children and is expanded
      if (hasChildren && isCurrentlyExpanded) {
        for (var child in node.children) {
          widgets.addAll(buildTreeNodes(child, depth + 1, currentRootForChecks, refForRecursion));
        }
      }
      return widgets;
    }

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: buildTreeNodes(rootNode, 0, rootNode, ref), // Initial call
    );
  }
}