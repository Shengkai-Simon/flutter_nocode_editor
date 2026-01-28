import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

/// A dedicated painter to draw visual feedback (borders, tags) for a widget
/// in the canvas, without interfering with its layout.
class FeedbackPainter extends CustomPainter {
  final bool isSelected;
  final bool isHovered;
  final bool isDragCandidate;
  final bool isDragRejected;
  final bool showLayoutBounds;
  final String label;

  FeedbackPainter({
    required this.isSelected,
    required this.isHovered,
    required this.isDragCandidate,
    required this.isDragRejected,
    required this.showLayoutBounds,
    required this.label,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Color borderColor = Colors.transparent;
    double strokeWidth = 1.0;
    bool shouldShowTag = false;
    Color tagBackgroundColor = Colors.transparent;
    Color tagTextColor = Colors.white;

    // Determine visual style based on interaction state
    if (isDragCandidate) {
      borderColor = Colors.greenAccent.shade400;
      strokeWidth = 2.0;
    } else if (isDragRejected) {
      borderColor = Colors.redAccent.shade400;
      strokeWidth = 2.0;
    } else {
      if (isSelected) {
        borderColor = selectedBorderColor;
        strokeWidth = 1.5;
        shouldShowTag = true;
        tagBackgroundColor = selectedTagBackgroundColor;
        tagTextColor = selectedTagTextColor;
      } else if (isHovered) {
        borderColor = hoverBorderColor;
        strokeWidth = 1.5;
        shouldShowTag = true;
        tagBackgroundColor = hoverTagBackgroundColor;
        tagTextColor = hoverTagTextColor;
      } else if (showLayoutBounds) {
        borderColor = layoutBoundBorderColor;
        strokeWidth = 1.0;
      }
    }

    // Draw the border if a color has been determined
    if (borderColor != Colors.transparent) {
      final paint = Paint()
        ..color = borderColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }

    // Draw the tag if needed
    if (shouldShowTag) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: tagTextColor,
            fontSize: kRendererTagFontSize,
            fontWeight: FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final tagRect = Rect.fromLTWH(
        -strokeWidth, // Position relative to the border
        -textPainter.height - (kRendererTagPadding.vertical / 2) - strokeWidth,
        textPainter.width + kRendererTagPadding.horizontal,
        textPainter.height + kRendererTagPadding.vertical,
      );

      final tagPaint = Paint()..color = tagBackgroundColor;
      canvas.drawRRect(RRect.fromRectAndRadius(tagRect, const Radius.circular(kRendererTagBorderRadius)), tagPaint);

      textPainter.paint(canvas, Offset(tagRect.left + kRendererTagPadding.left, tagRect.top + kRendererTagPadding.top));
    }
  }

  @override
  bool shouldRepaint(covariant FeedbackPainter oldDelegate) {
    // Repaint only if any of the state properties change
    return isSelected != oldDelegate.isSelected ||
        isHovered != oldDelegate.isHovered ||
        isDragCandidate != oldDelegate.isDragCandidate ||
        isDragRejected != oldDelegate.isDragRejected ||
        showLayoutBounds != oldDelegate.showLayoutBounds ||
        label != oldDelegate.label;
  }
}
