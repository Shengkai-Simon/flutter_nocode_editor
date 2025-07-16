import '../../../constants/app_constants.dart';

class WidgetNode {
  final String id;
  final String type;
  final Map<String, dynamic> props;
  final List<WidgetNode> children;

  WidgetNode({
    required this.id,
    required this.type,
    this.props = const {},
    this.children = const [],
  });

  WidgetNode deepCopy() {
    return WidgetNode(
      id: id, // id is preserved in a deep copy
      type: type,
      props: Map<String, dynamic>.from(props), // Create a new map for props
      children: children.map((child) => child.deepCopy()).toList(), // Recursively deep copy children
    );
  }

  WidgetNode copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? props,
    List<WidgetNode>? children,
  }) {
    return WidgetNode(
      id: id ?? this.id,
      type: type ?? this.type,
      props: props ?? this.props,
      children: children ?? this.children,
    );
  }

  Map<String, dynamic> toJson() {
    // Filter out internal, editor-only properties that start with an underscore.
    final filteredProps = Map<String, dynamic>.from(props);
    filteredProps.removeWhere((key, value) => key.startsWith('_'));

    return {
      'id': id,
      'type': type,
      'props': filteredProps, // Use the filtered props
      'children': children.map((child) => child.toJson()).toList(),
    };
  }

  Map<String, dynamic> toJsonWithoutIds() {
    final filteredProps = Map<String, dynamic>.from(props);
    filteredProps.removeWhere((key, value) => key.startsWith('_'));
    return {
      'type': type,
      'props': filteredProps,
      'children': children.map((child) => child.toJsonWithoutIds()).toList(),
    };
  }

  factory WidgetNode.fromJson(Map<String, dynamic> json) {
    String? id = json['id'] as String?;
    if (id == null || id.isEmpty) {
      id = uuid.v4();
    }
    final String type = json['type'] as String? ?? 'Unknown';

    final Map<String, dynamic> props =
    Map<String, dynamic>.from(json['props'] as Map? ?? const {});

    final List<WidgetNode> children = (json['children'] as List<dynamic>?)
        ?.map((childJson) => WidgetNode.fromJson(childJson as Map<String, dynamic>))
        .toList() ??
        const [];

    return WidgetNode(
      id: id,
      type: type,
      props: props,
      children: children,
    );
  }
}
