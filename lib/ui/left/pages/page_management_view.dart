import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../editor/models/page_node.dart';
import '../../../state/editor_state.dart';
import 'page_list_item.dart';

class PageManagementView extends ConsumerWidget {
  const PageManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectState = ref.watch(projectStateProvider);
    final pages = projectState.pages;
    final notifier = ref.read(projectStateProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pages',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Tooltip(
                message: 'Add New Page',
                child: IconButton(
                  icon: const Icon(Icons.add_box_outlined),
                  onPressed: () => notifier.addPage(),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: pages.length,
            itemBuilder: (context, index) {
              final PageNode page = pages[index];
              return PageListItem(
                key: ValueKey(page.id),
                page: page,
                isActive: page.id == projectState.activePageId,
              );
            },
          ),
        ),
      ],
    );
  }
}