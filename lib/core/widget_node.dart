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
}