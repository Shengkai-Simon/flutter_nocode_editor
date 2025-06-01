import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web/web.dart' as web;

import '../../editor/components/core/widget_node.dart';
import '../../services/issue_reporter_service.dart';
import '../../state/editor_state.dart';

class CanvasToolbar extends ConsumerWidget {
  const CanvasToolbar({super.key});

  void _saveProject(BuildContext context, WidgetNode tree) {
    try {
      final jsonMap = tree.toJson();
      const jsonEncoder = JsonEncoder.withIndent('  ');
      final jsonString = jsonEncoder.convert(jsonMap);

      final blob = web.Blob([jsonString.toJS].toJS, web.BlobPropertyBag(type: 'application/json'));
      final url = web.URL.createObjectURL(blob);
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = url;
      anchor.download = 'flutter_editor_project.json';
      web.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      web.URL.revokeObjectURL(url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Project saved successfully!"), backgroundColor: Colors.green),
      );
    } catch (e, s) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving project: $e"), backgroundColor: Colors.red),
      );
      IssueReporterService().reportError("Error during project save", source: "ProjectSave", error: e, stackTrace: s);
    }
  }

  void _loadProject(BuildContext context, WidgetRef ref) {
    if (ref.read(isLoadingProjectProvider)) {
      return;
    }

    ref.read(isLoadingProjectProvider.notifier).state = true;

    final issueService = IssueReporterService();
    final uploadInput = web.document.createElement('input') as web.HTMLInputElement;
    uploadInput.type = 'file';
    uploadInput.accept = '.json';

    JSFunction? jsChangeCallbackHolder;
    JSFunction? jsWindowFocusCallbackHolder;
    bool changeEventHasProcessed = false;

    void dartChangeCallbackBody(web.Event event) {
      changeEventHasProcessed = true;
      if (jsChangeCallbackHolder != null) {
        uploadInput.removeEventListener('change', jsChangeCallbackHolder);
        jsChangeCallbackHolder = null;
      }
      if (jsWindowFocusCallbackHolder != null) {
        web.window.removeEventListener('focus', jsWindowFocusCallbackHolder);
        jsWindowFocusCallbackHolder = null;
      }

      final web.HTMLInputElement eventInputTarget = event.currentTarget as web.HTMLInputElement;
      final web.FileList? files = eventInputTarget.files;

      web.File? selectedFile;
      if (files != null && files.length > 0 && files.item(0) != null) {
        selectedFile = files.item(0)!;
      }

      eventInputTarget.value = '';
      if (selectedFile != null) {
        ref.read(projectErrorsNotifierProvider.notifier).clearIssues();
        ref.read(projectWarningsNotifierProvider.notifier).clearIssues();

        final reader = web.FileReader();
        reader.onloadend = ((web.Event loadEndEvent) {
          String fileContent = "";
          try {
            final jsResult = reader.result;
            if (jsResult == null || jsResult.isUndefinedOrNull) {
              fileContent = "";
              issueService.reportWarning("FileReader result was null or undefined for file: ${selectedFile?.name}", source: "FileReader");
            } else if (jsResult.isA<JSString>()) {
              fileContent = (jsResult as JSString).toDart;
            } else {
              fileContent = jsResult.toString();
              issueService.reportWarning("FileReader result was NOT a JSString for file: ${selectedFile?.name}. Type: ${jsResult.runtimeType}. Using Dart .toString().", source: "FileReader");
            }

            if (fileContent.trim().isEmpty && !(jsResult == null || jsResult.isUndefinedOrNull) ) {
              issueService.reportWarning("Loaded file ('${selectedFile?.name}') content is effectively empty after processing.", source: "FileLoader");
            }

            if (fileContent.trim().isNotEmpty) {
              final jsonMap = jsonDecode(fileContent) as Map<String, dynamic>;
              final WidgetNode newTree = WidgetNode.fromJson(jsonMap);
              ref.read(canvasTreeProvider.notifier).state = newTree;
              ref.read(selectedNodeIdProvider.notifier).state = null;
            }

            Future.microtask(() {
              if (!context.mounted) return;
              final errors = ref.read(projectErrorsProvider);
              final warnings = ref.read(projectWarningsProvider);
              if (errors.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Project loaded with errors. Check 'Project Issues' panel."), backgroundColor: Colors.redAccent));
              } else if (warnings.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Project loaded with warnings. Check 'Project Issues' panel."), backgroundColor: Colors.orangeAccent));
              } else if (fileContent.trim().isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Project loaded successfully!"), backgroundColor: Colors.green));
              }
            });
          } catch (err, s) {
            issueService.reportError("Failed to parse project data from '${selectedFile?.name}'.", source: "ProjectParser", error: err, stackTrace: s);
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to parse project. See 'Project Issues' for details."), backgroundColor: Colors.red));
          } finally {
            if(context.mounted) ref.read(isLoadingProjectProvider.notifier).state = false;
          }
        }).toJS;

        reader.onerror = ((web.Event errorEvent) {
          final errorMessage = "Error reading file: ${selectedFile?.name}";
          issueService.reportError(errorMessage, source: "FileReader", error: reader.error);
          if(context.mounted) ref.read(isLoadingProjectProvider.notifier).state = false;
        }).toJS;

        reader.readAsText(selectedFile);

      } else {
        if(context.mounted) ref.read(isLoadingProjectProvider.notifier).state = false;
      }
    }
    jsChangeCallbackHolder = dartChangeCallbackBody.toJS;
    uploadInput.addEventListener('change', jsChangeCallbackHolder);

    void dartWindowFocusCallbackBody(web.Event event) {
      if (jsWindowFocusCallbackHolder != null) {
        web.window.removeEventListener('focus', jsWindowFocusCallbackHolder);
        jsWindowFocusCallbackHolder = null;
      }

      Future.delayed(const Duration(milliseconds: 150), () {
        if (!context.mounted) return;
        if (!changeEventHasProcessed) {
          if(uploadInput.value != '') { uploadInput.value = ''; }
          if (ref.read(isLoadingProjectProvider)) {
            ref.read(isLoadingProjectProvider.notifier).state = false;
          }
        }
      });
    }
    jsWindowFocusCallbackHolder = dartWindowFocusCallbackBody.toJS;
    web.window.addEventListener('focus', jsWindowFocusCallbackHolder);

    web.document.body?.append(uploadInput);
    try {
      uploadInput.click();
    } catch (e, s) {
      issueService.reportError("Failed to trigger file selection dialog.", source: "FileLoader", error: e, stackTrace: s);
      if(context.mounted) ref.read(isLoadingProjectProvider.notifier).state = false;
      if (jsChangeCallbackHolder != null) uploadInput.removeEventListener('change', jsChangeCallbackHolder);
      if (jsWindowFocusCallbackHolder != null) web.window.removeEventListener('focus', jsWindowFocusCallbackHolder);
    } finally {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (uploadInput.parentElement != null) { uploadInput.remove(); }
      });
    }
  }

  List<Widget> _buildSelectableIssueListItems(List<String> issues, Color textColor, BuildContext context) {
    if (issues.isEmpty) return [];
    List<Widget> widgets = [];
    for (int i = 0; i < issues.length; i++) {
      widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 4.0),
            child: SelectableText(
              issues[i],
              style: TextStyle(color: textColor, fontSize: 13, fontFamily: 'monospace'),
              toolbarOptions: const ToolbarOptions(copy: true, selectAll: true),
            ),
          )
      );
      if (i < issues.length - 1) {
        widgets.add(Divider(
            height: 1.0,
            thickness: 0.5,
            color: Theme.of(context).dividerColor.withOpacity(0.5),
            indent: 4,
            endIndent: 4
        ));
      }
    }
    return widgets;
  }

  void _showProjectIssuesDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Project Issues Report'),
          contentPadding: const EdgeInsets.fromLTRB(0, 12.0, 0, 0),
          content: Consumer(
            builder: (context, dialogRef, child) {
              final errors = dialogRef.watch(projectErrorsProvider);
              final warnings = dialogRef.watch(projectWarningsProvider);

              return DefaultTabController(
                length: 2,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.8)),
                        ),
                        child: TabBar(
                          tabs: [
                            Tab(child: Text("Errors (${errors.length})", style: const TextStyle(fontSize: 14))),
                            Tab(child: Text("Warnings (${warnings.length})", style: const TextStyle(fontSize: 14))),
                          ],
                          labelColor: Theme.of(context).colorScheme.primary,
                          unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          indicatorColor: Theme.of(context).colorScheme.primary,
                          indicatorWeight: 3.0,
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildIssueListForTab(
                              context,
                              errors,
                              Colors.red.shade700,
                              "No errors reported.",
                            ),
                            _buildIssueListForTab(
                              context,
                              warnings,
                              Colors.orange.shade900,
                              "No warnings reported.",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Clear Log'),
              onPressed: () {
                ref.read(projectErrorsNotifierProvider.notifier).clearIssues();
                ref.read(projectWarningsNotifierProvider.notifier).clearIssues();
              },
            ),
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildIssueListForTab(
      BuildContext context,
      List<String> issues,
      Color textColor,
      String emptyMessage,
      ) {
    if (issues.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SelectableText(
            emptyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
          ),
        ),
      );
    }

    return Scrollbar(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: _buildSelectableIssueListItems(issues, textColor, context),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTree = ref.watch(canvasTreeProvider);
    final isLoading = ref.watch(isLoadingProjectProvider);
    final errors = ref.watch(projectErrorsProvider);
    final warnings = ref.watch(projectWarningsProvider);

    IconData statusIconData = Icons.check_circle_outline_rounded;
    Color statusIconColor = Colors.green.shade600;
    String statusTooltip = "Project Status: OK";

    if (errors.isNotEmpty) {
      statusIconData = Icons.error_rounded;
      statusIconColor = Colors.red.shade700;
      statusTooltip = "Project Status: ${errors.length} Error(s) found. Click 'Project Issues' for details.";
    } else if (warnings.isNotEmpty) {
      statusIconData = Icons.warning_amber_rounded;
      statusIconColor = Colors.orange.shade700;
      statusTooltip = "Project Status: ${warnings.length} Warning(s) found. Click 'Project Issues' for details.";
    }

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Row(
        children: [
          Tooltip(
            message: 'Save Project',
            child: IconButton(
              icon: const Icon(Icons.save_alt_outlined),
              onPressed: () => _saveProject(context, currentTree),
              iconSize: 20,
            ),
          ),
          Tooltip(
            message: 'Load Project',
            child: IconButton(
              icon: const Icon(Icons.file_upload_outlined),
              onPressed: isLoading ? null : () {
                _loadProject(context, ref);
              },
              iconSize: 20,
            ),
          ),
          const Spacer(),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5)),
            ),
          Tooltip(
            message: statusTooltip,
            child: Icon(statusIconData, color: statusIconColor, size: 22),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            icon: const Icon(Icons.playlist_add_check_circle_outlined, size: 20),
            label: const Text('Project Issues'),
            onPressed: () => _showProjectIssuesDialog(context, ref),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)
            ),
          ),
        ],
      ),
    );
  }
}