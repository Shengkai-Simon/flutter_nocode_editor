import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_constants.dart';
import '../../editor/components/core/component_definition.dart';
import '../../editor/components/core/widget_node.dart';
import '../../editor/components/core/component_registry.dart';
import '../../editor/components/core/widget_node_utils.dart';
import '../../services/issue_reporter_service.dart';
import '../../state/editor_state.dart' hide uuid;

class WidgetRenderer extends ConsumerWidget {
  final WidgetNode node;

  const WidgetRenderer({super.key, required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedNodeIdProvider);
    final isSelected = selectedId == node.id;

    final rc = registeredComponents[node.type];
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

    return DragTarget<String>(
      builder: (BuildContext context, List<String?> candidateData, List<dynamic> rejectedData) {
        bool isHoveringOverTarget = candidateData.isNotEmpty;
        bool canAcceptDraggedItem = false;

        if (isHoveringOverTarget) {
          final String? draggedComponentType = candidateData.first;
          if (draggedComponentType != null && rc.childPolicy != ChildAcceptancePolicy.none) {
            if (rc.childPolicy == ChildAcceptancePolicy.single && node.children.isNotEmpty) {
              canAcceptDraggedItem = false;
            } else {
              canAcceptDraggedItem = true;
            }
          }
        }

        final borderColor = isSelected
            ? kRendererSelectedBorderColor
            : (isHoveringOverTarget && canAcceptDraggedItem
            ? Colors.greenAccent.shade400
            : kRendererUnselectedBorderColor);

        final borderWidth = isHoveringOverTarget && canAcceptDraggedItem ? 2.0 : 1.0;
        final backgroundColor = isHoveringOverTarget && canAcceptDraggedItem
            ? Colors.green.withOpacity(0.1)
            : null;


        return GestureDetector(
          onTap: () {
            ref.read(selectedNodeIdProvider.notifier).state = node.id;
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topLeft,
            children: [
              Container(
                margin: const EdgeInsets.all(kRendererWrapperMargin),
                constraints: const BoxConstraints(
                  minWidth: kRendererMinVisibleWidth,
                  minHeight: kRendererMinInteractiveHeight,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: borderColor,
                    width: borderWidth,
                    style: BorderStyle.solid,
                  ),
                  color: backgroundColor,
                ),
                child: actualComponentWidget,
              ),
              if (isSelected)
                Positioned(
                  top: -8,
                  left: kRendererWrapperMargin -1,
                  child: Container(
                    padding: kRendererTagPadding,
                    decoration: BoxDecoration(
                      color: kRendererTagBackgroundColor,
                      borderRadius: BorderRadius.circular(kRendererTagBorderRadius),
                    ),
                    child: Text(
                      rc.displayName,
                      style: const TextStyle(
                        color: kRendererTagTextColor,
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

        if (droppedRc == null) {
          IssueReporterService().reportError("Dropped unregistered component type: $droppedComponentType");
          return;
        }

        final newNode = WidgetNode(
          id: uuid.v4(),
          type: droppedComponentType,
          props: Map<String, dynamic>.from(droppedRc.defaultProps),
          children: [],
        );

        final currentTree = ref.read(canvasTreeProvider);
        final newTree = addNodeAsChildRecursive(currentTree, node.id, newNode);

        ref.read(canvasTreeProvider.notifier).state = newTree;
        ref.read(selectedNodeIdProvider.notifier).state = newNode.id;
      },
    );
  }
}