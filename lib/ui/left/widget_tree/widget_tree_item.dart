import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_constants.dart';
import '../../../editor/components/core/component_definition.dart';
import '../../../editor/components/core/component_registry.dart';
import '../../../editor/components/core/widget_node.dart';
import '../../../editor/components/core/widget_node_utils.dart';
import '../../../services/issue_reporter_service.dart';
import '../../../state/editor_state.dart';
import 'tree_line_painter.dart';

// Enum to manage the drag-over state for a tree item
enum _DragTargetInteractionState {
  none,
  canBeChild,
  animatingForSibling,
  cannotBeChildOrSibling,
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

class _WidgetTreeItemState extends ConsumerState<WidgetTreeItem> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _redBorderFadeAnimation;
  late Animation<double> _greenLineGrowAnimation;

  _DragTargetInteractionState _dragTargetState = _DragTargetInteractionState.none;
  String? _currentDraggedNodeId;

  static const double _treeItemHeight = 40.0;
  static const double _expanderButtonWidth = 28.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _redBorderFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _greenLineGrowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _resetDragStateAndAnimation() {
    if (!mounted) return;
    _animationController.reset();
    _currentDraggedNodeId = null;
    if (_dragTargetState != _DragTargetInteractionState.none) {
      setState(() {
        _dragTargetState = _DragTargetInteractionState.none;
      });
    }
  }

  bool _canAcceptAsChild(WidgetNode draggedNodeData) {
    final targetRc = registeredComponents[widget.node.type];
    if (targetRc == null) return false;
    if (targetRc.childPolicy == ChildAcceptancePolicy.none) return false;
    if (targetRc.childPolicy == ChildAcceptancePolicy.single && widget.node.children.isNotEmpty) {
      return widget.node.children.length == 1 && widget.node.children.first.id == draggedNodeData.id;
    }
    return true;
  }

  bool _canAcceptAsSiblingAfter(WidgetNode draggedNodeData) {
    final parentOfCurrentNode = findParentNode(widget.overallRootNode, widget.node.id);
    if (parentOfCurrentNode == null) return false;
    final parentRc = registeredComponents[parentOfCurrentNode.type];
    if (parentRc == null) return false;
    if (parentRc.childPolicy == ChildAcceptancePolicy.none) return false;
    if (parentRc.childPolicy == ChildAcceptancePolicy.single) {
      return parentOfCurrentNode.children.isEmpty || (parentOfCurrentNode.children.length == 1 && parentOfCurrentNode.children.first.id == draggedNodeData.id);
    }
    return true;
  }

  // Builds the main interactive content of the tree item (expander, icon, text)
  Widget _buildItemContentRow(BuildContext context,
      WidgetRef ref,
      IconData iconData,
      String displayName,
      Color itemIconColor,
      Color itemTextColor,
      FontWeight itemFontWeight,
      bool hasChildren,
      bool isCurrentlyExpanded,) {
    final expandedIdsNotifier = ref.read(expandedNodeIdsProvider.notifier);
    return Padding(
        padding: EdgeInsets.only(left: 10),
        child: Row(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: _expanderButtonWidth,
              height: _treeItemHeight,
              child: hasChildren ? IconButton(
                icon: Icon(isCurrentlyExpanded ? Icons.arrow_drop_down : Icons
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
          _resetDragStateAndAnimation();
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

  // Builds the container that shows selection, hover, and drag feedback (borders, background)
  Widget _buildStyledItemContainer(
      BuildContext context,
      WidgetRef ref,
      Widget tappableItem,
      bool isActuallySelected,
      bool isTreeItemDirectlyHovered,
      ) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        Color? currentBgColor; Border? currentBorder;
        switch (_dragTargetState) {
          case _DragTargetInteractionState.canBeChild:
            currentBorder = Border.all(color: Colors.greenAccent.shade400, width: 1.5);
            currentBgColor = Colors.green.withOpacity(0.1);
            break;
          case _DragTargetInteractionState.animatingForSibling:
            currentBorder = Border.all(color: Colors.redAccent.shade400.withOpacity(_redBorderFadeAnimation.value), width: 1.5);
            currentBgColor = Colors.red.withOpacity(0.08 * _redBorderFadeAnimation.value);
            break;
          case _DragTargetInteractionState.cannotBeChildOrSibling:
            currentBorder = Border.all(color: Colors.redAccent.shade400, width: 1.5);
            currentBgColor = Colors.red.withOpacity(0.08);
            break;
          default:
            if (isActuallySelected) {
              currentBgColor = Theme.of(context).colorScheme.primary.withOpacity(0.12);
            } else if (isTreeItemDirectlyHovered) {
              currentBgColor = kRendererHoverBorderColor.withOpacity(0.1);
            }
            break;
        }
        final rejected = ref.watch(dragRejectedDataProviderFor(widget.node.id));
        if (rejected.isNotEmpty && _dragTargetState != _DragTargetInteractionState.animatingForSibling) {
          currentBorder = Border.all(color: Colors.redAccent.shade400, width: 1.5);
          currentBgColor = Colors.red.withOpacity(0.08);
        }
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 1.0),
          decoration: BoxDecoration(color: currentBgColor, border: currentBorder, borderRadius: BorderRadius.circular(4)),
          child: tappableItem,
        );
      },
    );
  }

