import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/components/core/widget_node.dart';
import '../constants/app_constants.dart';
import '../constants/device_sizes.dart';
import '../editor/components/core/widget_node_utils.dart';
import '../editor/models/page_node.dart';
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

/// Encapsulates the state of the entire project。
class ProjectState {
  final List<PageNode> pages;
  final String activePageId;
  final String initialPageId;

  const ProjectState({required this.pages, required this.activePageId, required this.initialPageId});

  /// Gets the page that is currently being edited.
  PageNode get activePage => pages.firstWhere((p) => p.id == activePageId);

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
  }

  /// Updates the currently active page's WidgetNode tree.
  void updateActivePageTree(WidgetNode newTree) {
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
    state = state.copyWith(pages: newPages, activePageId: newPage.id);
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
    ref.read(historyManagerProvider.notifier).recordState(newTree);
  }

  /// Set up the project's splash page.
  void setInitialPage(String pageId) {
    if (state.pages.any((p) => p.id == pageId)) {
      state = state.copyWith(initialPageId: pageId);
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
  }

  /// Set the currently active page.
  void setActivePage(String pageId) {
    if (state.activePageId != pageId && state.pages.any((p) => p.id == pageId)) {
      state = state.copyWith(activePageId: pageId);
    }
  }
}

/// Globally unique project status provider.
final projectStateProvider = StateNotifierProvider<ProjectNotifier, ProjectState>((ref) {
  return ProjectNotifier(ref);
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

/// An inner helper class that encapsulates the history of a single page.
class _PageHistory {
    final List<WidgetNode> stack = [];
    int currentIndex = -1;
}

class HistoryManager extends StateNotifier<HistoryInfoState> {
  final Ref _ref;
  final Map<String, _PageHistory> _pageHistories = {};

  HistoryManager(this._ref)
      : super(const HistoryInfoState(canUndo: false, canRedo: false)) {
    // Listen for changes in project status to react when pages are added, deleted, or switched.
    _ref.listen<ProjectState>(projectStateProvider, (previous, next) {
      _syncHistoriesWithProjectState(next);
      _updateState(next.activePageId);
    }, fireImmediately: true);
  }

  /// Synchronize history based on project status
  void _syncHistoriesWithProjectState(ProjectState project) {
    // Create a history for new pages
    for (final page in project.pages) {
      if (!_pageHistories.containsKey(page.id)) {
        _pageHistories[page.id] = _PageHistory()
          ..stack.add(deepCopyNode(page.tree))
          ..currentIndex = 0;
      }
    }
    // Remove the history of deleted pages
    _pageHistories.removeWhere((pageId, _) => !project.pages.any((p) => p.id == pageId));
  }

  void _updateState(String activePageId) {
    final history = _pageHistories[activePageId];
    final canUndo = history != null && history.currentIndex > 0;
    final canRedo = history != null && history.currentIndex < history.stack.length - 1;

    if (state.canUndo != canUndo || state.canRedo != canRedo) {
      state = HistoryInfoState(canUndo: canUndo, canRedo: canRedo);
    }
  }

  void recordState(WidgetNode newTree) {
    final activePageId = _ref.read(projectStateProvider).activePageId;
    final history = _pageHistories[activePageId];
    if (history == null) return;

    final newStateCopy = deepCopyNode(newTree);

    if (history.currentIndex < history.stack.length - 1) {
      history.stack.removeRange(history.currentIndex + 1, history.stack.length);
    }

    history.stack.add(newStateCopy);
    history.currentIndex++;

    if (history.stack.length > kMaxHistorySteps) {
      history.stack.removeAt(0);
      history.currentIndex--;
    }

    _ref.read(projectStateProvider.notifier).updateActivePageTree(newStateCopy);
    _updateState(activePageId);
  }

  void undo() {
    final activePageId = _ref.read(projectStateProvider).activePageId;
    final history = _pageHistories[activePageId];
    if (history == null || history.currentIndex <= 0) return;

    history.currentIndex--;
    final historicState = history.stack[history.currentIndex];

    _ref.read(projectStateProvider.notifier).updateActivePageTree(deepCopyNode(historicState));
    _ref.read(selectedNodeIdProvider.notifier).state = null;
    _ref.read(hoveredNodeIdProvider.notifier).state = null;
    _updateState(activePageId);
  }

  void redo() {
    final activePageId = _ref.read(projectStateProvider).activePageId;
    final history = _pageHistories[activePageId];
    if (history == null || history.currentIndex >= history.stack.length - 1) {
      return;
    }

    history.currentIndex++;
    final historicState = history.stack[history.currentIndex];

    _ref.read(projectStateProvider.notifier).updateActivePageTree(deepCopyNode(historicState));
    _ref.read(selectedNodeIdProvider.notifier).state = null;
    _ref.read(hoveredNodeIdProvider.notifier).state = null;
    _updateState(activePageId);
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

/// 定义画布指针的模式
enum CanvasPointerMode {
  select, // Select Mode (Default)
  pan,    // Pan/gripper mode
}

/// Manages the mode of the current canvas pointer
final canvasPointerModeProvider = StateProvider<CanvasPointerMode>((ref) => CanvasPointerMode.select);

/// Manages whether the Ctrl key is currently being pressed down.
/// This is used to conditionally enable behaviors like scroll-to-zoom.
final isCtrlPressedProvider = StateProvider<bool>((ref) => false);