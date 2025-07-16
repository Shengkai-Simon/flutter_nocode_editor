import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_constants.dart';
import '../../editor/components/core/component_definition.dart';
import '../../editor/components/core/component_registry.dart';
import '../../editor/components/core/widget_node.dart';
import '../../editor/components/core/widget_node_utils.dart';
import '../../services/dnd_validation_service.dart';
import '../../state/editor_state.dart';
import '../../editor/components/core/component_types.dart' as ct;

class WidgetRenderer extends ConsumerWidget {
  final WidgetNode node;

  const WidgetRenderer({super.key, required this.node});

  /// Helper to identify widgets that have special layout requirements within a Flex parent.
  bool _isFlexWidget(String type) {
    return type == ct.expanded || type == ct.flexible || type == ct.spacer;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tree = ref.watch(activeCanvasTreeProvider);
    final parentNode = findParentNode(tree, node.id);

    final RegisteredComponent? rc = registeredComponents[node.type];
    if (rc == null) {
      return Container(
        constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
        padding: const EdgeInsets.all(8),
        color: Colors.red.withOpacity(0.1),
        child: Text('Unknown: ${node.type}', style: const TextStyle(color: Colors.red, fontSize: 10)),
      );
    }

    final actualComponentWidget = rc.builder(
      node, ref, (WidgetNode childNodeToRender) {
      return WidgetRenderer(node: childNodeToRender);
    },
    );

    if (_isFlexWidget(node.type)) {
      return actualComponentWidget;
    }

    return DragTarget<String>(
      builder: (BuildContext context, List<String?> candidateData, List<dynamic> rejectedDataList) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            final notifier = ref.read(dragRejectedDataProviderFor(node.id).notifier);
            if (rejectedDataList.isNotEmpty && notifier.state.isEmpty) {
              notifier.state = rejectedDataList;
            } else if (rejectedDataList.isEmpty && notifier.state.isNotEmpty) {
              notifier.state = [];
            }
          }
        });

        return Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (ref.read(hoveredNodeIdProvider) == node.id) {
                  ref.read(selectedNodeIdProvider.notifier).state = node.id;
                }
              },
              child: MouseRegion(
                onEnter: (_) {
                  ref.read(hoveredNodeIdProvider.notifier).state = node.id;
                  ref.read(dragTargetNodeIdProvider.notifier).state = node.id;
                },
                onExit: (_) {
                  ref.read(hoveredNodeIdProvider.notifier).state = parentNode?.id;
                  ref.read(dragTargetNodeIdProvider.notifier).state = parentNode?.id;
                },
                cursor: SystemMouseCursors.click,
                child: actualComponentWidget,
              ),
            ),
            _buildFeedbackOverlay(ref, rc.displayName),
          ],
        );
      },
      onWillAcceptWithDetails: (details) => _onWillAccept(ref, tree, details),
      onAcceptWithDetails: (details) => _onAccept(ref, tree, details),
    );
  }

  bool _onWillAccept(WidgetRef ref, WidgetNode tree, DragTargetDetails<String> details) {
    final activeDragTargetId = ref.read(dragTargetNodeIdProvider);
    if (activeDragTargetId != node.id) {
      return false;
    }
    return DndValidationService.canAcceptDrop(
      draggedItemData: details.data,
      targetNode: node,
      rootNode: tree,
    );
  }

  void _onAccept(WidgetRef ref, WidgetNode tree, DragTargetDetails<String> details) {
    final String droppedComponentType = details.data;
    final RegisteredComponent? droppedRc = registeredComponents[droppedComponentType];
    if (droppedRc == null) return;

    // Add the transient '_isNewlyAdded' flag when creating a new node.
    final newNode = WidgetNode(
      id: uuid.v4(),
      type: droppedComponentType,
      props: {
        ...Map<String, dynamic>.from(droppedRc.defaultProps),
        '_isNewlyAdded': true,
      },
    );
    // Correctly pass the newNode as the third argument.
    final newTree = addNodeAsChildRecursive(tree, node.id, newNode, insertAtStart: false);
    ref.read(projectStateProvider.notifier).updateActivePageTree(newTree);
    ref.read(selectedNodeIdProvider.notifier).state = newNode.id;
  }

  Widget _buildFeedbackOverlay(WidgetRef ref, String label) {
    final interactionMode = ref.watch(interactionModeProvider);
    final selectedId = ref.watch(selectedNodeIdProvider);
    final hoveredId = ref.watch(hoveredNodeIdProvider);
    final showLayoutBounds = ref.watch(showLayoutBoundsProvider);
    final dragTargetId = ref.watch(dragTargetNodeIdProvider);
    final isDropRejectedOnThisNode = ref.watch(dragRejectedDataProviderFor(node.id)).isNotEmpty;

    final isSelected = selectedId == node.id;
    final isHovered = hoveredId == node.id && !isSelected;

    bool isDragCandidate = false;
    bool isDragRejected = false;
    if (interactionMode == InteractionMode.dragging && dragTargetId == node.id) {
      isDragRejected = isDropRejectedOnThisNode;
      isDragCandidate = !isDropRejectedOnThisNode;
    }

    Color borderColor = Colors.transparent;
    double strokeWidth = 1.0;
    Color? highlightColor;
    bool showTag = false;
    Color tagBackgroundColor = Colors.transparent;
    Color tagTextColor = Colors.white;

    if (isDragCandidate) {
      borderColor = Colors.greenAccent.shade400;
      strokeWidth = 2.0;
      highlightColor = Colors.green.withOpacity(0.15);
      showTag = true;
      tagBackgroundColor = Colors.green.shade700;
      tagTextColor = Colors.white;
    } else if (isDragRejected) {
      borderColor = Colors.redAccent.shade400;
      strokeWidth = 2.0;
      highlightColor = Colors.red.withOpacity(0.12);
      showTag = true;
      tagBackgroundColor = Colors.red.shade700;
      tagTextColor = Colors.white;
    } else {
      if (isSelected) {
        borderColor = selectedBorderColor;
        strokeWidth = 1.5;
        showTag = true;
        tagBackgroundColor = selectedTagBackgroundColor;
        tagTextColor = selectedTagTextColor;
      } else if (isHovered) {
        borderColor = hoverBorderColor;
        strokeWidth = 1.5;
        showTag = true;
        tagBackgroundColor = hoverTagBackgroundColor;
        tagTextColor = hoverTagTextColor;
      } else if (showLayoutBounds) {
        borderColor = layoutBoundBorderColor;
        strokeWidth = 1.0;
      }
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: highlightColor,
                border: Border.all(
                  color: borderColor,
                  width: strokeWidth,
                ),
              ),
            ),
            if (showTag)
              Positioned(
                top: -kRendererTagPadding.bottom - strokeWidth,
                left: -strokeWidth,
                child: Container(
                  padding: kRendererTagPadding,
                  decoration: BoxDecoration(
                    color: tagBackgroundColor,
                    borderRadius: BorderRadius.circular(kRendererTagBorderRadius),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: tagTextColor,
                      fontSize: kRendererTagFontSize,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
