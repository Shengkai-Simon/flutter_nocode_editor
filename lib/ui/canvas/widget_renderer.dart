import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_constants.dart';
import '../../editor/components/core/component_model.dart';
import '../../editor/components/core/component_registry.dart';
import '../../state/editor_state.dart';

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
        constraints: const BoxConstraints(minWidth: 30, minHeight: 30), // Min size for unknown too
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
                color: isSelected ? kRendererSelectedBorderColor : kRendererUnselectedBorderColor,
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
            child: actualComponentWidget,
          ),
          if (isSelected)
            Positioned(
              top: -8,
              left: -1,
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
  }
}
