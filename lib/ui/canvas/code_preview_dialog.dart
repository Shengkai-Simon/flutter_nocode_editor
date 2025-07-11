import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:web/web.dart' as web;
import 'package:archive/archive_io.dart';

/// A dialog widget that displays a code preview with syntax highlighting,
/// copy, and download actions.
class CodePreviewDialog extends StatefulWidget {
  final Map<String, String> generatedFiles;

  const CodePreviewDialog({
    super.key,
    required this.generatedFiles,
  });

  @override
  State<CodePreviewDialog> createState() => _CodePreviewDialogState();
}

class _CodePreviewDialogState extends State<CodePreviewDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: widget.generatedFiles.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _downloadFile(String content, String fileName) {
    try {
      final blob = web.Blob(
          [content.toJS].toJS, web.BlobPropertyBag(type: 'text/dart'));
      final url = web.URL.createObjectURL(blob);
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = url;
      anchor.download = fileName;
      web.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      web.URL.revokeObjectURL(url);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error downloading file: $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  /// Package all the files into a single ZIP file and download it.
  void _downloadAllAsZip() {
    // Create a ZIP encoder
    final encoder = ZipEncoder();
    // Create a new archive
    final archive = Archive();

    // Iterate through all the generated files and add them to the archive
    widget.generatedFiles.forEach((fileName, content) {
      // Convert file content to bytes
      final fileBytes = utf8.encode(content);
      // Create a zip file entry
      final archiveFile = ArchiveFile(fileName, fileBytes.length, fileBytes);
      // Add the file to the package
      archive.addFile(archiveFile);
    });

    // Encode the entire archive to get the final ZIP file bytes
    final zipBytes = encoder.encode(archive);

    // Use the generic download logic to download this ZIP file
    try {
      final blob = web.Blob([Uint8List
          .fromList(zipBytes)
          .toJS
      ].toJS, web.BlobPropertyBag(type: 'application/zip'));
      final url = web.URL.createObjectURL(blob);
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = url;
      anchor.download = 'flutter_project.zip'; // The default file name of the package
      web.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      web.URL.revokeObjectURL(url);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error downloading zip file: $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const dialogBackgroundColor = Color(0xFF1E1E1E);
    const titleColor = Color(0xFF9CDCFE);
    const iconColor = Color(0xFFD4D4D4);

    final fileNames = widget.generatedFiles.keys.toList();
    final fileContents = widget.generatedFiles.values.toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: dialogBackgroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Generated Project Code',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: 'Download All as .zip',
                          child: IconButton(
                            icon: const Icon(Icons.archive_outlined, size: 20, color: iconColor),
                            onPressed: _downloadAllAsZip,
                          ),
                        ),
                        // This is the corrected part
                        const SizedBox(
                          height: 24, // Give the divider a specific height
                          child: VerticalDivider(
                            color: Colors.white,
                            width: 20, // The total space the divider takes horizontally
                            thickness: 1, // The thickness of the line itself
                          ),
                        ),
                        Tooltip(
                          message: 'Copy to Clipboard',
                          child: IconButton(
                            icon: const Icon(Icons.copy_all_outlined, size: 20, color: iconColor),
                            onPressed: () {
                              final currentCode = fileContents[_tabController.index];
                              Clipboard.setData(ClipboardData(text: currentCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Current file copied to clipboard!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: 'Download File',
                          child: IconButton(
                            icon: const Icon(Icons.download_outlined, size: 20, color: iconColor),
                            onPressed: () {
                              final fileName = fileNames[_tabController.index];
                              final fileContent = fileContents[_tabController.index];
                              _downloadFile(fileContent, fileName);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Tooltip(
                          message: 'Close',
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 22, color: iconColor),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                color: const Color(0xFF2D2D2D),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: fileNames.map((name) => Tab(text: name)).toList(),
                ),
              ),
              Flexible(
                child: TabBarView(
                  controller: _tabController,
                  children: fileContents.map((code) {
                    return SyntaxView(
                      code: code,
                      syntax: Syntax.DART,
                      syntaxTheme: SyntaxTheme.vscodeDark(),
                      withZoom: true,
                      withLinesCount: true,
                      expanded: true,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
