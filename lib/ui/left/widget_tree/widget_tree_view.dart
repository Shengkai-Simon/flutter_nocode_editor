import 'package:flutter/material.dart';
import 'package:flutter_editor/ui/left/widget_tree/gap_drop_target.dart';
import 'package:flutter_editor/ui/left/widget_tree/widget_tree_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../editor/components/core/widget_node.dart';
import '../../../state/editor_state.dart';

class WidgetTreeView extends ConsumerWidget {
  const WidgetTreeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WidgetNode rootCanvasNode = ref.watch(activeCanvasTreeProvider);
    final interactionMode = ref.watch(interactionModeProvider);
    final bool isDragging = interactionMode == InteractionMode.dragging;

    // This is the main recursive function to build the tree
    List<Widget> buildTreeNodes(
      WidgetNode parentNode,
      int depth,
      WidgetNode overallRoot,
      List<bool> ancestorIsLastList,
    ) {
      final Set<String> expandedIds = ref.watch(expandedNodeIdsProvider);
      final String? currentlyDraggedNodeId = ref.watch(currentlyDraggedNodeIdProvider);
      
      List<Widget> widgets = [];

      // If dragging, add a drop target at the start of the children list
      if (isDragging) {
        widgets.add(GapDropTarget(
          parentNode: parentNode,
          targetIndex: 0,
          overallRootNode: overallRoot,
          depth: depth,
          isLastInSiblings: parentNode.children.isEmpty,
          ancestorIsLastList: ancestorIsLastList,
        ));
      }

      for (int i = 0; i < parentNode.children.length; i++) {
        final child = parentNode.children[i];
        final bool isLast = i == parentNode.children.length - 1;

        widgets.add(
          WidgetTreeItem(
            key: ValueKey(child.id),
            node: child,
            depth: depth,
            overallRootNode: overallRoot,
            isLastChild: isLast,
            ancestorIsLastList: ancestorIsLastList,
          ),
        );

        final bool isExpanded = expandedIds.contains(child.id);
        final bool isBeingDragged = currentlyDraggedNodeId == child.id;

        if (isExpanded && !isBeingDragged) {
          // If the child is expanded, recursively build its subtree
          List<bool> nextAncestorIsLastList = List.from(ancestorIsLastList)..add(isLast);
          widgets.addAll(buildTreeNodes(child, depth + 1, overallRoot, nextAncestorIsLastList));
        }

        // Always add a gap target after each item if dragging
        if (isDragging) {
          widgets.add(GapDropTarget(
            parentNode: parentNode,
            targetIndex: i + 1,
            overallRootNode: overallRoot,
            depth: depth,
            isLastInSiblings: isLast,
            ancestorIsLastList: ancestorIsLastList,
          ));
        }
      }
      return widgets;
    }

    List<Widget> topLevelWidgets = buildTreeNodes(rootCanvasNode, 0, rootCanvasNode, []);

    if (rootCanvasNode.children.isEmpty) {
      if (isDragging) {
        // If the canvas is empty, still show a drop target
        return ListView(children: [
          GapDropTarget(
            parentNode: rootCanvasNode,
            targetIndex: 0,
            overallRootNode: rootCanvasNode,
            depth: 0,
            isLastInSiblings: true,
            ancestorIsLastList: const [],
          ),
        ]);
      } else {
        return const Center(child: Text("Please add widgets to the canvas."));
      }
    } else {
      return ListView(
        padding: const EdgeInsets.all(8.0),
        children: topLevelWidgets,
      );
    }
  }
}