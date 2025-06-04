import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../editor/components/core/widget_node.dart';
import '../constants/app_constants.dart';
import '../services/issue_reporter_service.dart';

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
final isLoadingProjectProvider = StateProvider<bool>((ref) => false);
final hoveredNodeIdProvider = StateProvider<String?>((ref) => null);
final showLayoutBoundsProvider = StateProvider<bool>((ref) => false);

final dragRejectedDataProviderFor = StateProvider.family<List<dynamic>, String>((ref, nodeId) => []);

/// Stores the ID collection of all expanded WidgetNodes.
final expandedNodeIdsProvider = StateProvider<Set<String>>((ref) {
  final WidgetNode rootNode = ref.watch(canvasTreeProvider);
  return _getAllInitiallyExpandedNodeIds(rootNode);
});

/// Used to obtain the IDs of all nodes in the tree that have child nodes.
Set<String> _getAllInitiallyExpandedNodeIds(WidgetNode node) {
  final Set<String> ids = {};
  if (node.children.isNotEmpty) {
    ids.add(node.id);
    for (final child in node.children) {
      ids.addAll(_getAllInitiallyExpandedNodeIds(child));
    }
  }
  return ids;
}

class IssuesListNotifier extends StateNotifier<List<String>> {
  IssuesListNotifier() : super([]);

  void addIssue(String issue) {
    state = [...state, issue];
  }

  void addIssues(List<String> issues) {
    state = [...state, ...issues];
  }

  void clearIssues() {
    state = [];
  }
}

final projectErrorsNotifierProvider = StateNotifierProvider<IssuesListNotifier, List<String>>((ref) {
  final notifier = IssuesListNotifier();
  final StreamSubscription<String> sub = IssueReporterService().errorStream.listen((errorMsg) {
    notifier.addIssue(errorMsg);
  });
  ref.onDispose(() => sub.cancel());
  return notifier;
});

final projectWarningsNotifierProvider = StateNotifierProvider<IssuesListNotifier, List<String>>((ref) {
  final notifier = IssuesListNotifier();
  final StreamSubscription<String> sub = IssueReporterService().warningStream.listen((warningMsg) {
    notifier.addIssue(warningMsg);
  });
  ref.onDispose(() => sub.cancel());
  return notifier;
});

final projectErrorsProvider = Provider<List<String>>((ref) {
  return ref.watch(projectErrorsNotifierProvider);
});

final projectWarningsProvider = Provider<List<String>>((ref) {
  return ref.watch(projectWarningsNotifierProvider);
});