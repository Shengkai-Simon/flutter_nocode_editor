import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../editor/components/core/component_definition.dart';
import '../../../editor/components/core/component_registry.dart';
import '../../../editor/components/core/widget_node.dart';
import '../../../editor/components/core/widget_node_utils.dart';
import '../../../state/editor_state.dart';
import 'tree_line_painter.dart';

/// A drop target for inserting widgets between other widgets in the tree.
/// It appears as a line in the gap between items.
class GapDropTarget extends ConsumerStatefulWidget {
  final WidgetNode parentNode;
  final int targetIndex;
  final WidgetNode overallRootNode;
  final int depth;
  final bool isLastInSiblings;
  final List<bool> ancestorIsLastList;

  const GapDropTarget({
    super.key,
    required this.parentNode,
    required this.targetIndex,
    required this.overallRootNode,
    required this.depth,
    required this.isLastInSiblings,
    required this.ancestorIsLastList,
  });

  @override
  ConsumerState<GapDropTarget> createState() => _GapDropTargetState();
}

class _GapDropTargetState extends ConsumerState<GapDropTarget> {
  bool _isDragOver = false;
  bool _isValidIntent = false;

  bool _canAccept(String draggedNodeId) {
    if (isAncestor(widget.overallRootNode, draggedNodeId, widget.parentNode.id)) {
      return false;
    }

    if (draggedNodeId == widget.parentNode.id) {
      return false;
    }

    final WidgetNode? draggedNode = findNodeById(widget.overallRootNode, draggedNodeId);
    if (draggedNode == null) return false;

    final draggedRc = registeredComponents[draggedNode.type];
    if (draggedRc == null) return false;

    if (draggedRc.allowedParentTypes != null && !draggedRc.allowedParentTypes!.contains(widget.parentNode.type)) {
      return false;
    }

    if (draggedRc.disallowedParentTypes != null && draggedRc.disallowedParentTypes!.contains(widget.parentNode.type)) {
      return false;
    }

    final parentRc = registeredComponents[widget.parentNode.type];
    if (parentRc == null) return false;
    if (parentRc.childPolicy == ChildAcceptancePolicy.none) return false;
    if (parentRc.childPolicy == ChildAcceptancePolicy.single) {
      final isExistingChild = widget.parentNode.children.any((child) => child.id == draggedNodeId);
      return widget.parentNode.children.isEmpty || (widget.parentNode.children.length == 1 && isExistingChild);
    }

    return true;
  }

  void _handleAccept(String draggedNodeId) {
    ref.read(projectStateProvider.notifier).moveNode(
      draggedNodeId: draggedNodeId,
      newParentId: widget.parentNode.id,
      newIndex: widget.targetIndex,
    );
    
    if (mounted) {
      setState(() {
        _isDragOver = false;
        _isValidIntent = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDraggingActive = ref.watch(interactionModeProvider) == InteractionMode.dragging;

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) {
        if (!isDraggingActive) return false;
        final canAccept = _canAccept(details.data);
        if (mounted) {
          setState(() {
            _isDragOver = true;
            _isValidIntent = canAccept;
          });
        }
        return canAccept;
      },
      onLeave: (data) {
        if (mounted) {
          setState(() {
            _isDragOver = false;
            _isValidIntent = false;
          });
        }
      },
      onAccept: (draggedNodeId) {
        _handleAccept(draggedNodeId);
      },
      builder: (context, candidateData, rejectedData) {
        if (!isDraggingActive || !_isDragOver) {
          return const SizedBox(height: 4.0);
        }

        Color? lineColor;
        if (candidateData.isNotEmpty && _isValidIntent) {
          lineColor = Colors.greenAccent.shade400;
        } else if (rejectedData.isNotEmpty || (candidateData.isNotEmpty && !_isValidIntent)) {
          lineColor = Colors.redAccent.shade400;
        }
        
        final double treeLinesPainterAreaWidth = widget.depth * TreeLinePainter.indentWidth;

        return Container(
          height: 16.0,
          alignment: Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: treeLinesPainterAreaWidth,
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: lineColor != null
                      ? Container(height: 3.0, color: lineColor)
                      : const SizedBox(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 