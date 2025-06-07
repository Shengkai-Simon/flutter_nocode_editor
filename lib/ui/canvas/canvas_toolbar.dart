import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter_editor/constants/device_sizes.dart';
import 'package:flutter_editor/ui/canvas/custom_size_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web/web.dart' as web;

import '../../editor/components/core/widget_node.dart';
import '../../editor/components/core/component_registry.dart';
import '../../services/code_generator_service.dart';
import '../../services/issue_reporter_service.dart';
import '../../state/editor_state.dart';
import 'code_preview_dialog.dart';

class CanvasToolbar extends ConsumerWidget {
  const CanvasToolbar({super.key});

  /// A reusable utility function to trigger a file download in the browser.
  void _downloadFile(BuildContext context, {
    required String content,
    required String fileName,
    required String mimeType,
  }) {
    try {
      final blob = web.Blob([content.toJS].toJS, web.BlobPropertyBag(type: mimeType));
      final url = web.URL.createObjectURL(blob);
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = url;
      anchor.download = fileName;
      web.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      web.URL.revokeObjectURL(url);
    } catch (e, s) {
      IssueReporterService().reportError("Error during file download", source: "CanvasToolbar._downloadFile", error: e, stackTrace: s);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error downloading file: $e"), backgroundColor: Colors.red),
      );
    }
  }

  /// Saves the current canvas tree as a JSON file.
  void _saveProject(BuildContext context, WidgetNode tree) {
    const jsonEncoder = JsonEncoder.withIndent('  ');
    final jsonString = jsonEncoder.convert(tree.toJson());
    _downloadFile(
        context,
        content: jsonString,
        fileName: 'flutter_editor_project.json',
        mimeType: 'application/json'
    );
  }

  /// Generates the Dart code and displays it in a preview dialog.
  void _showExportDialog(BuildContext context, WidgetRef ref) {
    final WidgetNode currentTree = ref.read(canvasTreeProvider);
    const String rootWidgetName = "MyExportedScreen";
    final String fileName = '${rootWidgetName.toLowerCase().replaceAll('_', '-')}.dart';

    final generator = CodeGeneratorService(registeredComponents);

    try {
      final String formattedDartCode = generator.generateDartCode(currentTree, rootWidgetName);
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return CodePreviewDialog(
            code: formattedDartCode,
            fileName: fileName,
          );
        },
      );
    } catch (e, s) {
      IssueReporterService().reportError(
        "Failed to generate Dart code for project.",
        source: "CanvasToolbar._showExportDialog",
        error: e,
        stackTrace: s,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating code: $e"), backgroundColor: Colors.red),
      );
    }
  }

  /// Updates the canvas root node with a new size and records the change in history.
  void _updateCanvasSize(Size newSize, String deviceName, WidgetRef ref) {
    ref.read(selectedDeviceProvider.notifier).state = deviceName;

    final currentTree = ref.read(canvasTreeProvider);
    final newProps = Map<String, dynamic>.from(currentTree.props);
    newProps['width'] = newSize.width;
    newProps['height'] = newSize.height;

    final newTree = currentTree.copyWith(props: newProps);

    ref.read(historyManagerProvider.notifier).recordState(newTree);
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProjectProvider);
    final errors = ref.watch(projectErrorsProvider);
    final warnings = ref.watch(projectWarningsProvider);
    final showLayoutBounds = ref.watch(showLayoutBoundsProvider);
    final showLayoutBoundsNotifier = ref.read(showLayoutBoundsProvider.notifier);
    final historyState = ref.watch(historyManagerProvider);
    final selectedDeviceName = ref.watch(selectedDeviceProvider);

    IconData statusIconData = Icons.check_circle_outline_rounded;
    Color statusIconColor = Colors.green.shade600;
    String statusTooltip = "Project Status: OK";

    if (errors.isNotEmpty) {
      statusIconData = Icons.error_rounded;
      statusIconColor = Colors.red.shade700;
      statusTooltip = "Project Status: ${errors.length} Error(s) found.";
    } else if (warnings.isNotEmpty) {
      statusIconData = Icons.warning_amber_rounded;
      statusIconColor = Colors.orange.shade700;
      statusTooltip = "Project Status: ${warnings.length} Warning(s) found.";
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
            message: 'Save Project as JSON',
            child: IconButton(
              icon: const Icon(Icons.save_alt_outlined),
              onPressed: () => _saveProject(context, ref.read(canvasTreeProvider)),
              iconSize: 20,
            ),
          ),
          Tooltip(
            message: 'Load Project from JSON',
            child: IconButton(
              icon: const Icon(Icons.file_upload_outlined),
              onPressed: isLoading ? null : () => _loadProject(context, ref),
              iconSize: 20,
            ),
          ),
          const VerticalDivider(indent: 12, endIndent: 12),

          Tooltip(
            message: 'Undo',
            child: IconButton(
              icon: const Icon(Icons.undo),
              onPressed: historyState.canUndo
                  ? () => ref.read(historyManagerProvider.notifier).undo()
                  : null,
              iconSize: 20,
            ),
          ),
          Tooltip(
            message: 'Redo',
            child: IconButton(
              icon: const Icon(Icons.redo),
              onPressed: historyState.canRedo
                  ? () => ref.read(historyManagerProvider.notifier).redo()
                  : null,
              iconSize: 20,
            ),
          ),
          const VerticalDivider(indent: 12, endIndent: 12),

          Tooltip(
            message: 'Export to Dart Code',
            child: IconButton(
              icon: const Icon(Icons.code),
              onPressed: () => _showExportDialog(context, ref),
              iconSize: 20,
            ),
          ),
          const VerticalDivider(indent: 12, endIndent: 12),

          // Canvas Size Dropdown
          SizedBox(
            width: 250,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedDeviceName,
                // isDense: true,
                isExpanded: true,
                items: kPredefinedDeviceSizes.map((device) {
                  return DropdownMenuItem<String>(
                    value: device.name,
                    child: Text(
                      device.name == 'Custom' ? 'Custom' : '${device.name} (${device.size.width} x ${device.size.height})',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (String? newDeviceName) async {
                  if (newDeviceName == null) return;

                  if (newDeviceName == 'Custom') {
                    final currentRootNode = ref.read(canvasTreeProvider);
                    final currentSize = Size(
                      (currentRootNode.props['width'] as num).toDouble(),
                      (currentRootNode.props['height'] as num).toDouble(),
                    );

                    final newCustomSize = await showDialog<Size>(
                      context: context,
                      builder: (_) => CustomSizeDialog(currentSize: currentSize),
                    );

                    if (newCustomSize != null) {
                      _updateCanvasSize(newCustomSize, 'Custom', ref);
                    }
                  } else {
                    final selectedDevice = kPredefinedDeviceSizes.firstWhere((d) => d.name == newDeviceName);
                    _updateCanvasSize(selectedDevice.size, newDeviceName, ref);
                  }
                },
              ),
            ),
          ),

          const Spacer(),

          Tooltip(
            message: showLayoutBounds ? 'Hide Layout Bounds' : 'Show Layout Bounds',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  showLayoutBounds ? Icons.grid_on_sharp : Icons.grid_off_sharp,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Switch(
                  value: showLayoutBounds,
                  onChanged: (value) {
                    showLayoutBoundsNotifier.state = value;
                  },
                ),
              ],
            ),
          ),
          const VerticalDivider(indent: 12, endIndent: 12),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5)),
            ),

          TextButton.icon(
            icon: const Icon(Icons.playlist_add_check_circle_outlined, size: 20),
            label: const Text('Project Issues'),
            onPressed: () => _showProjectIssuesDialog(context, ref),
          ),
          Tooltip(
            message: statusTooltip,
            child: Icon(statusIconData, color: statusIconColor, size: 22),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  void _loadProject(BuildContext context, WidgetRef ref) {
    if (ref.read(isLoadingProjectProvider)) {return;}

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
            } else if (jsResult.isA<JSString>()) {
              fileContent = (jsResult as JSString).toDart;
            } else {
              fileContent = jsResult.toString();
            }

            if (fileContent.trim().isNotEmpty) {
              final jsonMap = jsonDecode(fileContent) as Map<String, dynamic>;
              final WidgetNode newTree = WidgetNode.fromJson(jsonMap);
              ref.read(historyManagerProvider.notifier).resetWithInitialState(newTree);

              final loadedWidth = (newTree.props['width'] as num?)?.toDouble();
              final loadedHeight = (newTree.props['height'] as num?)?.toDouble();
              if (loadedWidth != null && loadedHeight != null) {
                final loadedSize = Size(loadedWidth, loadedHeight);
                bool foundMatch = false;
                for (var device in kPredefinedDeviceSizes) {
                  if (device.size == loadedSize) {
                    ref.read(selectedDeviceProvider.notifier).state = device.name;
                    foundMatch = true;
                    break;
                  }
                }
                if (!foundMatch) {
                  ref.read(selectedDeviceProvider.notifier).state = 'Custom';
                }
              }

            }
          } catch (err, s) {
            issueService.reportError("Failed to parse project data from '${selectedFile?.name}'.", source: "ProjectParser", error: err, stackTrace: s);
          } finally {
            if(context.mounted) ref.read(isLoadingProjectProvider.notifier).state = false;
          }
        }).toJS;

        reader.onerror = ((web.Event errorEvent) {
          issueService.reportError("Error reading file: ${selectedFile?.name}", source: "FileReader", error: reader.error);
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
    } finally {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (uploadInput.parentElement != null) { uploadInput.remove(); }
      });
    }
  }

  void _showProjectIssuesDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Project Issues Report'),
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
                    children: <Widget>[
                      TabBar(
                        tabs: [
                          Tab(text: "Errors (${errors.length})"),
                          Tab(text: "Warnings (${warnings.length})"),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildIssueListForTab(context, errors, Colors.red.shade700, "No errors reported."),
                            _buildIssueListForTab(context, warnings, Colors.orange.shade900, "No warnings reported."),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                ref.read(projectErrorsNotifierProvider.notifier).clearIssues();
                ref.read(projectWarningsNotifierProvider.notifier).clearIssues();
              },
              child: const Text('Clear Log'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIssueListForTab(BuildContext context, List<String> issues, Color textColor, String emptyMessage) {
    if (issues.isEmpty) {
      return Center(child: Text(emptyMessage));
    }
    return ListView.separated(
      itemCount: issues.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: SelectableText(issues[index], style: TextStyle(color: textColor, fontFamily: 'monospace')),
      ),
      separatorBuilder: (context, index) => const Divider(height: 1),
    );
  }
}