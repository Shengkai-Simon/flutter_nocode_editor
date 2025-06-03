import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/components/core/widget_node.dart';
import '../../editor/components/core/component_registry.dart';
import '../../editor/components/core/component_definition.dart';
import '../../services/issue_reporter_service.dart';
import '../../state/editor_state.dart';
import '../../editor/components/core/widget_node_utils.dart';
import '../../constants/app_constants.dart';

// Enum to manage the drag-over state for a tree item
enum _DragTargetInteractionState {
  none, // Default, no drag happening over this item
  canBeChild, // Dragged item can be a child of this item
  animatingForSibling, // Cannot be child, animation running for potential sibling drop
  cannotBeChildOrSibling, // Neither child nor sibling is possible
}

class WidgetTreeView extends ConsumerWidget {
  const WidgetTreeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WidgetNode rootNode = ref.watch(canvasTreeProvider);
    final Set<String> expandedIds = ref.watch(expandedNodeIdsProvider);

    List<Widget> buildTreeWidgets(WidgetNode node, int depth, WidgetNode overallRoot) {
      List<Widget> widgets = [];
      widgets.add(
        _WidgetTreeItem(
          key: ValueKey(node.id + expandedIds.toString()), // Ensure widget identity for state preservation
          node: node,
          depth: depth,
          overallRootNode: overallRoot,
        ),
      );


      if (node.children.isNotEmpty && expandedIds.contains(node.id)) {
        for (var child in node.children) {
          widgets.addAll(buildTreeWidgets(child, depth + 1, overallRoot));
        }
      }
      return widgets;
    }

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: buildTreeWidgets(rootNode, 0, rootNode),
    );
  }
}

class _WidgetTreeItem extends ConsumerStatefulWidget {
  final WidgetNode node;
  final int depth;
  final WidgetNode overallRootNode;

  const _WidgetTreeItem({
    super.key,
    required this.node,
    required this.depth,
    required this.overallRootNode,
  });

  @override
  ConsumerState<_WidgetTreeItem> createState() => _WidgetTreeItemState();
}

