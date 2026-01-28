import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/models/page_node.dart';
import '../../state/editor_state.dart';
import '../left/pages/delete_confirmation_dialog.dart';
import '../left/pages/rename_page_dialog.dart';

class PageCardItem extends ConsumerWidget {
  final PageNode page;

  const PageCardItem({super.key, required this.page});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectState = ref.watch(projectStateProvider);
    final notifier = ref.read(projectStateProvider.notifier);
    final isInitialPage = projectState.initialPageId == page.id;
    final canDelete = projectState.pages.length > 1;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // When the card is tapped, switch to the editor view and record history
        onTap: () {
          notifier.setActivePage(page.id);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Colors.grey.shade200,
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        isInitialPage ? Icons.home_filled : Icons.article_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    if (isInitialPage)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: const Text(
                            'Initial',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: PopupMenuButton<String>(
                        tooltip: "Page Actions",
                        onSelected: (value) async {
                          switch (value) {
                            case 'rename':
                              final newName = await showDialog<String>(
                                context: context,
                                builder: (_) => RenamePageDialog(currentPageName: page.name),
                              );
                              if (newName != null && newName.isNotEmpty) {
                                notifier.renamePage(page.id, newName);
                              }
                              break;
                            case 'set_initial':
                              notifier.setInitialPage(page.id);
                              break;
                            case 'delete':
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (_) => DeleteConfirmationDialog(
                                  title: 'Delete Page?',
                                  content: 'Are you sure you want to delete "${page.name}"? This action cannot be undone.',
                                ),
                              );
                              if (confirmed == true) {
                                notifier.deletePage(page.id);
                              }
                              break;
                          }
                        },
                        itemBuilder: (context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(value: 'rename', child: Text('Rename')),
                          if (!isInitialPage)
                            const PopupMenuItem<String>(value: 'set_initial', child: Text('Set as Initial Page')),
                          if (canDelete) ...[
                            const PopupMenuDivider(),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete', style: TextStyle(color: Colors.red.shade700)),
                            ),
                          ]
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                page.name,
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
