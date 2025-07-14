import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web/web.dart' as web;

import '../constants/app_constants.dart';
import '../editor/components/core/widget_node.dart';
import '../editor/models/page_node.dart';
import '../services/issue_reporter_service.dart';
import '../services/project_migrator_service.dart';
import '../state/editor_state.dart';

/// Encapsulates the logic that triggers file downloads in a web environment.
Future<void> downloadFileOnWeb(String content, String fileName, {String type = 'application/json'}) async {
  try {
    final blob = web.Blob([content.toJS].toJS, web.BlobPropertyBag(type: type));
    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = fileName;
    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    web.URL.revokeObjectURL(url);
  } catch (e, s) {
    IssueReporterService().reportError(
      "Error during file download",
      source: "file_io_web.downloadFileOnWeb",
      error: e,
      stackTrace: s,
    );
  }
}

/// Packages the given files into a ZIP and downloads it.
Future<void> downloadProjectAsZip(Map<String, String> files, {String zipFileName = 'flutter_project.zip'}) async {
  final issueService = IssueReporterService();
  try {
    final encoder = ZipEncoder();
    final archive = Archive();

    files.forEach((fileName, content) {
      final fileBytes = utf8.encode(content);
      final archiveFile = ArchiveFile(fileName, fileBytes.length, fileBytes);
      archive.addFile(archiveFile);
    });

    final zipBytes = encoder.encode(archive);
    if (zipBytes == null) {
      issueService.reportError("Failed to encode zip file: encoder returned null.", source: "file_io_web.downloadProjectAsZip");
      return;
    }

    final blob = web.Blob([Uint8List.fromList(zipBytes).toJS].toJS, web.BlobPropertyBag(type: 'application/zip'));
    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = zipFileName;
    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    web.URL.revokeObjectURL(url);
  } catch (e, s) {
    issueService.reportError(
      "Error creating or downloading zip file",
      source: "file_io_web.downloadProjectAsZip",
      error: e,
      stackTrace: s,
    );
  }
}


/// Encapsulates the logic of opening a file picker and reading the contents of a file in a web environment.
/// If the user deselects, null is returned.
Future<String?> pickAndReadFileAsStringOnWeb(WidgetRef ref) async {
  final completer = Completer<String?>();
  final issueService = IssueReporterService();

  final uploadInput = web.document.createElement('input') as web.HTMLInputElement;
  uploadInput.type = 'file';
  uploadInput.accept = '.json';

  void onFileSelected(web.Event event) {
    final web.HTMLInputElement eventInputTarget = event.currentTarget as web.HTMLInputElement;
    final web.FileList? files = eventInputTarget.files;

    if (files != null && files.length > 0 && files.item(0) != null) {
      final selectedFile = files.item(0)!;
      final reader = web.FileReader();

      reader.onloadend = ((web.Event loadEndEvent) {
        try {
          final jsResult = reader.result;
          if (jsResult != null && !jsResult.isUndefinedOrNull && jsResult.isA<JSString>()) {
            completer.complete((jsResult as JSString).toDart);
          } else {
            completer.complete(null);
          }
        } catch (e, s) {
          issueService.reportError(
            "Failed to read file content.",
            source: "file_io_web.pickAndReadFileAsStringOnWeb",
            error: e,
            stackTrace: s,
          );
          completer.complete(null);
        }
      }).toJS;

      reader.onerror = ((web.Event errorEvent) {
        issueService.reportError(
          "Error reading file: ${selectedFile.name}",
          source: "FileReader",
          error: reader.error,
        );
        completer.complete(null);
      }).toJS;

      reader.readAsText(selectedFile);
    } else {
      completer.complete(null);
    }
  }

  JSFunction? jsChangeCallbackHolder = onFileSelected.toJS;
  uploadInput.addEventListener('change', jsChangeCallbackHolder);

  // Handle cases where the user clicks the cancel button
  web.window.addEventListener('focus', ((web.Event event) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (uploadInput.files != null && uploadInput.files!.length == 0 && !completer.isCompleted) {
        completer.complete(null);
      }
    });
  }).toJS);

  try {
    uploadInput.click();
  } catch(e, s) {
    issueService.reportError("Failed to trigger file selection dialog.", source: "FileLoader", error: e, stackTrace: s);
    completer.complete(null);
  }

  return completer.future;
}

