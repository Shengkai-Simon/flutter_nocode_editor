import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../editor/models/page_node.dart';
import '../../../state/editor_state.dart';
import 'delete_confirmation_dialog.dart';
import 'rename_page_dialog.dart';

class PageListItem extends ConsumerWidget {
  final PageNode page;
  final bool isActive;

  const PageListItem({
    super.key,
    required this.page,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(projectStateProvider.notifier);
    final canDelete = ref.watch(projectStateProvider).pages.length > 1;

    return Material(
      color: isActive ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
      child: InkWell(
        onTap: () => notifier.setActivePage(page.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Icon(
                Icons.article_outlined,
                color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  page.name,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? Theme.of(context).colorScheme.primary : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'rename') {
                    final newName = await showDialog<String>(
                      context: context,
                      builder: (_) => RenamePageDialog(currentPageName: page.name),
                    );
                    if (newName != null && newName.isNotEmpty) {
                      notifier.renamePage(page.id, newName);
                    }
                  } else if (value == 'delete') {
                    // A secondary confirmation box pops up
                    final bool? confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) =>
                          DeleteConfirmationDialog(
                            title: 'Delete Page?',
                            content: 'Are you sure you want to delete the page "${page.name}"? This action cannot be undone.',
                          ),
                    );
                    if (confirmed == true) {
                      notifier.deletePage(page.id);
                    }
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'rename',
                    child: Text('Rename'),
                  ),
                  if (canDelete) ...[
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}