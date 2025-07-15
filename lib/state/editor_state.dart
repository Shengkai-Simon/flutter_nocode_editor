import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/components/core/widget_node.dart';
import '../constants/app_constants.dart';
import '../constants/device_sizes.dart';
import '../editor/components/core/widget_node_utils.dart';
import '../editor/models/page_node.dart';
import '../services/issue_reporter_service.dart';
import 'view_mode_state.dart';

enum LeftPanelMode {
  addWidgets,
  widgetTree,
  pages,
}

final leftPanelModeProvider = StateProvider<LeftPanelMode>((ref) => LeftPanelMode.addWidgets);

final selectedDeviceProvider = StateProvider<String>((ref) {
  // Default to the first device in the first category
  return kPredefinedDeviceCategories.first.devices.first.name;
});

/// Encapsulates the state of the entire project。
class ProjectState {
  final List<PageNode> pages;
  final String activePageId;
  final String initialPageId;

  const ProjectState({required this.pages, required this.activePageId, required this.initialPageId});

  /// Gets the page that is currently being edited.
  PageNode get activePage => pages.firstWhere((p) => p.id == activePageId, orElse: () => pages.first);

  ProjectState deepCopy() {
    return ProjectState(
      pages: pages.map((p) => p.deepCopy()).toList(),
      activePageId: activePageId,
      initialPageId: initialPageId,
    );
  }

  ProjectState copyWith({
    List<PageNode>? pages,
    String? activePageId,
    String? initialPageId,
  }) {
    return ProjectState(
      pages: pages ?? this.pages,
      activePageId: activePageId ?? this.activePageId,
      initialPageId: initialPageId ?? this.initialPageId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pages': pages.map((p) => p.toJson()).toList(),
      'activePageId': activePageId,
      'initialPageId': initialPageId,
    };
  }

  factory ProjectState.fromJson(Map<String, dynamic> json) {
    final pages = (json['pages'] as List<dynamic>)
        .map((pageJson) => PageNode.fromJson(pageJson as Map<String, dynamic>))
        .toList();

    return ProjectState(
      pages: pages,
      activePageId: json['activePageId'] as String? ?? pages.first.id,
      initialPageId: json['initialPageId'] as String? ?? pages.first.id,
    );
  }
}

/// The core of the project state Notifier。
class ProjectNotifier extends StateNotifier<ProjectState> {
  final Ref ref;
  ProjectNotifier(this.ref) : super(_createInitialState());

  static ProjectState _createInitialState() {
    final defaultPage = PageNode(
      id: uuid.v4(),
      name: 'Main Page',
      tree: createDefaultCanvasTree(),
    );
    return ProjectState(
      pages: [defaultPage],
      activePageId: defaultPage.id,
      initialPageId: defaultPage.id,
    );
  }

  /// Replaces the entire current project state with a new one.
  /// This is used when loading a project from a file.
  void loadProject(ProjectState newProjectState) {
    state = newProjectState;
    // We don't record history here as this is a "load" operation,
    // which should clear the existing history. The caller can decide
    // to record an initial state if needed.
  }

  /// Updates a specific widget node within the active page.
  /// This is the new primary method for component property changes.
  void updateWidgetNode(WidgetNode updatedNode) {
    final activePage = state.activePage;
    final newTree = replaceNodeInTree(activePage.tree, updatedNode);
    state = state.copyWith(
      pages: state.pages.map((page) {
        if (page.id == state.activePageId) {
          return page.copyWith(tree: newTree);
        }
        return page;
      }).toList(),
    );
    ref.read(historyManagerProvider.notifier).recordState(state);
  }

  /// Replaces the entire WidgetNode tree of the currently active page.
  /// This action is recorded in the history.
  void updateActivePageTree(WidgetNode newTree) {
    state = state.copyWith(
      pages: state.pages.map((page) {
        if (page.id == state.activePageId) {
          return page.copyWith(tree: newTree);
        }
        return page;
      }).toList(),
    );
    ref.read(historyManagerProvider.notifier).recordState(state);
  }

  /// Updates the currently active page's WidgetNode tree FOR PREVIEW ONLY.
  /// This does NOT record a history state.
  void updateActivePageTreeForPreview(WidgetNode newTree) {
    state = state.copyWith(
      pages: state.pages.map((page) {
        if (page.id == state.activePageId) {
          return page.copyWith(tree: newTree);
        }
        return page;
      }).toList(),
    );
  }