  // Builds the green line indicator for sibling drop
  Widget _buildSiblingDropIndicator(double treeLinesPainterAreaWidth) {
    if (_dragTargetState == _DragTargetInteractionState.animatingForSibling && _greenLineGrowAnimation.value > 0.01) {
      return Positioned(
        left: treeLinesPainterAreaWidth,
        right: 0,
        bottom: 0,
        child: FractionallySizedBox(
          widthFactor: _greenLineGrowAnimation.value,
          alignment: Alignment.centerLeft,
          child: Container(height: 3.0, color: Colors.greenAccent.shade400),
        ),
      );
    }
    return const SizedBox.shrink(); // Return empty if not needed
  }

  @override
  Widget build(BuildContext context) {
    final String? selectedNodeId = ref.watch(selectedNodeIdProvider);
    final String? currentHoveredIdByCanvas = ref.watch(hoveredNodeIdProvider);

    final RegisteredComponent? rc = registeredComponents[widget.node.type];
    final String displayName = rc?.displayName ?? widget.node.type;
    final IconData iconData = rc?.icon ?? Icons.device_unknown;

    final bool isActuallySelected = widget.node.id == selectedNodeId;
    final bool isTreeItemDirectlyHovered = currentHoveredIdByCanvas == widget.node.id && !isActuallySelected && _dragTargetState == _DragTargetInteractionState.none;

    final Color itemIconColor = isActuallySelected ? Theme.of(context).colorScheme.primary : (isTreeItemDirectlyHovered ? kRendererHoverBorderColor : Theme.of(context).iconTheme.color?.withOpacity(0.7) ?? Colors.grey);
    final Color itemTextColor = isActuallySelected ? Theme.of(context).colorScheme.primary : (isTreeItemDirectlyHovered ? kRendererHoverBorderColor : Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black);
    final FontWeight itemFontWeight = isActuallySelected ? FontWeight.bold : FontWeight.normal;

    final bool hasChildren = widget.node.children.isNotEmpty;
    final bool isCurrentlyExpanded = ref.watch(expandedNodeIdsProvider).contains(widget.node.id);
    final double treeLinesPainterAreaWidth = widget.depth * TreeLinePainter.indentWidth;

    final Widget itemContent = _buildItemContentRow(context, ref, iconData, displayName, itemIconColor, itemTextColor, itemFontWeight, hasChildren, isCurrentlyExpanded);
    final Widget tappableAndDraggableItem = _buildTappableAndDraggableItem(context, ref, itemContent, rc, iconData, displayName);
    final Widget styledItem = _buildStyledItemContainer(context, ref, tappableAndDraggableItem, isActuallySelected, isTreeItemDirectlyHovered);
    final Widget siblingIndicator = _buildSiblingDropIndicator(treeLinesPainterAreaWidth);

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) {
        final draggedNodeId = details.data;
        _currentDraggedNodeId = draggedNodeId;
        final WidgetNode? draggedNodeInstance = findNodeById(widget.overallRootNode, draggedNodeId);

        if (draggedNodeInstance == null || draggedNodeId == widget.node.id || isAncestor(widget.overallRootNode, draggedNodeId, widget.node.id)) {
          if (mounted) {
            _animationController.reset();
            setState(() => _dragTargetState = _DragTargetInteractionState.cannotBeChildOrSibling);
          }
          return false;
        }
        bool canBeChild = _canAcceptAsChild(draggedNodeInstance);
        if (canBeChild) {
          if (mounted) {
            _animationController.reset();
            setState(() => _dragTargetState = _DragTargetInteractionState.canBeChild);
          }
          return true;
        } else {
          bool canBeSibling = _canAcceptAsSiblingAfter(draggedNodeInstance);
          if (canBeSibling) {
            if (mounted) {
              if (_dragTargetState != _DragTargetInteractionState.animatingForSibling) {
                _animationController.forward(from: 0.0);
              }
              setState(() => _dragTargetState = _DragTargetInteractionState.animatingForSibling);
            }
            return true;
          } else {
            if (mounted) {
              _animationController.reset();
              setState(() => _dragTargetState = _DragTargetInteractionState.cannotBeChildOrSibling);
            }
            return false;
          }
        }
      },
      onAcceptWithDetails: (details) {
        final String draggedNodeId = details.data;
        _currentDraggedNodeId = null;
        final WidgetNode? nodeToMoveOriginal = findNodeById(widget.overallRootNode, draggedNodeId);
        if (nodeToMoveOriginal == null) {
          _resetDragStateAndAnimation();
          return;
        }
        final WidgetNode nodeToMove = deepCopyNode(nodeToMoveOriginal);
        WidgetNode currentTree = ref.read(activeCanvasTreeProvider);
        WidgetNode treeAfterRemoval = removeNodeById(currentTree, draggedNodeId);
        WidgetNode finalTree = treeAfterRemoval;
        bool actionTaken = false;

        if (_dragTargetState == _DragTargetInteractionState.canBeChild) {
          finalTree = addNodeAsChildRecursive(treeAfterRemoval, widget.node.id, nodeToMove);
          actionTaken = true;
        } else if (_dragTargetState == _DragTargetInteractionState.animatingForSibling) {
          if (_animationController.isCompleted) {
            finalTree = insertNodeAsSiblingRecursive(treeAfterRemoval, widget.node.id, nodeToMove, after: true);
            actionTaken = true;
          } else {
            IssueReporterService().reportWarning("Sibling drop for ${widget.node.type} cancelled: animation not completed.");
          }
        }
        if (actionTaken) {
          ref.read(historyManagerProvider.notifier).recordState(finalTree);
          ref.read(selectedNodeIdProvider.notifier).state = nodeToMove.id;
          ref.read(hoveredNodeIdProvider.notifier).state = null;
        }
        _resetDragStateAndAnimation();
      },
      onLeave: (data) { if (data == _currentDraggedNodeId) _resetDragStateAndAnimation(); },
      builder: (context, candidateData, rejectedDataList) {
        Future.microtask(() { if(mounted) ref.read(dragRejectedDataProviderFor(widget.node.id).notifier).state = rejectedDataList; });
        return MouseRegion(
          onEnter: (_) { if (_dragTargetState == _DragTargetInteractionState.none && _currentDraggedNodeId == null) ref.read(hoveredNodeIdProvider.notifier).state = widget.node.id; },
          onExit: (_) { if (ref.read(hoveredNodeIdProvider) == widget.node.id && _dragTargetState == _DragTargetInteractionState.none && _currentDraggedNodeId == null) ref.read(hoveredNodeIdProvider.notifier).state = null; },
          cursor: SystemMouseCursors.click,
          child: SizedBox(
            height: _treeItemHeight + 3,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomLeft,
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
                      Expanded(child: styledItem),
                    ],
                  ),
                ),
                siblingIndicator,
              ],
            ),
          ),
        );
      },
    );
  }
}