import '../../constants/app_constants.dart';
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

  PageNode deepCopy() {
    return PageNode(
      id: id,
      name: name,
      tree: tree.deepCopy(), // Deep copy the widget tree
    );
  }

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tree': tree.toJson(),
    };
  }

  factory PageNode.fromJson(Map<String, dynamic> json) {
    return PageNode(
      id: json['id'] as String? ?? uuid.v4(),
      name: json['name'] as String? ?? 'Untitled Page',
      tree: WidgetNode.fromJson(json['tree'] as Map<String, dynamic>),
    );
  }
}