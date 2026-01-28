import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/components/core/component_registry.dart';
import '../../editor/components/core/widget_node.dart';
import '../../editor/components/core/widget_node_utils.dart';
import '../../editor/properties/core/property_definition.dart';
import '../../services/issue_reporter_service.dart';
import '../../state/editor_state.dart';

/// A widget responsible for rendering the appropriate editor for a single
/// property (`PropField`) of a selected widget (`WidgetNode`).
class PropertyEditor extends ConsumerWidget {
  final WidgetNode node;
  final PropField field;

  const PropertyEditor({
    super.key,
    required this.node,
    required this.field,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamic rawPropValue = node.props[field.name];
    final dynamic currentValueForEditor = rawPropValue ?? field.defaultValue;

    // Called for live updates (e.g., slider dragging). Does NOT record history.
    void onUpdate(dynamic newValueFromField) {
      final Map<String, dynamic> updatedProps = Map<String, dynamic>.from(node.props);
      updatedProps[field.name] = newValueFromField;

      final updatedNode = node.copyWith(props: updatedProps);
      final currentGlobalTree = ref.read(activeCanvasTreeProvider);
      final newGlobalTree = replaceNodeInTree(currentGlobalTree, updatedNode);
      ref.read(projectStateProvider.notifier).updateActivePageTreeForPreview(newGlobalTree);
    }

    // Called on final submission (e.g., focus loss, enter). Records history.
    void onCommit(dynamic newValueFromField) {
      final Map<String, dynamic> updatedProps = Map<String, dynamic>.from(node.props);
      updatedProps[field.name] = newValueFromField;

      final updatedNode = node.copyWith(props: updatedProps);
      ref.read(projectStateProvider.notifier).updateWidgetNode(updatedNode);
    }

    if (field.editorBuilder != null) {
      if (field.editorBuilder is PropertyEditorBuilderWithUpdate) {
        // This is a modern editor that supports live updates.
        return field.editorBuilder!(
          context,
          node.props,
          field,
          currentValueForEditor,
          onCommit,
          onUpdate,
        );
      } else if (field.editorBuilder is PropertyEditorBuilder) {
        // This is a legacy editor.
        return field.editorBuilder!(
          context,
          node.props,
          field,
          currentValueForEditor,
          onCommit,
        );
      }
    }
    // Fallback for no editor or wrong type
    final rc = registeredComponents[node.type];
    IssueReporterService().reportWarning("Warning: No valid editorBuilder for property '${field.name}' in '${rc?.displayName ?? node.type}'.");
    return ListTile(
      title: Text(field.label),
      subtitle: Text(currentValueForEditor?.toString() ?? 'N/A (No editor)'),
    );
  }
}
