import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/component_registry.dart';
import '../core/editor_state.dart';
import '../core/widget_node.dart';

class LeftPanel extends ConsumerWidget {
  const LeftPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uuid = const Uuid();
    final componentList = registeredComponents.values.toList();

    void addComponent(String type) {
      final rc = registeredComponents[type];
      if (rc == null) return;

      final newNode = WidgetNode(
        id: uuid.v4(), // Ensure uuid is initialized, e.g., final uuid = Uuid(); at class or file level
        type: rc.type,
        props: Map<String, dynamic>.from(rc.defaultProps),
        children: [],
      );

      final selectedId = ref.read(selectedNodeIdProvider);
      final currentTree = ref.read(canvasTreeProvider);

      WidgetNode? targetParentNode;
      if (selectedId == null) {
        targetParentNode = currentTree;
      } else {
        targetParentNode = _findNodeInTreeById(currentTree, selectedId);
      }

      if (targetParentNode != null &&
          targetParentNode.type == 'Container' &&
          targetParentNode.children.isNotEmpty) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "'${targetParentNode.type}' (ID: ${targetParentNode.id.substring(0, 8)}) can only hold one child. "
                  "Please remove the existing child or select a different parent.",
            ),
            backgroundColor: Colors.orangeAccent,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      print('=========================================================');
      print('Attempting to add component: ${rc.type} (ID: ${newNode.id})');
      print('Target Parent ID: $selectedId');
      if (targetParentNode != null) {
        print('Actual Parent Node for adding: {id: ${targetParentNode.id}, type: ${targetParentNode.type}, childrenCount: ${targetParentNode.children.length}}');
      } else if (selectedId != null) {
        print('Warning: Target Parent ID $selectedId not found in tree. Adding to root.');
      }
      print('Current Tree BEFORE modification: ${currentTree.toJson()}');

      final newTree = _addChildToTree(currentTree, selectedId, newNode);

      print('New Tree AFTER modification: ${newTree.toJson()}');
      print('=========================================================');

      ref.read(canvasTreeProvider.notifier).state = newTree;
      ref.read(selectedNodeIdProvider.notifier).state = newNode.id;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Components',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            padding: const EdgeInsets.all(12),
            children: componentList.map((rc) {
              return GestureDetector(
                onTap: () => addComponent(rc.type),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(rc.icon ?? Icons.extension, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              rc.displayName,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  WidgetNode? _findNodeInTreeById(WidgetNode root, String id) {
    if (root.id == id) return root;
    for (final child in root.children) {
      final found = _findNodeInTreeById(child, id);
      if (found != null) return found;
    }
    return null;
  }

  WidgetNode _addChildToTree(WidgetNode root, String? parentId, WidgetNode newChild) {
    if (parentId == null || root.id == parentId) {
      return root.copyWith(children: [...root.children, newChild]);
    }

    return root.copyWith(
      children: root.children.map((c) => _addChildToTree(c, parentId, newChild)).toList(),
    );
  }
}
