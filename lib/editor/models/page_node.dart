import '../components/core/widget_node.dart';

/// Represents an editable page in the editor。
class PageNode {
  final String id;
  String name;
  final WidgetNode tree;

  PageNode({
    required this.id,
    required this.name,
    required this.tree,
  });

  PageNode copyWith({
    String? id,
    String? name,
    WidgetNode? tree,
  }) {
    return PageNode(
      id: id ?? this.id,
      name: name ?? this.name,
      tree: tree ?? this.tree,
    );
  }
}