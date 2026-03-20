import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_constants.dart';
import '../../../editor/components/core/component_definition.dart';
import '../../../editor/components/core/component_registry.dart';
import '../../../editor/components/core/widget_node.dart';
import '../../../editor/components/core/widget_node_utils.dart';
import '../../../state/editor_state.dart';
import 'tree_line_painter.dart';

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
  bool _isDragOver = false;
  bool _isValidIntent = false;

  static const double _treeItemHeight = 40.0;
  static const double _expanderButtonWidth = 28.0;

  @override
  void dispose() {
    super.dispose();
  }

  void _resetDragState() {
    if (_isDragOver || _isValidIntent) {
      if(mounted){
        setState(() {
          _isDragOver = false;
          _isValidIntent = false;
        });
      }
    }
  }

  bool _canAcceptAsChild(String draggedNodeId) {
    if (isAncestor(widget.overallRootNode, draggedNodeId, widget.node.id) || draggedNodeId == widget.node.id) {
      return false;
    }

    final WidgetNode? draggedNodeData = findNodeById(widget.overallRootNode, draggedNodeId);
    if (draggedNodeData == null) return false;

    final draggedRc = registeredComponents[draggedNodeData.type];
    if (draggedRc == null) return false;

    // Rule: Check allowed parents
    if (draggedRc.allowedParentTypes != null &&
        !draggedRc.allowedParentTypes!.contains(widget.node.type)) {
      return false;
    }

    // Rule: Check disallowed parents
    if (draggedRc.disallowedParentTypes != null &&
        draggedRc.disallowedParentTypes!.contains(widget.node.type)) {
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
      bool isDraggingActive,
      ) {
    final selectedNodeNotifier = ref.read(selectedNodeIdProvider.notifier);
    Widget tappableItem = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDraggingActive ? null : () {
          selectedNodeNotifier.state = widget.node.id;
          ref.read(hoveredNodeIdProvider.notifier).state = null;
          // No need to call _resetDragState, as it's for drop-target states.
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
          ref.read(interactionModeProvider.notifier).state = InteractionMode.dragging;
          ref.read(currentlyDraggedNodeIdProvider.notifier).state = widget.node.id;
        },
        onDragEnd: (details) {
          ref.read(interactionModeProvider.notifier).state = InteractionMode.normal;
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
    final interactionMode = ref.watch(interactionModeProvider);
    final bool isDraggingActive = interactionMode == InteractionMode.dragging;

    final String? selectedNodeId = ref.watch(selectedNodeIdProvider);
    final String? currentHoveredIdByCanvas = ref.watch(hoveredNodeIdProvider);
    final String? currentlyDraggedNodeId = ref.watch(currentlyDraggedNodeIdProvider);

    final RegisteredComponent? rc = registeredComponents[widget.node.type];
    final String displayName = rc?.displayName ?? widget.node.type;
    final IconData iconData = rc?.icon ?? Icons.device_unknown;

    final bool isActuallySelected = widget.node.id == selectedNodeId;
    final bool isTreeItemDirectlyHovered = !isDraggingActive && currentHoveredIdByCanvas == widget.node.id;

    final Color itemIconColor = isActuallySelected ? Theme.of(context).colorScheme.primary : (isTreeItemDirectlyHovered ? kRendererHoverBorderColor : Theme.of(context).iconTheme.color?.withOpacity(0.7) ?? Colors.grey);
    final Color itemTextColor = isActuallySelected ? Theme.of(context).colorScheme.primary : (isTreeItemDirectlyHovered ? kRendererHoverBorderColor : Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black);
    final FontWeight itemFontWeight = isActuallySelected ? FontWeight.bold : FontWeight.normal;

    final bool hasChildren = widget.node.children.isNotEmpty;

    final bool isGloballyExpanded = ref.watch(expandedNodeIdsProvider).contains(widget.node.id);
    final bool isBeingDragged = widget.node.id == currentlyDraggedNodeId;
    final bool isEffectivelyExpanded = isGloballyExpanded && !isBeingDragged;

    final double treeLinesPainterAreaWidth = widget.depth * TreeLinePainter.indentWidth;

    final Widget itemContent = _buildItemContentRow(context, ref, iconData, displayName, itemIconColor, itemTextColor, itemFontWeight, hasChildren, isEffectivelyExpanded);
    final Widget tappableAndDraggableItem = _buildTappableAndDraggableItem(context, ref, itemContent, rc, iconData, displayName, isDraggingActive);

    return DragTarget<String>(
      onMove: (details) {
        if (!mounted || !isDraggingActive) return;
        final canAccept = _canAcceptAsChild(details.data);
        if (canAccept != _isValidIntent || !_isDragOver) {
          setState(() {
            _isDragOver = true;
            _isValidIntent = canAccept;
          });
        }
      },
      onWillAcceptWithDetails: (details) {
        if (!isDraggingActive) return false;
        final isValid = _canAcceptAsChild(details.data);
        if (!isValid && _isValidIntent) {
          // If it was valid, but now it's not, reset state
          Future.microtask(_resetDragState);
        }
        return isValid;
      },
      onAccept: (draggedNodeId) {
        ref.read(projectStateProvider.notifier).moveNode(
          draggedNodeId: draggedNodeId,
          newParentId: widget.node.id,
          newIndex: 0, // When adding as a child, it's added to the end. The notifier handles the exact index.
        );
        _resetDragState();
      },
      onLeave: (data) {
        _resetDragState();
      },
      builder: (context, candidateData, rejectedDataList) {

        Color? bgColor;
        Border? border;

        if (isDraggingActive && _isDragOver) {
          if (_isValidIntent) {
                bgColor = Colors.green.withOpacity(0.1);
                border = Border.all(color: Colors.greenAccent.shade400, width: 1.5);
          } else {
            bgColor = Colors.red.withOpacity(0.08);
            border = Border.all(color: Colors.redAccent.shade400, width: 1.5);
          }
        }

        // Apply default selection/hover styles if not dragging
        if (!isDraggingActive) {
          if (isActuallySelected) {
            bgColor = Theme.of(context).colorScheme.primary.withOpacity(0.12);
          } else if (isTreeItemDirectlyHovered) {
            bgColor = kRendererHoverBorderColor.withOpacity(0.1);
          }
        }

        return MouseRegion(
          onEnter: isDraggingActive ? null : (_) { ref.read(hoveredNodeIdProvider.notifier).state = widget.node.id; },
          onExit: isDraggingActive ? null : (_) { if (ref.read(hoveredNodeIdProvider) == widget.node.id) ref.read(hoveredNodeIdProvider.notifier).state = null; },
          cursor: SystemMouseCursors.click,
          child: SizedBox(
            height: _treeItemHeight, // Use exact height
            child: Stack(
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
              ],
            ),
          ),
        );
      },
    );
  }
}
