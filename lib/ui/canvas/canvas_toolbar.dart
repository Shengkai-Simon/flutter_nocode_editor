import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web/web.dart' as web;

import '../../editor/components/core/widget_node.dart';
import '../../state/editor_state.dart';

class CanvasToolbar extends ConsumerWidget {
  const CanvasToolbar({super.key});

  // Save Function
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
      print("Save error: $e\n$s");
    }
  }

  // Load Function
  void _loadProject(BuildContext context, WidgetRef ref) {
    final uploadInput = web.document.createElement('input') as web.HTMLInputElement;
    uploadInput.type = 'file';
    uploadInput.accept = '.json';

    void handleChange(web.Event event) {
      final files = uploadInput.files;
      if (files != null && files.length > 0) {
        final file = files.item(0);
        if (file != null) {
          final reader = web.FileReader();
          reader.onloadend = (web.Event e) {
            try {
              final jsResult = reader.result;
              String fileContent;

              if (jsResult == null || jsResult.isUndefinedOrNull) {
                print("FileReader result was null or undefined.");
                fileContent = "";
              } else if (jsResult.isA<JSString>()) {
                fileContent = (jsResult as JSString).toDart;
              } else {
                print("FileReader result was not a JSString (type: ${jsResult.runtimeType}). Content: '$jsResult'. Attempting Dart toString().");
                fileContent = jsResult.toString();
              }

              if (fileContent.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Loaded file is empty or unreadable."), backgroundColor: Colors.orange),
                );
                return;
              }

              final jsonMap = jsonDecode(fileContent) as Map<String, dynamic>;
              final newTree = WidgetNode.fromJson(jsonMap);

              ref.read(canvasTreeProvider.notifier).state = newTree;
              ref.read(selectedNodeIdProvider.notifier).state = null;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Project loaded successfully!"), backgroundColor: Colors.green),
              );
            } catch (err, s) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error loading or parsing project file: $err"), backgroundColor: Colors.red),
              );
              print("Load error: $err\n$s");
            }
          }.toJS;

          reader.onerror = (web.Event e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error reading file: ${reader.error}"), backgroundColor: Colors.red),
            );
            print("File read error: ${reader.error}");
          }.toJS;
          reader.readAsText(file);
        }
      }
    }

    uploadInput.addEventListener('change', handleChange.toJS);
    uploadInput.click();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTree = ref.watch(canvasTreeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Row(
        children: [
          Tooltip(
            message: 'Save Project',
            child: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                _saveProject(context, currentTree);
              },
            ),
          ),
          Tooltip(
            message: 'Load Project',
            child: IconButton(
              icon: const Icon(Icons.upload),
              onPressed: () {
                _loadProject(context, ref);
              },
            ),
          ),
        ],
      ),
    );
  }
}