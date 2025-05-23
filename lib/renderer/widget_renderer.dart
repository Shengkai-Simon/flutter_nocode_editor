import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/widget_node.dart';
import '../core/editor_state.dart';

class WidgetRenderer extends ConsumerWidget {
  final WidgetNode node;

  const WidgetRenderer({super.key, required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedNodeIdProvider);
    final isSelected = selectedId == node.id;

    Widget rendered;

    switch (node.type) {
      case 'Text':
        rendered = Text(
          node.props['text'] ?? '',
          style: TextStyle(
            fontSize: double.tryParse(node.props['fontSize']?.toString() ?? '') ?? 16,
            color: _parseColor(node.props['color']) ?? Colors.black,
          ),
        );
        break;

      case 'Container':
        rendered = Container(
          width: double.tryParse(node.props['width']?.toString() ?? '') ?? 200,
          height: double.tryParse(node.props['height']?.toString() ?? '') ?? 100,
          color: _parseColor(node.props['backgroundColor']) ?? Colors.grey[300],
          padding: const EdgeInsets.all(8),
          child: Column(
            children: node.children
                .map((child) => WidgetRenderer(node: child))
                .toList(),
          ),
        );
        break;

      default:
        rendered = const Text('Unsupported');
    }

    return GestureDetector(
      onTap: () {
        ref.read(selectedNodeIdProvider.notifier).state = node.id;
      },
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          color: Colors.blue.withValues(alpha: 13),
        )
            : null,
        padding: const EdgeInsets.all(4),
        child: rendered,
      ),
    );
  }

  Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final cleanHex = hex.replaceFirst('#', '');
    if (cleanHex.length != 6) return null;
    return Color(int.parse('FF$cleanHex', radix: 16));
  }
}
