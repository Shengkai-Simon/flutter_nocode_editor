import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_constants.dart';
import '../../editor/components/core/widget_node.dart';
import '../../editor/components/core/component_registry.dart';
import '../../editor/components/core/component_definition.dart';
import '../../state/editor_state.dart';
import '../../editor/components/core/widget_node_utils.dart';

class WidgetRenderer extends ConsumerWidget {
  final WidgetNode node;

  const WidgetRenderer({super.key, required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tree = ref.watch(activeCanvasTreeProvider);
    final parentNode = findParentNode(tree, node.id);

    final selectedId = ref.watch(selectedNodeIdProvider);
    final hoveredId = ref.watch(hoveredNodeIdProvider);
    final showLayoutBounds = ref.watch(showLayoutBoundsProvider);

    final bool isActuallySelected = selectedId == node.id;
    final bool isActuallyHovered = hoveredId == node.id && !isActuallySelected;

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

    return MouseRegion(
      onEnter: (_) {
        ref.read(hoveredNodeIdProvider.notifier).state = node.id;
      },
      onExit: (_) {
        ref.read(hoveredNodeIdProvider.notifier).state = parentNode?.id;
      },
      cursor: SystemMouseCursors.click,
      child: DragTarget<String>(
        builder: (BuildContext context, List<String?> candidateData, List<dynamic> rejectedDataList) {
          Color effectiveBorderColor = Colors.transparent;
          double effectiveBorderWidth = 1.0;
          Color? effectiveHoverBackgroundColor;

          bool showTag = false;
          String tagText = rc.displayName;
          Color tagBackgroundColor = Colors.transparent;
          Color tagTextColor = Colors.white;

          if (candidateData.isNotEmpty) {
            effectiveBorderColor = Colors.greenAccent.shade400;
            effectiveBorderWidth = 2.0;
            effectiveHoverBackgroundColor = Colors.green.withOpacity(0.15);
          } else if (rejectedDataList.isNotEmpty) {
            effectiveBorderColor = Colors.redAccent.shade400;
            effectiveBorderWidth = 2.0;
            effectiveHoverBackgroundColor = Colors.red.withOpacity(0.12);
          } else {
            if (isActuallySelected) {
              effectiveBorderColor = selectedBorderColor;
              effectiveBorderWidth = 1.5;
              showTag = true;
              tagBackgroundColor = selectedTagBackgroundColor;
              tagTextColor = selectedTagTextColor;
            }
            else if (isActuallyHovered) {
              effectiveBorderColor = hoverBorderColor;
              effectiveBorderWidth = 1.5;
              showTag = true;
              tagBackgroundColor = hoverTagBackgroundColor;
              tagTextColor = hoverTagTextColor;
            }
            else if (showLayoutBounds) {
              effectiveBorderColor = layoutBoundBorderColor;
              effectiveBorderWidth = 1.0;
            }
          }

          return GestureDetector(
            onTap: () {
              if (!isActuallySelected) {
                ref.read(selectedNodeIdProvider.notifier).state = node.id;
              }
            },
            behavior: HitTestBehavior.deferToChild,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topLeft,
              children: [
                Container(
                  margin: const EdgeInsets.all(kRendererWrapperMargin),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: effectiveBorderColor,
                      width: effectiveBorderWidth,
                    ),
                  ),
                  child: actualComponentWidget,
                ),
                if (effectiveHoverBackgroundColor != null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        margin: const EdgeInsets.all(kRendererWrapperMargin),
                        decoration: BoxDecoration(
                          color: effectiveHoverBackgroundColor,
                        ),
                      ),
                    ),
                  ),
                if (showTag)
                  Positioned(
                    top: -8,
                    left: kRendererWrapperMargin -1,
                    child: Container(
                      padding: kRendererTagPadding,
                      decoration: BoxDecoration(
                        color: tagBackgroundColor,
                        borderRadius: BorderRadius.circular(kRendererTagBorderRadius),
                      ),
                      child: Text(
                        tagText,
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
          );
        },
        onWillAcceptWithDetails: (DragTargetDetails<String> details) {
          if (rc.childPolicy == ChildAcceptancePolicy.none) {
            return false;
          }
          if (rc.childPolicy == ChildAcceptancePolicy.single && node.children.isNotEmpty) {
            return false;
          }
          return true;
        },
        onAcceptWithDetails: (DragTargetDetails<String> details) {
          final String droppedComponentType = details.data;
          final RegisteredComponent? droppedRc = registeredComponents[droppedComponentType];

          if (droppedRc == null) return;

          final newNode = WidgetNode(
            id: uuid.v4(),
            type: droppedComponentType,
            props: Map<String, dynamic>.from(droppedRc.defaultProps),
          );

          final currentTree = ref.read(activeCanvasTreeProvider);
          final newTree = addNodeAsChildRecursive(currentTree, node.id, newNode);

          ref.read(projectStateProvider.notifier).updateActivePageTree(newTree);
          ref.read(selectedNodeIdProvider.notifier).state = newNode.id;
        },
      ),
    );
  }
}