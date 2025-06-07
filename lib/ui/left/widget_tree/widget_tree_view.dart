import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_editor/ui/left/widget_tree/widget_tree_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../editor/components/core/widget_node.dart';
import '../../../state/editor_state.dart';

class WidgetTreeView extends ConsumerWidget {
  const WidgetTreeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WidgetNode rootCanvasNode = ref.watch(canvasTreeProvider);
    final Set<String> expandedIds = ref.watch(expandedNodeIdsProvider);

    List<Widget> buildTreeWidgetsRecursive(
        WidgetNode node,
        int depth,
        WidgetNode overallRoot,
        List<bool> ancestorIsLastList,
        bool isThisNodeTheLastChild,
        ) {
      List<Widget> widgets = [];
      widgets.add(
        WidgetTreeItem(
          key: ValueKey(node.id),
          node: node,
          depth: depth,
          overallRootNode: overallRoot,
          isLastChild: isThisNodeTheLastChild,
          ancestorIsLastList: ancestorIsLastList,
        ),
      );

      if (node.children.isNotEmpty && expandedIds.contains(node.id)) {
        for (int i = 0; i < node.children.length; i++) {
          final child = node.children[i];
          final bool isChildLastInSiblings = i == node.children.length - 1;
          List<bool> nextAncestorIsLastList = List.from(ancestorIsLastList);
          nextAncestorIsLastList.add(isThisNodeTheLastChild);
          widgets.addAll(buildTreeWidgetsRecursive(
            child,
            depth + 1,
            overallRoot,
            nextAncestorIsLastList,
            isChildLastInSiblings,
          ));
        }
      }
      return widgets;
    }

    List<Widget> topLevelTreeItems = [];
    for (int i = 0; i < rootCanvasNode.children.length; i++) {
      final topLevelChild = rootCanvasNode.children[i];
      final bool isThisTopLevelChildLast = i == rootCanvasNode.children.length - 1;
      topLevelTreeItems.addAll(buildTreeWidgetsRecursive(
        topLevelChild,
        0,
        rootCanvasNode,
        [],
        isThisTopLevelChildLast,
      ));
    }

    if (topLevelTreeItems.isEmpty) {
      return Center(child: Text("Please add widgets to the canvas."));
    } else {
      return ListView(
        padding: const EdgeInsets.all(8.0),
        children: topLevelTreeItems,
      );
    }
  }
}