import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_constants.dart';
import '../../../editor/components/core/component_definition.dart';
import '../../../editor/components/core/component_registry.dart';
import '../../../editor/components/core/widget_node.dart';
import '../../../editor/components/core/widget_node_utils.dart';
import '../../../state/editor_state.dart';
import 'tree_line_painter.dart';

// Define the drag intent
enum _DropIntent {
  none,
  insertBefore,  // Insert as a brother
  addAsChild,    // As a child node
  insertAfter,   // Insert as a brother
}

class WidgetTreeItem extends ConsumerStatefulWidget {
  final WidgetNode node;
  final int depth;
  final WidgetNode overallRootNode;
  final bool isLastChild;
  final List<bool> ancestorIsLastList;

  const WidgetTreeItem({
    super.key,
    required this.node,
    required this.depth,
    required this.overallRootNode,
    required this.isLastChild,
    required this.ancestorIsLastList,
  });

  @override
  ConsumerState<WidgetTreeItem> createState() => _WidgetTreeItemState();
}

class _WidgetTreeItemState extends ConsumerState<WidgetTreeItem> {
  _DropIntent _dropIntent = _DropIntent.none;
  bool _isValidIntent = false;

  static const double _treeItemHeight = 40.0;
  static const double _expanderButtonWidth = 28.0;

  @override
  void dispose() {
    super.dispose();
  }

  void _resetDragState() {
    if (_dropIntent != _DropIntent.none || _isValidIntent) {
      if(mounted){
        setState(() {
          _dropIntent = _DropIntent.none;
          _isValidIntent = false;
        });
      }
    }
  }

  bool _canAcceptAsChild(WidgetNode draggedNodeData) {
    // Verify that the dragged component accepts the current node as its parent
    final draggedRc = registeredComponents[draggedNodeData.type];
    if (draggedRc?.requiredParentTypes != null &&
        !draggedRc!.requiredParentTypes!.contains(widget.node.type)) {
      return false;
    }

    // Verify that the current node accepts the dragged component as its child
    final targetRc = registeredComponents[widget.node.type];
    if (targetRc == null) return false;
    if (targetRc.childPolicy == ChildAcceptancePolicy.none) return false;
    if (targetRc.childPolicy == ChildAcceptancePolicy.single && widget.node.children.isNotEmpty) {
      return widget.node.children.length == 1 && widget.node.children.first.id == draggedNodeData.id;
    }
    return true;
  }

  bool _canAcceptAsSibling(WidgetNode draggedNodeData) {
    final parentOfCurrentNode = findParentNode(widget.overallRootNode, widget.node.id);
    if (parentOfCurrentNode == null) return false;

    // Verify that the dragged component accepts a future parent
    final draggedRc = registeredComponents[draggedNodeData.type];
    if (draggedRc?.requiredParentTypes != null &&
        !draggedRc!.requiredParentTypes!.contains(parentOfCurrentNode.type)) {
      return false;
    }

    // Verify that the future parent accepts the new child
    final parentRc = registeredComponents[parentOfCurrentNode.type];
    if (parentRc == null) return false;
    if (parentRc.childPolicy == ChildAcceptancePolicy.none) return false;
    if (parentRc.childPolicy == ChildAcceptancePolicy.single) {
      return parentOfCurrentNode.children.isEmpty || (parentOfCurrentNode.children.length == 1 && parentOfCurrentNode.children.first.id == draggedNodeData.id);
    }
    return true;
  }

  _DropIntent _getIntentFromOffset(Offset localPosition, Size size) {
    if (localPosition.dy < size.height * 0.25) {
      return _DropIntent.insertBefore;
    } else if (localPosition.dy > size.height * 0.75) {
      return _DropIntent.insertAfter;
    } else {
      return _DropIntent.addAsChild;
    }
  }

  Widget _buildItemContentRow(BuildContext context,
      WidgetRef ref,
      IconData iconData,
      String displayName,
      Color itemIconColor,
      Color itemTextColor,
      FontWeight itemFontWeight,
      bool hasChildren,
      bool isEffectivelyExpanded,
      ) {
    final expandedIdsNotifier = ref.read(expandedNodeIdsProvider.notifier);
    return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Row(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: _expanderButtonWidth,
              height: _treeItemHeight,
              child: hasChildren ? IconButton(
                icon: Icon(isEffectivelyExpanded ? Icons.arrow_drop_down : Icons
                    .arrow_right),
                iconSize: 20.0,
                padding: EdgeInsets.zero,
                alignment: Alignment.center,
                onPressed: () {
                  expandedIdsNotifier.update((currentIds) =>
                  currentIds.contains(widget.node.id) ? (Set.from(currentIds)
                    ..remove(widget.node.id)) : (Set.from(currentIds)
                    ..add(widget.node.id))
                  );
                },
              ) : null,
            ),
            Icon(iconData, size: 18, color: itemIconColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                displayName,
                style: TextStyle(
                    fontWeight: itemFontWeight,
                    fontSize: 13,
                    color: itemTextColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ));
  }

