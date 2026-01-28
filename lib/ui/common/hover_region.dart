import 'package:flutter/material.dart';

class HoverRegion extends StatefulWidget {
  const HoverRegion({
    super.key,
    required this.builder,
    this.onHoverChange,
    this.cursor = SystemMouseCursors.basic,
  });

  final Widget Function(BuildContext context, bool isHovering) builder;

  final void Function(bool isHovering)? onHoverChange;

  final MouseCursor cursor;

  @override
  State<HoverRegion> createState() => _HoverRegionState();
}

class _HoverRegionState extends State<HoverRegion> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        if (!_isHovering) {
          setState(() {
            _isHovering = true;
          });
          widget.onHoverChange?.call(true);
        }
      },
      onExit: (event) {
        if (_isHovering) {
          setState(() {
            _isHovering = false;
          });
          widget.onHoverChange?.call(false);
        }
      },
      cursor: widget.cursor,
      child: widget.builder(context, _isHovering),
    );
  }
}