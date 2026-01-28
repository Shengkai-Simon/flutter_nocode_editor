import 'package:flutter/material.dart';
import 'package:flutter_editor/ui/global/page_card_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/editor_state.dart';

class GlobalView extends ConsumerWidget {
  const GlobalView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pages = ref.watch(projectStateProvider).pages;
    final notifier = ref.read(projectStateProvider.notifier);

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 80.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1.1,
      ),

      itemCount: pages.length + 1,
      itemBuilder: (context, index) {
        if (index == pages.length) {
          return Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                width: 1,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
            elevation: 0,
            child: InkWell(
              onTap: () => notifier.addPage(),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Add New Page",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        final page = pages[index];
        return PageCardItem(page: page);
      },
    );
  }
}
