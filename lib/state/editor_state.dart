import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/components/core/widget_node.dart';
import '../constants/app_constants.dart';
import '../constants/device_sizes.dart';
import '../editor/components/core/widget_node_utils.dart';
import '../services/issue_reporter_service.dart';


enum LeftPanelMode {
  addWidgets,
  widgetTree,
  pages,
}

final leftPanelModeProvider = StateProvider<LeftPanelMode>((ref) => LeftPanelMode.addWidgets);

final selectedDeviceProvider = StateProvider<String>((ref) {
  return kPredefinedDeviceSizes.first.name;
});

final canvasTreeProvider = StateProvider<WidgetNode>((ref) {
  return createDefaultCanvasTree();
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

// --- UNDO/REDO ---
const int kMaxHistorySteps = 50;

class HistoryInfoState {
  final bool canUndo;
  final bool canRedo;
  const HistoryInfoState({required this.canUndo, required this.canRedo});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is HistoryInfoState &&
              runtimeType == other.runtimeType &&
              canUndo == other.canUndo &&
              canRedo == other.canRedo;

  @override
  int get hashCode => canUndo.hashCode ^ canRedo.hashCode;
}

class HistoryManager extends StateNotifier<HistoryInfoState> {
  final Ref _ref;
  List<WidgetNode> _history = [];
  int _currentIndex = -1; // Index of the current state in _history

  HistoryManager(this._ref)
      : super(const HistoryInfoState(canUndo: false, canRedo: false)) {
    // Initialize history with a deep copy of the initial canvas tree state
    final initialTree = _ref.read(canvasTreeProvider);
    _history = [deepCopyNode(initialTree)];
    _currentIndex = 0;
    _updateState(); // Set initial canUndo/canRedo state
  }

  // Public getters for direct checking if needed, though watching the state is preferred
  bool get currentCanUndo => _currentIndex > 0;
  bool get currentCanRedo => _currentIndex < _history.length - 1;

  void _updateState() {
    final newCanUndo = currentCanUndo;
    final newCanRedo = currentCanRedo;
    // Only update state if it actually changed to prevent unnecessary rebuilds
    if (state.canUndo != newCanUndo || state.canRedo != newCanRedo) {
      state = HistoryInfoState(canUndo: newCanUndo, canRedo: newCanRedo);
    }
  }

  void recordState(WidgetNode newTree) {
    final newStateCopy = deepCopyNode(newTree);

    if (_currentIndex < _history.length - 1) {
      _history = _history.sublist(0, _currentIndex + 1);
    }

    _history.add(newStateCopy);
    _currentIndex++; // Move pointer to the new state

    // Limit history size
    if (_history.length > kMaxHistorySteps) {
      _history.removeAt(0);
      _currentIndex--; // Adjust index because an element was removed from the beginning
    }

    // Update the live canvas tree provider with the recorded state
    _ref.read(canvasTreeProvider.notifier).state = newStateCopy;

    _updateState(); // Update canUndo/canRedo status
  }

  void undo() {
    if (currentCanUndo) {
      _currentIndex--;
      final historicState = _history[_currentIndex];
      // Set live state to a deep copy of the historic state
      _ref.read(canvasTreeProvider.notifier).state = deepCopyNode(historicState);
      _ref.read(selectedNodeIdProvider.notifier).state = null; // Deselect node
      _ref.read(hoveredNodeIdProvider.notifier).state = null;  // Clear hover
      _updateState();
    }
  }

  void redo() {
    if (currentCanRedo) {
      _currentIndex++;
      final historicState = _history[_currentIndex];
      // Set live state to a deep copy of the historic state
      _ref.read(canvasTreeProvider.notifier).state = deepCopyNode(historicState);
      _ref.read(selectedNodeIdProvider.notifier).state = null; // Deselect node
      _ref.read(hoveredNodeIdProvider.notifier).state = null;  // Clear hover
      _updateState();
    }
  }

  void resetWithInitialState(WidgetNode initialState) {
    final initialStateCopy = deepCopyNode(initialState); // Deep copy
    _history = [initialStateCopy];
    _currentIndex = 0;
    _ref.read(canvasTreeProvider.notifier).state = initialStateCopy;
    _ref.read(selectedNodeIdProvider.notifier).state = null;
    _ref.read(hoveredNodeIdProvider.notifier).state = null;
    _updateState();
  }
}

final historyManagerProvider =
StateNotifierProvider<HistoryManager, HistoryInfoState>((ref) {
  return HistoryManager(ref);
});