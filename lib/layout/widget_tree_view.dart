import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/component_registry.dart';
import '../core/editor_state.dart';
import '../core/widget_node.dart';

class WidgetTreeView extends ConsumerWidget {
  const WidgetTreeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WidgetNode rootNode = ref.watch(canvasTreeProvider);
    final String? selectedNodeId = ref.watch(selectedNodeIdProvider);
    final selectedNodeNotifier = ref.read(selectedNodeIdProvider.notifier);

    List<Widget> buildTreeNodes(WidgetNode node, int depth) {
      List<Widget> widgets = [];
      final RegisteredComponent? rc = registeredComponents[node.type];
      final String displayName = rc?.displayName ?? node.type;
      final IconData iconData = rc?.icon ?? Icons.device_unknown;
      final bool isSelected = node.id == selectedNodeId;

      widgets.add(
        Padding(
          padding: EdgeInsets.only(left: depth * 16.0),
          child: ListTile(
            dense: true,
            leading: Icon(iconData, size: 20, color: isSelected ? Theme.of(context).colorScheme.primary : null),
            title: Text(
              displayName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
            selected: isSelected,
            onTap: () {
              selectedNodeNotifier.state = node.id;
            },
          ),
        ),
      );

      if (node.children.isNotEmpty) {
        for (var child in node.children) {
          widgets.addAll(buildTreeNodes(child, depth + 1));
        }
      }
      return widgets;
    }

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: buildTreeNodes(rootNode, 0),
    );
  }
}