import 'package:flutter/material.dart';

import '../../editor/components/core/component_definition.dart';
import '../common/hover_region.dart';

class PaletteComponentItem extends StatelessWidget {
  final RegisteredComponent rc;
  final ThemeData theme;

  const PaletteComponentItem({
    super.key,
    required this.rc,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return HoverRegion(
      cursor: SystemMouseCursors.grab,
      builder: (context, isHovering) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isHovering ? theme.colorScheme.primaryContainer.withOpacity(0.5) : theme.cardColor,
            border: Border.all(
              color: isHovering ? theme.colorScheme.primary : theme.dividerColor.withOpacity(0.5),
              width: isHovering ? 1.5 : 1.0,
            ),
            boxShadow: isHovering ? [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(rc.icon ?? Icons.extension, size: 20, color: isHovering ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.primary),
              const SizedBox(height: 4),
              Text(
                rc.displayName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isHovering ? theme.colorScheme.onPrimaryContainer : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}