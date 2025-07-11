import 'package:flutter/material.dart';

/// A generic quadratic confirmation dialog.
class DeleteConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;

  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          // When "Cancel" is pressed, the dialog returns false.
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton.tonal(
          // When you press "Delete", the dialog box returns true.
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red.shade100,
            foregroundColor: Colors.red.shade900,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}