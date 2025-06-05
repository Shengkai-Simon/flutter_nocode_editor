import 'package:flutter_editor/editor/components/core/component_definition.dart';
import 'package:flutter_editor/editor/components/core/component_registry.dart';

import '../../../services/issue_reporter_service.dart';
import 'widget_node.dart';

/// Finds a node by its ID within the given root node.
WidgetNode? findNodeById(WidgetNode root, String? id) {
  if (id == null) return null;
  if (root.id == id) return root;
  for (final child in root.children) {
    final result = findNodeById(child, id);
    if (result != null) return result;
  }
  return null;
}

/// Finds the parent of a node with the given childId. Returns null if not found or if childId is the root.
WidgetNode? findParentNode(WidgetNode root, String childId) {
  if (root.id == childId) return null; // Root has no parent in this context

  for (final child in root.children) {
    if (child.id == childId) {
      return root; // Found parent
    }
    final parentInChild = findParentNode(child, childId);
    if (parentInChild != null) {
      return parentInChild;
    }
  }
  return null;
}


/// Replaces a node in the tree with an updated version of that node.
WidgetNode replaceNodeInTree(WidgetNode root, WidgetNode updatedNode) {
  if (root.id == updatedNode.id) return updatedNode;
  return root.copyWith(
    children: root.children.map((c) => replaceNodeInTree(c, updatedNode)).toList(),
  );
}

/// Adds a new child node to a target parent node within the tree.
WidgetNode addNodeAsChildRecursive(WidgetNode currentNode, String targetParentId, WidgetNode newChild) {
  if (currentNode.id == targetParentId) {
    final parentDef = registeredComponents[currentNode.type];
    if (parentDef == null) {
      IssueReporterService().reportError("Could not find component definition for parent type ${currentNode.type}");
      // Could not find component definition for parent type [type]
      return currentNode;
    }

    if (parentDef.childPolicy == ChildAcceptancePolicy.none) {
      IssueReporterService().reportWarning("Attempted to add child to ${currentNode.type} which does not accept children.");
      // Attempted to add child to [type] which does not accept children.
      return currentNode;
    }
    if (parentDef.childPolicy == ChildAcceptancePolicy.single && currentNode.children.isNotEmpty) {
      IssueReporterService().reportWarning("Attempted to add child to ${currentNode.type} which already has a single child.");
      // Attempted to add child to [type] which already has a single child.
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

/// Removes a node by its ID from the tree.
WidgetNode removeNodeById(WidgetNode root, String targetId) {
  if (root.id == targetId) {
    IssueReporterService().reportWarning("Attempted to remove the root node via removeNodeById. This is not allowed. Returning root.");
    // Attempted to remove the root node via removeNodeById. This is not allowed. Returning root.
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

/// Inserts a node as a sibling to a target sibling node.
/// If `after` is true, inserts after the targetSiblingId, otherwise before.
WidgetNode insertNodeAsSiblingRecursive(WidgetNode root, String targetSiblingId, WidgetNode nodeToInsert, {bool after = true}) {
  final parentNode = findParentNode(root, targetSiblingId);
  if (parentNode == null) {
    IssueReporterService().reportWarning("Cannot insert sibling for '$targetSiblingId': parent not found or target is root.");
    // Cannot insert sibling for '[targetSiblingId]': parent not found or target is root.
    return root; // Or handle error appropriately
  }

  final parentDef = registeredComponents[parentNode.type];
  if (parentDef == null) {
    IssueReporterService().reportError("Could not find component definition for parent type ${parentNode.type} when inserting sibling.");
    // Could not find component definition for parent type [type] when inserting sibling.
    return root;
  }
  if (parentDef.childPolicy == ChildAcceptancePolicy.none) {
    IssueReporterService().reportWarning("Cannot add sibling to child of ${parentNode.type} because parent does not accept children (should not happen if parent has children).");
    // Cannot add sibling to child of [type] because parent does not accept children.
    return root;
  }
  if (parentDef.childPolicy == ChildAcceptancePolicy.single) {
    // This case is tricky. If it's single, we can't add another one.
    // The onWillAccept logic should prevent this, but as a safeguard:
    IssueReporterService().reportWarning("Cannot add sibling to child of ${parentNode.type} because parent only accepts a single child.");
    // Cannot add sibling to child of [type] because parent only accepts a single child.
    return root;
  }


  List<WidgetNode> newSiblings = List.from(parentNode.children);
  int targetIndex = newSiblings.indexWhere((s) => s.id == targetSiblingId);

  if (targetIndex == -1) {
    IssueReporterService().reportWarning("Cannot insert sibling for '$targetSiblingId': target sibling not found in parent's children list.");
    // Cannot insert sibling for '[targetSiblingId]': target sibling not found in parent's children list.
    return root;
  }

  if (after) {
    if (targetIndex == newSiblings.length - 1) {
      newSiblings.add(nodeToInsert);
    } else {
      newSiblings.insert(targetIndex + 1, nodeToInsert);
    }
  } else {
    newSiblings.insert(targetIndex, nodeToInsert);
  }

  final updatedParent = parentNode.copyWith(children: newSiblings);
  return replaceNodeInTree(root, updatedParent);
}


/// Checks if a node (potentialAncestorId) is an ancestor of another node (nodeId).
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
    return false; // NodeId not found in the tree
  }

  // Path now contains the path from root to nodeId
  int nodeIndexInPath = path.indexOf(nodeId);
  if (nodeIndexInPath == -1) return false; // Should not happen if findPath was true

  // Check if potentialAncestorId is in the path before nodeId
  for (int i = 0; i < nodeIndexInPath; i++) {
    if (path[i] == potentialAncestorId) {
      return true;
    }
  }
  return false;
}

/// Creates a deep copy of a WidgetNode.
WidgetNode deepCopyNode(WidgetNode node) {
  return WidgetNode(
    id: node.id, // Keep the same ID for the copy if it's representing the same logical entity being moved
    type: node.type,
    props: Map<String, dynamic>.from(node.props), // Deep copy props if they can be mutable
    children: node.children.map((child) => deepCopyNode(child)).toList(),
  );
}