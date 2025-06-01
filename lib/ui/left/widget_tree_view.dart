import 'package:flutter/material.dart';
import 'package:flutter_editor/services/issue_reporter_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/components/core/widget_node.dart';
import '../../editor/components/core/component_registry.dart';
import '../../editor/components/core/component_definition.dart';
import '../../editor/components/core/widget_node_utils.dart';
import '../../state/editor_state.dart';

class WidgetTreeView extends ConsumerWidget {
  const WidgetTreeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WidgetNode rootNode = ref.watch(canvasTreeProvider);
    final String? selectedNodeId = ref.watch(selectedNodeIdProvider);
    final selectedNodeNotifier = ref.read(selectedNodeIdProvider.notifier);

    List<Widget> buildTreeNodes(WidgetNode node, int depth, WidgetNode currentRootForChecks) {
      List<Widget> widgets = [];
      final RegisteredComponent? rc = registeredComponents[node.type];
      final String displayName = rc?.displayName ?? node.type;
      final IconData iconData = rc?.icon ?? Icons.device_unknown;
      final bool isSelected = node.id == selectedNodeId;

      Widget treeItemContent = ListTile(
        dense: true,
        leading: Icon(iconData, size: 20, color: isSelected ? Theme.of(context).colorScheme.primary : null),
        title: Text(
          displayName,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
        selected: isSelected,
        onTap: () {
          if (node.id != rootNode.id) {
            selectedNodeNotifier.state = node.id;
          } else {
            selectedNodeNotifier.state = null;
          }
        },
      );

      Widget draggableTreeItem = node.id == rootNode.id
          ? treeItemContent
          : LongPressDraggable<String>(
        data: node.id,
        feedback: Material(
          elevation: 4.0,
          color: Colors.transparent,
          child: Opacity(
            opacity: 0.8,
            child: Container(
              padding: EdgeInsets.only(left: depth * 16.0),
              width: MediaQuery.of(context).size.width * 0.2,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: treeItemContent,
            ),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.4, child: treeItemContent),
        child: treeItemContent,
      );

      Widget finalListItem = DragTarget<String>(
        builder: (BuildContext context, List<String?> candidateData, List<dynamic> rejectedData) {
          bool isHovering = candidateData.isNotEmpty && candidateData.first != node.id;
          bool canAccept = false;
          if (isHovering) {
            final String? draggedNodeId = candidateData.first;
            if (draggedNodeId != null && rc != null) {
              if (node.id != rootNode.id &&
                  rc.childPolicy != ChildAcceptancePolicy.none &&
                  !isAncestor(currentRootForChecks, draggedNodeId, node.id)) {
                if (rc.childPolicy == ChildAcceptancePolicy.single && node.children.isNotEmpty) {
                  canAccept = false;
                } else {
                  canAccept = true;
                }
              }
            }
          }

          return Container(
            margin: EdgeInsets.only(left: depth * 16.0),
            decoration: BoxDecoration(
                color: isHovering && canAccept ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3) : null,
                border: isHovering && canAccept ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1) : null,
                borderRadius: BorderRadius.circular(2)
            ),
            child: draggableTreeItem,
          );
        },
        onWillAcceptWithDetails: (DragTargetDetails<String> details) {
          final String draggedNodeId = details.data;

          if (draggedNodeId == node.id) return false;

          final targetRc = registeredComponents[node.type];
          if (targetRc == null || targetRc.childPolicy == ChildAcceptancePolicy.none) {
            return false;
          }
          if (targetRc.childPolicy == ChildAcceptancePolicy.single && node.children.isNotEmpty) {
            if (node.children.any((child) => child.id != draggedNodeId)) return false;
          }

          if (isAncestor(currentRootForChecks, draggedNodeId, node.id)) {
            return false;
          }

          return true;
        },
        onAcceptWithDetails: (DragTargetDetails<String> details) {
          final String draggedNodeId = details.data;
          final String targetParentId = node.id;

          final currentTree = ref.read(canvasTreeProvider);

          final WidgetNode? nodeToMove = findNodeById(currentTree, draggedNodeId);
          if (nodeToMove == null) {
            IssueReporterService().reportError("Dragged node ($draggedNodeId) not found in tree.");
            return;
          }

          final treeAfterRemoval = removeNodeById(currentTree, draggedNodeId);

          final finalTree = addNodeAsChildRecursive(treeAfterRemoval, targetParentId, nodeToMove);

          ref.read(canvasTreeProvider.notifier).state = finalTree;
          ref.read(selectedNodeIdProvider.notifier).state = draggedNodeId;
        },
      );

      widgets.add(Padding(
        padding: EdgeInsets.zero,
        child: finalListItem,
      ));

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