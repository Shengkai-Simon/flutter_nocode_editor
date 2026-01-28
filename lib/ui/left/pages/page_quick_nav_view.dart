import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/editor_state.dart';

/// A view that is only used to quickly switch pages in page editing mode.
class PageQuickNavView extends ConsumerWidget {
  const PageQuickNavView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectState = ref.watch(projectStateProvider);
    final notifier = ref.read(projectStateProvider.notifier);
    final pages = projectState.pages;

    return ListView.builder(
      itemCount: pages.length,
      itemBuilder: (context, index) {
        final page = pages[index];
        final isActive = page.id == projectState.activePageId;
        final isInitial = page.id == projectState.initialPageId;
        return ListTile(
          selected: isActive,
          leading: Icon(isInitial ? Icons.home : Icons.article_outlined),
          title: Text(page.name),
          onTap: () => notifier.setActivePage(page.id),
        );
      },
    );
  }
}