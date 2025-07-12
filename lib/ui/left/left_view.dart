import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/components/core/component_registry.dart';
import '../../editor/components/core/component_definition.dart';
import '../../state/editor_state.dart';
import 'palette_component_item.dart';
import 'pages/page_quick_nav_view.dart';
import 'widget_tree/widget_tree_view.dart';

class LeftView extends ConsumerWidget {
  const LeftView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // LeftView displays different content depending on the state of the leftPanelModeProvider
    return switch (ref.watch(leftPanelModeProvider)) {
      LeftPanelMode.addWidgets => _buildAddComponentSection(context, ref),
      LeftPanelMode.widgetTree => const WidgetTreeView(),
      LeftPanelMode.pages      => const PageQuickNavView(),
    };
  }

  String _getCategoryDisplayName(ComponentCategory category) {
    switch (category) {
      case ComponentCategory.layout: return 'Layout Widgets';
      case ComponentCategory.content: return 'Content & Display';
      case ComponentCategory.input: return 'Input & Controls';
      case ComponentCategory.other: return 'Other Widgets';
    }
  }

  Widget _buildAddComponentSection(BuildContext context, WidgetRef ref) {
    final allComponents = registeredComponents.values.toList();
    final theme = Theme.of(context);

    final Map<ComponentCategory, List<RegisteredComponent>> categorizedComponents = {};
    for (var component in allComponents) {
      (categorizedComponents[component.category] ??= []).add(component);
    }

    final List<ComponentCategory> categoryOrder = [
      ComponentCategory.layout,
      ComponentCategory.content,
      ComponentCategory.input,
      ComponentCategory.other,
    ];

    List<Widget> sectionWidgets = [];
    for (var category in categoryOrder) {
      final componentsInCategory = categorizedComponents[category];
      if (componentsInCategory != null && componentsInCategory.isNotEmpty) {
        sectionWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 12.0, right: 12.0, bottom: 8.0),
            child: Text(
              _getCategoryDisplayName(category),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
          ),
        );
        sectionWidgets.add(
          GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: componentsInCategory.map((rc) {
              return Draggable<String>(
                data: rc.type,
                feedback: Material(
                  elevation: 4.0,
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(rc.icon ?? Icons.extension, size: 20, color: Theme.of(context).colorScheme.onSecondaryContainer),
                        const SizedBox(width: 8),
                        Text(rc.displayName, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSecondaryContainer)),
                      ],
                    ),
                  ),
                ),
                childWhenDragging: Opacity(opacity: 0.4, child: PaletteComponentItem(rc: rc, theme: theme)),
                child: PaletteComponentItem(rc: rc, theme: theme),
              );
            }).toList(),
          ),
        );
      }
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 12.0),
      children: sectionWidgets,
    );
  }
}