import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_constants.dart';
import '../../editor/components/core/widget_node.dart';
import '../../editor/components/core/component_registry.dart';
import '../../editor/components/core/component_definition.dart';
import '../../state/editor_state.dart' hide uuid;
import '../../editor/components/core/widget_node_utils.dart';

class WidgetRenderer extends ConsumerWidget {
  final WidgetNode node;

  const WidgetRenderer({super.key, required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedNodeIdProvider);
    final isSelected = selectedId == node.id;

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

    return DragTarget<String>(
      builder: (BuildContext context, List<String?> candidateData, List<dynamic> rejectedDataList) {
        Color effektiveBorderColor;
        double effektiveBorderWidth = 1.0;
        Color? effektiveHoverBackgroundColor;

        if (candidateData.isNotEmpty) {
          effektiveBorderColor = Colors.greenAccent.shade400;
          effektiveBorderWidth = 2.0;
          effektiveHoverBackgroundColor = Colors.green.withOpacity(0.15);
        } else if (rejectedDataList.isNotEmpty) {
          effektiveBorderColor = Colors.redAccent.shade400;
          effektiveBorderWidth = 2.0;
          effektiveHoverBackgroundColor = Colors.red.withOpacity(0.12);
        } else {
          if (isSelected) {
            effektiveBorderColor = kRendererSelectedBorderColor;
          } else {
            effektiveBorderColor = kRendererUnselectedBorderColor;
          }
        }

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
                    color: effektiveBorderColor,
                    width: effektiveBorderWidth,
                    style: BorderStyle.solid,
                  ),
                ),
                child: actualComponentWidget,
              ),

              if (effektiveHoverBackgroundColor != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      margin: const EdgeInsets.all(kRendererWrapperMargin),
                      decoration: BoxDecoration(
                        color: effektiveHoverBackgroundColor,
                        ),
                    ),
                  ),
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

        if (droppedRc == null) return;

        final newNode = WidgetNode(
          id: uuid.v4(),
          type: droppedComponentType,
          props: Map<String, dynamic>.from(droppedRc.defaultProps),
        );

        final currentTree = ref.read(canvasTreeProvider);
        final newTree = addNodeAsChildRecursive(currentTree, node.id, newNode);

        ref.read(canvasTreeProvider.notifier).state = newTree;
        ref.read(selectedNodeIdProvider.notifier).state = newNode.id;
      },
    );
  }
}