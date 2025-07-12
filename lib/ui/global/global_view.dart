import 'package:flutter/material.dart';
import 'package:flutter_editor/ui/global/page_card_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/editor_state.dart';

class GlobalView extends ConsumerWidget {
  const GlobalView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pages = ref.watch(projectStateProvider).pages;

    return GridView.builder(
      padding: const EdgeInsets.all(24.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 16 / 10,
      ),
      itemCount: pages.length,
      itemBuilder: (context, index) {
        final page = pages[index];
        return PageCardItem(page: page);
      },
    );
  }
}