  // Builds the tappable and draggable part of the item
  Widget _buildTappableAndDraggableItem(
      BuildContext context,
      WidgetRef ref,
      Widget itemContentRow,
      RegisteredComponent? rc,
      IconData iconData,
      String displayName,
      ) {
    final selectedNodeNotifier = ref.read(selectedNodeIdProvider.notifier);
    Widget tappableItem = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          selectedNodeNotifier.state = widget.node.id;
          ref.read(hoveredNodeIdProvider.notifier).state = null;
          _resetDragState();
        },
        child: Container(
          height: _treeItemHeight,
          padding: const EdgeInsets.only(right: 4),
          alignment: Alignment.centerLeft,
          child: itemContentRow,
        ),
      ),
    );

    final bool canBeDragged = rc != null;
    if (canBeDragged) {
      tappableItem = LongPressDraggable<String>(
        data: widget.node.id,
        onDragStarted: () {
          ref.read(currentlyDraggedNodeIdProvider.notifier).state = widget.node.id;
        },
        onDragEnd: (details) {
          ref.read(currentlyDraggedNodeIdProvider.notifier).state = null;
        },
        feedback: Material(
          elevation: 4.0,
          color: Colors.transparent,
          child: Opacity(
            opacity: 0.85,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(iconData, size: 16, color: Theme.of(context).colorScheme.onPrimaryContainer),
                const SizedBox(width: 6),
                Text(displayName, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onPrimaryContainer)),
              ]),
            ),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.4, child: tappableItem),
        child: tappableItem,
      );
    }
    return tappableItem;
  }

  @override
  Widget build(BuildContext context) {
    final String? selectedNodeId = ref.watch(selectedNodeIdProvider);
    final String? currentHoveredIdByCanvas = ref.watch(hoveredNodeIdProvider);
    final String? currentlyDraggedNodeId = ref.watch(currentlyDraggedNodeIdProvider);

    final RegisteredComponent? rc = registeredComponents[widget.node.type];
    final String displayName = rc?.displayName ?? widget.node.type;
    final IconData iconData = rc?.icon ?? Icons.device_unknown;

    final bool isActuallySelected = widget.node.id == selectedNodeId;
    final bool isTreeItemDirectlyHovered = currentHoveredIdByCanvas == widget.node.id && !isActuallySelected && _dropIntent == _DropIntent.none;

    final Color itemIconColor = isActuallySelected ? Theme.of(context).colorScheme.primary : (isTreeItemDirectlyHovered ? kRendererHoverBorderColor : Theme.of(context).iconTheme.color?.withOpacity(0.7) ?? Colors.grey);
    final Color itemTextColor = isActuallySelected ? Theme.of(context).colorScheme.primary : (isTreeItemDirectlyHovered ? kRendererHoverBorderColor : Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black);
    final FontWeight itemFontWeight = isActuallySelected ? FontWeight.bold : FontWeight.normal;

    final bool hasChildren = widget.node.children.isNotEmpty;

    final bool isGloballyExpanded = ref.watch(expandedNodeIdsProvider).contains(widget.node.id);
    final bool isBeingDragged = widget.node.id == currentlyDraggedNodeId;
    final bool isEffectivelyExpanded = isGloballyExpanded && !isBeingDragged;

    final double treeLinesPainterAreaWidth = widget.depth * TreeLinePainter.indentWidth;

    final Widget itemContent = _buildItemContentRow(context, ref, iconData, displayName, itemIconColor, itemTextColor, itemFontWeight, hasChildren, isEffectivelyExpanded);
    final Widget tappableAndDraggableItem = _buildTappableAndDraggableItem(context, ref, itemContent, rc, iconData, displayName);

    return DragTarget<String>(
      onMove: (details) {
        if (!mounted) return;
        final draggedNodeId = details.data;
        if (draggedNodeId == widget.node.id || isAncestor(widget.overallRootNode, draggedNodeId, widget.node.id)) {
          _resetDragState();
          return;
        }

        final WidgetNode? draggedNodeInstance = findNodeById(widget.overallRootNode, draggedNodeId);
        if (draggedNodeInstance == null) {
          _resetDragState();
          return;
        }

        final renderBox = context.findRenderObject() as RenderBox;
        final newIntent = _getIntentFromOffset(renderBox.globalToLocal(details.offset), renderBox.size);

        bool isIntentValid;
        switch (newIntent) {
          case _DropIntent.addAsChild:
            isIntentValid = _canAcceptAsChild(draggedNodeInstance);
            break;
          case _DropIntent.insertBefore:
          case _DropIntent.insertAfter:
            isIntentValid = _canAcceptAsSibling(draggedNodeInstance);
            break;
          case _DropIntent.none:
            isIntentValid = false;
            break;
        }

        if (newIntent != _dropIntent || isIntentValid != _isValidIntent) {
          setState(() {
            _dropIntent = newIntent;
            _isValidIntent = isIntentValid;
          });
        }
      },
      onWillAcceptWithDetails: (details) {
        // This callback is the authoritative gatekeeper.
        // It performs its own validation, ignoring the widget's state,
        // to avoid any race conditions with setState.
        final draggedNodeId = details.data;
        if (draggedNodeId == widget.node.id || isAncestor(widget.overallRootNode, draggedNodeId, widget.node.id)) {
          return false;
        }

        final WidgetNode? draggedNodeInstance = findNodeById(widget.overallRootNode, draggedNodeId);
        if (draggedNodeInstance == null) {
          return false;
        }

        final renderBox = context.findRenderObject() as RenderBox;
        final intent = _getIntentFromOffset(renderBox.globalToLocal(details.offset), renderBox.size);

        switch (intent) {
          case _DropIntent.addAsChild:
            return _canAcceptAsChild(draggedNodeInstance);
          case _DropIntent.insertBefore:
          case _DropIntent.insertAfter:
            return _canAcceptAsSibling(draggedNodeInstance);
          case _DropIntent.none:
          default:
            return false;
        }
      },
      onAcceptWithDetails: (details) {
        final String draggedNodeId = details.data;
        final WidgetNode? nodeToMoveOriginal = findNodeById(widget.overallRootNode, draggedNodeId);
        if (nodeToMoveOriginal == null) {
          _resetDragState();
          return;
        }

        final WidgetNode nodeToMove = deepCopyNode(nodeToMoveOriginal);
        WidgetNode currentTree = ref.read(activeCanvasTreeProvider);
        WidgetNode treeAfterRemoval = removeNodeById(currentTree, draggedNodeId);
        WidgetNode? finalTree;
        bool actionTaken = false;

        // The final action is based on the state set by the last onMove event.
        switch (_dropIntent) {
          case _DropIntent.addAsChild:
            finalTree = addNodeAsChildRecursive(treeAfterRemoval, widget.node.id, nodeToMove);
            actionTaken = true;
            break;
          case _DropIntent.insertBefore:
            finalTree = insertNodeAsSiblingRecursive(treeAfterRemoval, widget.node.id, nodeToMove, after: false);
            actionTaken = true;
            break;
          case _DropIntent.insertAfter:
            finalTree = insertNodeAsSiblingRecursive(treeAfterRemoval, widget.node.id, nodeToMove, after: true);
            actionTaken = true;
            break;
          case _DropIntent.none:
            break;
        }

        if (actionTaken && finalTree != null) {
          ref.read(projectStateProvider.notifier).updateActivePageTree(finalTree);
          ref.read(selectedNodeIdProvider.notifier).state = nodeToMove.id;
          ref.read(hoveredNodeIdProvider.notifier).state = null;
        }
        _resetDragState();
      },
      onLeave: (data) {
        _resetDragState();
      },
      builder: (context, candidateData, rejectedDataList) {

        Color? bgColor;
        Border? border;
        Widget? overlayLine;

        final bool isDraggingOver = candidateData.isNotEmpty || rejectedDataList.isNotEmpty;

        if (isDraggingOver) {
          if (_isValidIntent) {
            // Valid drop state
            switch (_dropIntent) {
              case _DropIntent.insertBefore:
                overlayLine = Align(alignment: Alignment.topCenter, child: Container(height: 2.5, color: Colors.greenAccent.shade400));
                break;
              case _DropIntent.insertAfter:
                overlayLine = Align(alignment: Alignment.bottomCenter, child: Container(height: 2.5, color: Colors.greenAccent.shade400));
                break;
              case _DropIntent.addAsChild:
                bgColor = Colors.green.withOpacity(0.1);
                border = Border.all(color: Colors.greenAccent.shade400, width: 1.5);
                break;
              case _DropIntent.none:
                break;
            }
          } else {
            // Invalid drop state
            border = Border.all(color: Colors.redAccent.shade400, width: 1.5);
            bgColor = Colors.red.withOpacity(0.08);
          }
        }

        // Apply default selection/hover styles if not dragging
        if (!isDraggingOver) {
          if (isActuallySelected) {
            bgColor = Theme.of(context).colorScheme.primary.withOpacity(0.12);
          } else if (isTreeItemDirectlyHovered) {
            bgColor = kRendererHoverBorderColor.withOpacity(0.1);
          }
        }

        return MouseRegion(
          onEnter: (_) { if (_dropIntent == _DropIntent.none) ref.read(hoveredNodeIdProvider.notifier).state = widget.node.id; },
          onExit: (_) { if (ref.read(hoveredNodeIdProvider) == widget.node.id) ref.read(hoveredNodeIdProvider.notifier).state = null; },
          cursor: SystemMouseCursors.click,
          child: SizedBox(
            height: _treeItemHeight + 3,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: treeLinesPainterAreaWidth,
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: TreeLinePainter(
                            depth: widget.depth,
                            isLastChild: widget.isLastChild,
                            ancestorIsLastList: widget.ancestorIsLastList,
                            lineColor: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7) ?? Colors.grey.shade400,
                            itemHeight: _treeItemHeight,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 1.0),
                          decoration: BoxDecoration(
                            color: bgColor,
                            border: border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: tappableAndDraggableItem,
                        ),
                      ),
                    ],
                  ),
                ),
                if (overlayLine != null) Positioned.fill(left: treeLinesPainterAreaWidth, child: overlayLine),
              ],
            ),
          ),
        );
      },
    );
  }
}
