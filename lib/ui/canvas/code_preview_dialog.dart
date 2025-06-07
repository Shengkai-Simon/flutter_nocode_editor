import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:flutter_syntax_view/flutter_syntax_view.dart';

/// A reusable utility function to trigger a file download in the browser.
void _downloadDartFile(String content, String fileName, BuildContext context) {
  try {
    final blob = web.Blob([content.toJS].toJS, web.BlobPropertyBag(type: 'text/dart'));
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
      SnackBar(content: Text("Error downloading file: $e"), backgroundColor: Colors.red),
    );
  }
}

/// A dialog widget that displays a code preview with syntax highlighting,
/// copy, and download actions.
/// 一个对话框组件，用于显示带有语法高亮、复制和下载操作的代码预览。
class CodePreviewDialog extends StatelessWidget {
  final String code;
  final String fileName;

  const CodePreviewDialog({
    super.key,
    required this.code,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    const dialogBackgroundColor = Color(0xFF1E1E1E);
    const titleColor = Color(0xFF9CDCFE);
    const iconColor = Color(0xFFD4D4D4);

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
                      'Generated Dart Code',
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
                          message: 'Copy to Clipboard',
                          child: IconButton(
                            icon: const Icon(Icons.copy_all_outlined, size: 20, color: iconColor),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: code));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Code copied to clipboard!'),
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
                            onPressed: () => _downloadDartFile(code, fileName, context),
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
              const Divider(height: 1, color: Color(0xFF333333)),
              Flexible(
                child: SyntaxView(
                  code: code,
                  syntax: Syntax.DART,
                  syntaxTheme: SyntaxTheme.vscodeDark(),
                  withZoom: true,
                  withLinesCount: true,
                  expanded: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