  /// Adds a new page to the project.
  void addPage() {
    int pageCounter = 1;
    String newPageName;
    do {
      newPageName = 'New Page $pageCounter';
      pageCounter++;
    } while (state.pages.any((p) => p.name == newPageName));

    final newPage = PageNode(
      id: uuid.v4(),
      name: newPageName,
      tree: createDefaultCanvasTree(),
    );

    final newPages = [...state.pages, newPage];
    state = state.copyWith(pages: newPages);
    ref.read(historyManagerProvider.notifier).recordState(state);
  }

  /// Deletes a page from the project.
  void deletePage(String pageId) {
    if (state.pages.length <= 1) {
      IssueReporterService().reportWarning("Cannot delete the last page of the project.");
      return;
    }

    final newPages = state.pages.where((p) => p.id != pageId).toList();
    String newActivePageId = state.activePageId;
    String newInitialPageId = state.initialPageId;

    if (state.activePageId == pageId) {
      newActivePageId = newPages.first.id;
    }
    // If the deleted page was the initial page, set the first page as the new initial.
    if (state.initialPageId == pageId) {
      newInitialPageId = newPages.first.id;
    }

    state = state.copyWith(
        pages: newPages,
        activePageId: newActivePageId,
        initialPageId: newInitialPageId
    );
    ref.read(historyManagerProvider.notifier).recordState(state);
  }

  /// Reorders a page in the list.
  void reorderPage(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final newPages = List<PageNode>.from(state.pages);
    final item = newPages.removeAt(oldIndex);
    newPages.insert(newIndex, item);
    state = state.copyWith(pages: newPages);
    ref.read(historyManagerProvider.notifier).recordState(state);
  }

  /// Import a WidgetNode tree and replace the contents of the specified page.
  /// This action is tracked by the history
  void importTreeForPage(String pageId, WidgetNode newTree) {
    // Locate the page you want to replace
    final targetPage = state.pages.firstWhere((p) => p.id == pageId);
    // Create an updated page object
    final updatedPage = targetPage.copyWith(tree: newTree);
    // Replace the old page object in the entire page list
    final newPages = state.pages.map((p) => p.id == pageId ? updatedPage : p).toList();
    // Update the status
    state = state.copyWith(pages: newPages);
    // Record new trees into history
    ref.read(historyManagerProvider.notifier).recordState(state);
  }

  /// Set up the project's splash page.
  void setInitialPage(String pageId) {
    if (state.pages.any((p) => p.id == pageId)) {
      state = state.copyWith(initialPageId: pageId);
      ref.read(historyManagerProvider.notifier).recordState(state);
    }
  }

  /// Renames a specific page.
  void renamePage(String pageId, String newName) {
    if (newName.trim().isEmpty) {
      IssueReporterService().reportWarning("Page name cannot be empty.");
      return;
    }
    if (state.pages.any((p) => p.name == newName && p.id != pageId)) {
      IssueReporterService().reportWarning('Page name "$newName" already exists.');
      return;
    }

    state = state.copyWith(
      pages: state.pages.map((p) {
        if (p.id == pageId) {
          p.name = newName;
        }
        return p;
      }).toList(),
    );
    ref.read(historyManagerProvider.notifier).recordState(state);
  }

  /// Set the currently active page.
  void setActivePage(String pageId) {
    if (state.activePageId != pageId && state.pages.any((p) => p.id == pageId)) {
      state = state.copyWith(activePageId: pageId);
      // Switching pages is not a state change that should be recorded in history.
    }
  }
}

/// Globally unique project status provider.
final projectStateProvider = StateNotifierProvider<ProjectNotifier, ProjectState>((ref) {
  final notifier = ProjectNotifier(ref);
  // Record the initial state of the project as the first entry in history.
  ref.read(historyManagerProvider.notifier).recordState(notifier.state);
  return notifier;
});

/// Derives the Widget tree from the currently active page.
/// The UI component will listen to this provider, not directly to the projectProvider.
final activeCanvasTreeProvider = Provider<WidgetNode>((ref) {
  final projectState = ref.watch(projectStateProvider);
  return projectState.activePage.tree;
});

