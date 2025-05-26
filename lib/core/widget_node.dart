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
    return {
      'id': id,
      'type': type,
      'props': props,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }

  factory WidgetNode.fromJson(Map<String, dynamic> json) {
    final String id = json['id'] as String? ?? '';
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