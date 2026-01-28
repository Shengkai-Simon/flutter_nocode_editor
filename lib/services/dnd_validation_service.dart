import '../editor/components/core/component_definition.dart';
import '../editor/components/core/component_registry.dart';
import '../editor/components/core/widget_node.dart';

/// A dedicated service for handling Drag and Drop validation logic.
class DndValidationService {
  /// Determines if a target node can accept a dragged item.
  ///
  /// This is the central authority for all drop validation on the canvas.
  ///
  /// [draggedItemData]: The data from the Draggable, which is the component type string.
  /// [targetNode]: The WidgetNode that is the potential drop target.
  /// [rootNode]: The root of the entire widget tree, used for context.
  static bool canAcceptDrop({
    required String draggedItemData,
    required WidgetNode targetNode,
    required WidgetNode rootNode,
  }) {
    final String draggedComponentType = draggedItemData;
    final RegisteredComponent? draggedRc = registeredComponents[draggedComponentType];
    final RegisteredComponent? targetRc = registeredComponents[targetNode.type];

    // Rule 0: Ensure both components are registered and valid.
    if (draggedRc == null || targetRc == null) {
      return false;
    }

    // Rule 1: Check the target's child policy.
    // Can the target node accept any children at all?
    if (targetRc.childPolicy == ChildAcceptancePolicy.none) {
      return false;
    }
    // If it only accepts one child, does it already have one?
    if (targetRc.childPolicy == ChildAcceptancePolicy.single && targetNode.children.isNotEmpty) {
      return false;
    }

    // Rule 2: Check the dragged component's parent requirements.
    // Does the dragged component require a specific type of parent?
    if (draggedRc.allowedParentTypes != null && draggedRc.allowedParentTypes!.isNotEmpty) {
      // If so, is the target node's type in the allowed list?
      if (!draggedRc.allowedParentTypes!.contains(targetNode.type)) {
        return false;
      }
    }

    // Rule 3: Check for disallowed parent types.
    if (draggedRc.disallowedParentTypes != null && draggedRc.disallowedParentTypes!.contains(targetNode.type)) {
      return false;
    }

    // If it's a drag from the tree (reordering), we would also check for self-nesting here.
    // Since we are only handling drags from the palette for now, this is not needed.
    // final bool isSelfOrDescendant = isAncestor(rootNode, targetNode.id, draggedItemData);
    // if (isSelfOrDescendant) {
    //   return false;
    // }

    // If all rules pass, the drop is valid.
    return true;
  }
}