class _WidgetTreeItemState extends ConsumerState<_WidgetTreeItem> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _redBorderFadeAnimation;
  late Animation<double> _greenLineGrowAnimation;

  _DragTargetInteractionState _dragTargetState = _DragTargetInteractionState.none;
  String? _currentDraggedNodeId; // To keep track of what's being dragged over

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      // Animation duration is now 2 seconds
      duration: const Duration(seconds: 1),
      vsync: this,
    )..addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    // Both animations now run over the full 2-second duration
    _redBorderFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _greenLineGrowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear), // Linear for smooth growth
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
    if (widget.node.id == widget.overallRootNode.id) return false;
    final parentOfCurrentNode = findParentNode(widget.overallRootNode, widget.node.id);
    if (parentOfCurrentNode == null) return false;
    final parentRc = registeredComponents[parentOfCurrentNode.type];
    if (parentRc == null) return false;
    if (parentRc.childPolicy == ChildAcceptancePolicy.none) return false;
    if (parentRc.childPolicy == ChildAcceptancePolicy.single) {
      // Cannot add a sibling if parent is single-child and already has its child (which isn't the one being dragged for reordering)
      return parentOfCurrentNode.children.isEmpty || (parentOfCurrentNode.children.length == 1 && parentOfCurrentNode.children.first.id == draggedNodeData.id);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final String? selectedNodeId = ref.watch(selectedNodeIdProvider);
    final selectedNodeNotifier = ref.read(selectedNodeIdProvider.notifier);
    final String? currentHoveredIdByCanvas = ref.watch(hoveredNodeIdProvider);

    final RegisteredComponent? rc = registeredComponents[widget.node.type];
    final String displayName = rc?.displayName ?? widget.node.type;
    final IconData iconData = rc?.icon ?? Icons.device_unknown;

    final Set<String> expandedIds = ref.watch(expandedNodeIdsProvider);
    final StateController<Set<String>> expandedIdsNotifier = ref.read(expandedNodeIdsProvider.notifier);

    final bool isActuallySelected = widget.node.id == selectedNodeId;
    final bool isTreeItemDirectlyHovered = currentHoveredIdByCanvas == widget.node.id && !isActuallySelected && _dragTargetState == _DragTargetInteractionState.none;

    final Color defaultIconColor = Theme.of(context).iconTheme.color?.withOpacity(0.7) ?? Colors.grey;
    final Color defaultTextColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    Color itemIconColor = defaultIconColor;
    Color itemTextColor = defaultTextColor;
    FontWeight itemFontWeight = FontWeight.normal;

    if (isActuallySelected) {
      itemIconColor = Theme.of(context).colorScheme.primary;
      itemTextColor = Theme.of(context).colorScheme.primary;
      itemFontWeight = FontWeight.bold;
    } else if (isTreeItemDirectlyHovered) {
      itemIconColor = kRendererHoverBorderColor;
      itemTextColor = kRendererHoverBorderColor;
    }

    final bool hasChildren = widget.node.children.isNotEmpty;
    final bool isCurrentlyExpanded = expandedIds.contains(widget.node.id);

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
                newIds.contains(widget.node.id) ? newIds.remove(widget.node.id) : newIds.add(widget.node.id);
                return newIds;
              });
            },
          )
        else
          const SizedBox(width: 24.0),
        const SizedBox(width: 4),
        Icon(iconData, size: 18, color: itemIconColor),
      ],
    );

    Widget treeItemContent = ListTile(
      dense: true,
      leading: leadingWidget,
      title: Text(
        displayName,
        style: TextStyle(fontWeight: itemFontWeight, fontSize: 13, color: itemTextColor),
      ),
      selected: isActuallySelected,
      onTap: () {
        selectedNodeNotifier.state = widget.node.id;
        ref.read(hoveredNodeIdProvider.notifier).state = null;
        _resetDragStateAndAnimation();
      },
    );

    bool canBeDragged = widget.node.id != widget.overallRootNode.id && rc != null;
    Widget interactiveItem = canBeDragged
        ? LongPressDraggable<String>(
      data: widget.node.id,
      feedback: Material(
        elevation: 4.0,
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.8,
          child: Container(
            padding: EdgeInsets.only(left: widget.depth * 1.0),
            width: kLeftPanelWidth * 0.8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
            child: ListTile(
                dense: true,
                leading: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (hasChildren) Icon(isCurrentlyExpanded ? Icons.arrow_drop_down : Icons.arrow_right, size: 22),
                  const SizedBox(width: 4),
                  Icon(iconData, size: 18)
                ]),
                title: Text(displayName, style: const TextStyle(fontSize: 13))),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: treeItemContent),
      child: treeItemContent,
    )
        : treeItemContent;

    return DragTarget<String>(
      onWillAcceptWithDetails: (DragTargetDetails<String> details) {
        final draggedNodeId = details.data;
        _currentDraggedNodeId = draggedNodeId; // Store for onLeave check
        final WidgetNode? draggedNodeInstance = findNodeById(widget.overallRootNode, draggedNodeId);

        if (draggedNodeInstance == null || draggedNodeId == widget.node.id || isAncestor(widget.overallRootNode, draggedNodeId, widget.node.id)) {
          if (mounted) {
            _animationController.reset(); // Stop animation if it was running for a different invalid interaction
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
                _animationController.forward(from: 0.0); // Start animation from beginning
              }
              setState(() => _dragTargetState = _DragTargetInteractionState.animatingForSibling);
            }
            return true; // Still accept, decision on drop
          } else {
            if (mounted) {
              _animationController.reset();
              setState(() => _dragTargetState = _DragTargetInteractionState.cannotBeChildOrSibling);
            }
            return false;
          }
        }
      },
      onAcceptWithDetails: (DragTargetDetails<String> details) {
        final String draggedNodeId = details.data;
        _currentDraggedNodeId = null; // Clear after processing
        final WidgetNode? nodeToMoveOriginal = findNodeById(widget.overallRootNode, draggedNodeId);

        if (nodeToMoveOriginal == null) {
          _resetDragStateAndAnimation();
          return;
        }
        final WidgetNode nodeToMove = deepCopyNode(nodeToMoveOriginal);
        WidgetNode currentTree = ref.read(canvasTreeProvider);
        WidgetNode treeAfterRemoval = removeNodeById(currentTree, draggedNodeId);
        WidgetNode finalTree = treeAfterRemoval; // Default to no change if conditions not met

        bool actionTaken = false;
        if (_dragTargetState == _DragTargetInteractionState.canBeChild) {
          finalTree = addNodeAsChildRecursive(treeAfterRemoval, widget.node.id, nodeToMove);
          actionTaken = true;
        } else if (_dragTargetState == _DragTargetInteractionState.animatingForSibling) {
          // Only perform sibling drop if animation was completed
          if (_animationController.isCompleted) {
            finalTree = insertNodeAsSiblingRecursive(treeAfterRemoval, widget.node.id, nodeToMove, after: true);
            actionTaken = true;
          } else {
            // Animation not completed, action is cancelled
            IssueReporterService().reportWarning("Sibling drop for ${widget.node.type} cancelled: animation not completed.");
            // Sibling drop for [type] cancelled: animation not completed.
          }
        }

        if (actionTaken) {
          ref.read(canvasTreeProvider.notifier).state = finalTree;
          ref.read(selectedNodeIdProvider.notifier).state = nodeToMove.id;
          ref.read(hoveredNodeIdProvider.notifier).state = null;
        }
        _resetDragStateAndAnimation();
      },
      onLeave: (data) {
        // Only reset if the leaving item is the one we were tracking
        if (data == _currentDraggedNodeId) {
          _resetDragStateAndAnimation();
        }
      },
      builder: (BuildContext context, List<String?> candidateData, List<dynamic> rejectedData) {
        return MouseRegion(
          onEnter: (_) {
            if (_dragTargetState == _DragTargetInteractionState.none && _currentDraggedNodeId == null) {
              ref.read(hoveredNodeIdProvider.notifier).state = widget.node.id;
            }
          },
          onExit: (_) {
            if (ref.read(hoveredNodeIdProvider) == widget.node.id && _dragTargetState == _DragTargetInteractionState.none && _currentDraggedNodeId == null) {
              ref.read(hoveredNodeIdProvider.notifier).state = null;
            }
          },
          cursor: SystemMouseCursors.click,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomLeft,
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, _) { // Removed child param as interactiveItem is built outside
                  Color? currentBgColor;
                  Border? currentBorder;

                  switch (_dragTargetState) {
                    case _DragTargetInteractionState.canBeChild:
                      currentBorder = Border.all(color: Colors.greenAccent.shade400, width: 1.5);
                      currentBgColor = Colors.green.withOpacity(0.1);
                      break;
                    case _DragTargetInteractionState.animatingForSibling:
                      currentBorder = Border.all(
                        color: Colors.redAccent.shade400.withOpacity(_redBorderFadeAnimation.value),
                        width: 1.5,
                      );
                      // Background can also fade or change if desired
                      currentBgColor = Colors.red.withOpacity(0.08 * _redBorderFadeAnimation.value);
                      break;
                    case _DragTargetInteractionState.cannotBeChildOrSibling:
                      currentBorder = Border.all(color: Colors.redAccent.shade400, width: 1.5);
                      currentBgColor = Colors.red.withOpacity(0.08);
                      break;
                    case _DragTargetInteractionState.none:
                    default:
                      if (isActuallySelected) {
                        currentBgColor = Theme.of(context).colorScheme.primary.withOpacity(0.12);
                      } else if (isTreeItemDirectlyHovered) {
                        currentBgColor = kRendererHoverBorderColor.withOpacity(0.1);
                      }
                      break;
                  }
                  if (rejectedData.isNotEmpty && _dragTargetState != _DragTargetInteractionState.animatingForSibling) {
                    currentBorder = Border.all(color: Colors.redAccent.shade400, width: 1.5);
                    currentBgColor = Colors.red.withOpacity(0.08);
                  }

                  return Container(
                    margin: EdgeInsets.only(left: widget.depth * 16.0, top: 2, bottom: 2),
                    decoration: BoxDecoration(
                      color: currentBgColor,
                      border: currentBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: interactiveItem,
                  );
                },
              ),
              // Green line visibility and growth are now directly controlled by animation value in build method
              if (_dragTargetState == _DragTargetInteractionState.animatingForSibling && _greenLineGrowAnimation.value > 0.01)
                Positioned(
                  left: widget.depth * 16.0,
                  right: 0,
                  bottom: 0,
                  child: FractionallySizedBox(
                    widthFactor: _greenLineGrowAnimation.value, // Grows from left to right
                    alignment: Alignment.centerLeft, // Ensure it grows from the left
                    child: Container(
                      height: 3.0,
                      color: Colors.greenAccent.shade400,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}