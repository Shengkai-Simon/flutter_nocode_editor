import 'package:flutter_editor/editor/components/core/component_definition.dart';
import 'package:flutter_editor/editor/components/core/component_registry.dart';
import 'package:uuid/uuid.dart';

import '../../../services/issue_reporter_service.dart';
import 'widget_node.dart';

final uuid = Uuid();

WidgetNode? findNodeById(WidgetNode root, String? id) {
  if (id == null) return null;
  if (root.id == id) return root;
  for (final child in root.children) {
    final result = findNodeById(child, id);
    if (result != null) return result;
  }
  return null;
}

WidgetNode replaceNodeInTree(WidgetNode root, WidgetNode updatedNode) {
  if (root.id == updatedNode.id) return updatedNode;
  return root.copyWith(
    children: root.children.map((c) => replaceNodeInTree(c, updatedNode)).toList(),
  );
}

WidgetNode addNodeAsChildRecursive(WidgetNode currentNode, String targetParentId, WidgetNode newChild) {
  if (currentNode.id == targetParentId) {
    final parentDef = registeredComponents[currentNode.type];
    if (parentDef == null) {
      IssueReporterService().reportError("Could not find component definition for parent type ${currentNode.type}");
      return currentNode;
    }

    if (parentDef.childPolicy == ChildAcceptancePolicy.none) {
      IssueReporterService().reportWarning("Attempted to add child to ${currentNode.type} which does not accept children.");
      return currentNode;
    }
    if (parentDef.childPolicy == ChildAcceptancePolicy.single && currentNode.children.isNotEmpty) {
      IssueReporterService().reportWarning("Attempted to add child to ${currentNode.type} which already has a single child.");
      return currentNode;
    }

    final List<WidgetNode> updatedChildren = List.from(currentNode.children)..add(newChild);
    return currentNode.copyWith(children: updatedChildren);
  }

  List<WidgetNode> newChildrenList = [];
  bool childrenChanged = false;
  for (var child in currentNode.children) {
    final updatedChild = addNodeAsChildRecursive(child, targetParentId, newChild);
    if (!identical(child, updatedChild)) {
      childrenChanged = true;
    }
    newChildrenList.add(updatedChild);
  }

  if (childrenChanged) {
    return currentNode.copyWith(children: newChildrenList);
  }
  return currentNode;
}

WidgetNode removeNodeById(WidgetNode root, String targetId) {
  if (root.id == targetId) {
    IssueReporterService().reportWarning("Attempted to remove the root node via removeNodeById. This is not allowed. Returning root.");
    return root;
  }

  List<WidgetNode> newChildren = [];
  bool childWasRemoved = false;

  for (final child in root.children) {
    if (child.id == targetId) {
      childWasRemoved = true;
    } else {
      newChildren.add(removeNodeById(child, targetId));
    }
  }

  bool treeActuallyChanged = childWasRemoved;
  if (!treeActuallyChanged && newChildren.length == root.children.length) {
    for (int i = 0; i < newChildren.length; i++) {
      if (!identical(newChildren[i], root.children[i])) {
        treeActuallyChanged = true;
        break;
      }
    }
  }

  if (treeActuallyChanged) {
    return root.copyWith(children: newChildren);
  } else {
    return root;
  }
}

bool isAncestor(WidgetNode? root, String potentialAncestorId, String nodeId) {
  if (root == null) return false;

  List<String> path = [];
  bool findPath(WidgetNode currentNode, String targetId, List<String> currentPath) {
    currentPath.add(currentNode.id);
    if (currentNode.id == targetId) {
      return true;
    }
    for (var child in currentNode.children) {
      if (findPath(child, targetId, currentPath)) {
        return true;
      }
    }
    currentPath.removeLast();
    return false;
  }

  if (!findPath(root, nodeId, path)) {
    return false;
  }

  int nodeIndex = path.indexOf(nodeId);
  int ancestorIndex = path.indexOf(potentialAncestorId);

  return ancestorIndex != -1 && ancestorIndex < nodeIndex;
}