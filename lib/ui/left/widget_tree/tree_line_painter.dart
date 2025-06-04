import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TreeLinePainter extends CustomPainter {
  final int depth;
  final bool isLastChild;
  final List<bool> ancestorIsLastList;
  final Color lineColor;
  final double strokeWidth;
  final double itemHeight;

  static const double indentWidth = 16.0;

  TreeLinePainter({
    required this.depth,
    required this.isLastChild,
    required this.ancestorIsLastList,
    this.lineColor = Colors.grey,
    this.strokeWidth = 1.0,
    required this.itemHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double connectorY = itemHeight / 2;

    for (int i = 0; i < depth; i++) {
      double x = (i * indentWidth) + (indentWidth / 2);
      if (i < ancestorIsLastList.length && !ancestorIsLastList[i]) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
    }

    if (size.width > 0) {
      double itemConnectorLineStartX = (depth * indentWidth) + (indentWidth / 2);
      canvas.drawLine(Offset(itemConnectorLineStartX, connectorY), Offset(itemConnectorLineStartX + indentWidth / 2, connectorY), paint);
      if (isLastChild) {
        canvas.drawLine(Offset(itemConnectorLineStartX, 0), Offset(itemConnectorLineStartX, connectorY), paint);
      } else {
        canvas.drawLine(Offset(itemConnectorLineStartX, 0), Offset(itemConnectorLineStartX, size.height), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant TreeLinePainter oldDelegate) {
    return oldDelegate.depth != depth ||
        oldDelegate.isLastChild != isLastChild ||
        !listEquals(oldDelegate.ancestorIsLastList, ancestorIsLastList) ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.itemHeight != itemHeight;
  }
}