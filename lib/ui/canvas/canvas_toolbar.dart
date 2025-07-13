import 'package:flutter/material.dart';
import 'package:flutter_editor/constants/device_sizes.dart';
import 'package:flutter_editor/ui/canvas/custom_size_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/components/core/component_registry.dart';
import '../../services/code_generator_service.dart';
import '../../services/issue_reporter_service.dart';
import '../../state/editor_state.dart';
import '../../utils/file_io_web.dart';
import 'code_preview_dialog.dart';

class CanvasToolbar extends ConsumerStatefulWidget {
  const CanvasToolbar({super.key});

  @override
  ConsumerState<CanvasToolbar> createState() => _CanvasToolbarState();
}

class _CanvasToolbarState extends ConsumerState<CanvasToolbar> {
  int _dropdownKeyCounter = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 16),
        Expanded(
          child: _buildPageEditToolbar(context, ref),
        ),
      ],
    );
  }

  Widget _buildPageEditToolbar(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyManagerProvider);
    final showLayoutBounds = ref.watch(showLayoutBoundsProvider);
    final showLayoutBoundsNotifier = ref.read(showLayoutBoundsProvider.notifier);
    final selectedDeviceName = ref.watch(selectedDeviceProvider);
    final isLoading = ref.watch(isLoadingProjectProvider);
    final errors = ref.watch(projectErrorsProvider);
    final warnings = ref.watch(projectWarningsProvider);

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

    return Row(
      children: [
        Tooltip(message: 'Save Current Page Layout (.json)',
            child: IconButton(icon: const Icon(Icons.save_alt_outlined),
                onPressed: () => saveCurrentPageToFile(ref), iconSize: 20)
        ),
        Tooltip(message: 'Load Layout to Current Page (.json)',
            child: IconButton(icon: const Icon(Icons.file_upload_outlined),
                onPressed: () => loadAndReplaceCurrentPage(ref), iconSize: 20)
        ),
        const VerticalDivider(indent: 12, endIndent: 12),
        Tooltip(message: 'Undo',
            child: IconButton(icon: const Icon(Icons.undo),
                onPressed: historyState.canUndo ? () => ref.read(historyManagerProvider.notifier).undo() : null, iconSize: 20)
        ),
        Tooltip(message: 'Redo',
            child: IconButton(icon: const Icon(Icons.redo),
                onPressed: historyState.canRedo ? () => ref.read(historyManagerProvider.notifier).redo() : null, iconSize: 20)
        ),
        const VerticalDivider(indent: 12, endIndent: 12),
        Tooltip(message: 'Export Project Code (.zip)',
            child: IconButton(icon: const Icon(Icons.code),
                onPressed: () => _showExportDialog(context, ref), iconSize: 20)
        ),
        const VerticalDivider(indent: 12, endIndent: 12),
        SizedBox(
          width: 250,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              key: ValueKey('device_$_dropdownKeyCounter'),
              value: selectedDeviceName,
              isExpanded: true,
              items: kPredefinedDeviceSizes.map((device) =>
                  DropdownMenuItem<String>(value: device.name,
                      child: Text(device.name == 'Custom' ? 'Custom' : '${device.name} (${device.size.width} x ${device.size.height})',
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis))
              ).toList(),
              onChanged: (String? newDeviceName) async {
                if (newDeviceName == null) return;
                if (newDeviceName == 'Custom') {
                  final currentRootNode = ref.read(activeCanvasTreeProvider);
                  final currentSize = Size((currentRootNode.props['width'] as num).toDouble(), (currentRootNode.props['height'] as num).toDouble());
                  final newCustomSize = await showDialog<Size>(context: context, builder: (_) => CustomSizeDialog(currentSize: currentSize));
                  if (newCustomSize != null) {
                    _updateCanvasSize(newCustomSize, 'Custom', ref);
                  }
                } else {
                  final selectedDevice = kPredefinedDeviceSizes.firstWhere((d) => d.name == newDeviceName);
                  _updateCanvasSize(selectedDevice.size, newDeviceName, ref);
                }
                setState(() => _dropdownKeyCounter++);
              },
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              const Spacer(),
              Tooltip(message: showLayoutBounds
                  ? 'Hide Layout Bounds'
                  : 'Show Layout Bounds',
                  child: Row(mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(showLayoutBounds ? Icons.grid_on_sharp : Icons
                            .grid_off_sharp, size: 20, color: Theme
                            .of(context)
                            .colorScheme
                            .onSurfaceVariant),
                        const SizedBox(width: 4),
                        Switch(value: showLayoutBounds, onChanged: (value) {
                          showLayoutBoundsNotifier.state = value;
                        })
                      ])),
              const VerticalDivider(indent: 12, endIndent: 12),
              if (isLoading) const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5))),
              TextButton.icon(icon: const Icon(
                  Icons.playlist_add_check_circle_outlined, size: 20),
                  label: const Text('Project Issues'),
                  onPressed: () => _showProjectIssuesDialog(context, ref)),
              Tooltip(message: statusTooltip,
                  child: Icon(statusIconData, color: statusIconColor, size: 22)),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ],
    );
  }

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    final ProjectState currentProject = ref.read(projectStateProvider);
    final generator = CodeGeneratorService(registeredComponents);
    try {
      final Map<String, String> generatedFiles = generator.generateProjectCode(currentProject);
      showDialog(context: context, builder: (BuildContext dialogContext) => CodePreviewDialog(generatedFiles: generatedFiles));
    } catch (e, s) {
      IssueReporterService().reportError("Failed to generate project code", source: "CanvasToolbar._showExportDialog", error: e, stackTrace: s);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error generating code: $e"), backgroundColor: Colors.red));
    }
  }

  void _updateCanvasSize(Size newSize, String deviceName, WidgetRef ref) {
    ref.read(selectedDeviceProvider.notifier).state = deviceName;
    final currentTree = ref.read(activeCanvasTreeProvider);
    final newProps = Map<String, dynamic>.from(currentTree.props);
    newProps['width'] = newSize.width;
    newProps['height'] = newSize.height;
    final newTree = currentTree.copyWith(props: newProps);
    ref.read(historyManagerProvider.notifier).recordState(newTree);
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
                      TabBar(tabs: [Tab(text: "Errors (${errors.length})"), Tab(text: "Warnings (${warnings.length})")]),
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
                }, child: const Text('Clear Log')
            ),
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Close')
            ),
          ],
        );
      },
    );
  }

  Widget _buildIssueListForTab(BuildContext context, List<String> issues, Color textColor, String emptyMessage) {
    if (issues.isEmpty) return Center(child: Text(emptyMessage));
    return ListView.separated(
      itemCount: issues.length,
      itemBuilder: (context, index) => Padding(padding: const EdgeInsets.all(8.0), child: SelectableText(issues[index], style: TextStyle(color: textColor, fontFamily: 'monospace'))),
      separatorBuilder: (context, index) => const Divider(height: 1),
    );
  }
}