final selectedNodeIdProvider = StateProvider<String?>((ref) => null);
final isLoadingProjectProvider = StateProvider<bool>((ref) => false);
final hoveredNodeIdProvider = StateProvider<String?>((ref) => null);
final showLayoutBoundsProvider = StateProvider<bool>((ref) => false);

final dragRejectedDataProviderFor = StateProvider.family<List<dynamic>, String>((ref, nodeId) => []);

/// Stores the ID collection of all expanded WidgetNodes.
final expandedNodeIdsProvider = StateProvider<Set<String>>((ref) {
  final WidgetNode rootNode = ref.watch(activeCanvasTreeProvider);
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
  void addIssue(String issue) => state = [...state, issue];
  void addIssues(List<String> issues) => state = [...state, ...issues];
  void clearIssues() => state = [];
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
  final List<ProjectState> _history = [];
  int _historyIndex = -1;

  HistoryManager(this._ref) : super(const HistoryInfoState(canUndo: false, canRedo: false));

  void _updateState() {
    final canUndo = _historyIndex > 0;
    final canRedo = _historyIndex < _history.length - 1;

    if (state.canUndo != canUndo || state.canRedo != canRedo) {
      state = HistoryInfoState(canUndo: canUndo, canRedo: canRedo);
    }
  }

  void recordState(ProjectState projectState) {
    // When a new state is recorded, discard any "redo" states.
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    _history.add(projectState.deepCopy());
    _historyIndex++;

    // Limit the history size
    if (_history.length > kMaxHistorySteps) {
      _history.removeAt(0);
      _historyIndex--;
    }
    _updateState();
  }

  void _restoreState(ProjectState historicState) {
    final selectedIdBeforeRestore = _ref.read(selectedNodeIdProvider);
    final activePageIdBeforeRestore = _ref.read(projectStateProvider).activePageId;

    ProjectState stateToLoad;
    final pageExists = historicState.pages.any((p) => p.id == activePageIdBeforeRestore);

    if (pageExists) {
      // The page we were on still exists, so we keep it active.
      stateToLoad = historicState.copyWith(activePageId: activePageIdBeforeRestore);
    } else {
      // The page was deleted by this undo/redo. Reset to the historic state's own
      // active page (which is guaranteed to be valid) and switch to the overview.
      stateToLoad = historicState;
      _ref.read(mainViewProvider.notifier).state = MainView.overview;
    }

    _ref.read(projectStateProvider.notifier).loadProject(stateToLoad);

    // Restore selected node if it still exists on the active page
    if (selectedIdBeforeRestore != null) {
      final activePage = stateToLoad.pages.firstWhere((p) => p.id == stateToLoad.activePageId, orElse: () => stateToLoad.pages.first);
      final nodeStillExists = findNodeById(activePage.tree, selectedIdBeforeRestore) != null;
      if (!nodeStillExists) {
        _ref.read(selectedNodeIdProvider.notifier).state = null;
      }
    }
    _ref.read(hoveredNodeIdProvider.notifier).state = null;
    _updateState();
  }

  void undo() {
    if (_historyIndex <= 0) return;

    _historyIndex--;
    final historicState = _history[_historyIndex];
    _restoreState(historicState);
  }

  void redo() {
    if (_historyIndex >= _history.length - 1) return;

    _historyIndex++;
    final historicState = _history[_historyIndex];
    _restoreState(historicState);
  }
}

final historyManagerProvider =
StateNotifierProvider<HistoryManager, HistoryInfoState>((ref) {
  return HistoryManager(ref);
});

/// Manage the zoom of the canvas.
/// 1.0 = 100%, 0.5 = 50%。
/// The special value of 0.0 represents the "Fit to Screen" mode.
final canvasScaleProvider = StateProvider<double>((ref) => 0.0);

/// Defines the pattern of the canvas pointer
enum CanvasPointerMode {
  select, // Select Mode (Default)
  pan,    // Pan/gripper mode
}

/// Manages the mode of the current canvas pointer
final canvasPointerModeProvider = StateProvider<CanvasPointerMode>((ref) => CanvasPointerMode.select);

/// Manages whether the Ctrl key is currently being pressed down.
/// This is used to conditionally enable behaviors like scroll-to-zoom.
final isCtrlPressedProvider = StateProvider<bool>((ref) => false);
