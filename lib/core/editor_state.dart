import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widget_node.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

final canvasTreeProvider = StateProvider<WidgetNode>((ref) {
  return WidgetNode(
    id: uuid.v4(),
    type: 'Container',
    props: {'width': 400.0, 'height': 300.0, 'backgroundColor': '#eeeeee'},
    children: [],
  );
});

final selectedNodeIdProvider = StateProvider<String?>((ref) => null);
