import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../editor/components/core/widget_node.dart';
import '../constants/app_constants.dart';

final uuid = Uuid();

enum LeftPanelMode {
  addWidgets,
  widgetTree,
  pages,
}

final leftPanelModeProvider = StateProvider<LeftPanelMode>((ref) => LeftPanelMode.addWidgets);

final canvasTreeProvider = StateProvider<WidgetNode>((ref) {
  return WidgetNode(
    id: uuid.v4(),
    type: 'Container',
    props: {'width': kRendererWidth, 'height': kRendererHeight, 'backgroundColor': '#eeeeee'},
    children: [],
  );
});

final selectedNodeIdProvider = StateProvider<String?>((ref) => null);