/// Save the entire project as a JSON file.
Future<void> saveProjectToFile(WidgetRef ref) async {
  final projectState = ref.read(projectStateProvider);
  final versionedProjectData = {
    'version': '2.0',
    'project': projectState.toJson(),
  };
  const jsonEncoder = JsonEncoder.withIndent('  ');
  final jsonString = jsonEncoder.convert(versionedProjectData);
  await downloadFileOnWeb(jsonString, 'flutter_project.json');
}

/// Load a complete project file and replace the entire project.
Future<void> loadProjectFromFile(WidgetRef ref) async {
  if (ref.read(isLoadingProjectProvider)) return;
  ref.read(isLoadingProjectProvider.notifier).state = true;

  final String? fileContent = await pickAndReadFileAsStringOnWeb(ref);

  if (fileContent != null && fileContent.isNotEmpty) {
    try {
      final jsonMap = jsonDecode(fileContent) as Map<String, dynamic>;
      if (jsonMap['version'] == '2.0' && jsonMap['project'] != null) {
        final newProjectState = ProjectState.fromJson(jsonMap['project']);
        ref.read(projectStateProvider.notifier).loadProject(newProjectState);
      } else {
        final migrator = ProjectMigratorService();
        final WidgetNode newTree = migrator.migrate(jsonMap);
        final newPage = PageNode(id: uuid.v4(), name: 'Imported Page', tree: newTree);
        final newProjectState = ProjectState(pages: [newPage], activePageId: newPage.id, initialPageId: newPage.id);
        ref.read(projectStateProvider.notifier).loadProject(newProjectState);
      }
    } catch (e, s) {
      IssueReporterService().reportError("Failed to parse project from file.", error: e, stackTrace: s);
    }
  }
  // Use .context to securely access the BuildContext
  if (ref.context.mounted) ref.read(isLoadingProjectProvider.notifier).state = false;
}

// --- Page-level actions (Page Level Actions) ---

/// Save the currently active page as a separate JSON file.
Future<void> saveCurrentPageToFile(WidgetRef ref) async {
  final activeTree = ref.read(activeCanvasTreeProvider);
  final versionedProjectData = {
    ProjectSchemaKeys.schemaVersion: kCurrentProjectSchemaVersion,
    ProjectSchemaKeys.projectData: activeTree.toJson(),
  };
  const jsonEncoder = JsonEncoder.withIndent('  ');
  final jsonString = jsonEncoder.convert(versionedProjectData);
  await downloadFileOnWeb(jsonString, 'flutter_editor_page.json');
}

/// Load the JSON file and replace the currently active page.
Future<void> loadAndReplaceCurrentPage(WidgetRef ref) async {
  if (ref.read(isLoadingProjectProvider)) return;
  ref.read(isLoadingProjectProvider.notifier).state = true;

  final String? fileContent = await pickAndReadFileAsStringOnWeb(ref);

  if (fileContent != null && fileContent.isNotEmpty) {
    try {
      final jsonMap = jsonDecode(fileContent) as Map<String, dynamic>;
      final migrator = ProjectMigratorService();
      final WidgetNode newTree = migrator.migrate(jsonMap);
      ref.read(historyManagerProvider.notifier).recordState(newTree);
    } catch (e, s) {
      IssueReporterService().reportError("Failed to parse page layout from file.", error: e, stackTrace: s);
    }
  }
  if (ref.context.mounted) ref.read(isLoadingProjectProvider.notifier).state = false;
}