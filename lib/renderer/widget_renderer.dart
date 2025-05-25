import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/component_registry.dart';
import '../core/editor_state.dart';
import '../core/widget_node.dart';

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

    const tagBackgroundColor = Colors.blue;
    const tagTextColor = Colors.white;
    const double minVisibleWidth = 30.0;
    const double minVisibleHeight = 15.0;

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
            margin: const EdgeInsets.all(6.0),
            constraints: const BoxConstraints(
              minWidth: minVisibleWidth,
              minHeight: minVisibleHeight,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
                width: 1,
                style: isSelected ? BorderStyle.solid : BorderStyle.solid,
              ),
            ),
            child: actualComponentWidget,
          ),
          if (isSelected)
            Positioned(
              top: -8,
              left: -1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tagBackgroundColor,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  rc.displayName,
                  style: const TextStyle(
                    color: tagTextColor,
                    fontSize: 10,
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
