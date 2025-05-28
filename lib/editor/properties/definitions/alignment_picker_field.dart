import 'package:flutter/material.dart';

class AlignmentPickerField extends StatefulWidget {
  final String label;
  final String value;
  final void Function(String) onChanged;
  final List<Map<String, String>> options;

  const AlignmentPickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.options,
  });

  @override
  State<AlignmentPickerField> createState() => _AlignmentPickerFieldState();
}

class _AlignmentPickerFieldState extends State<AlignmentPickerField> {
  final List<String> _gridOrder = [
    'topLeft', 'topCenter', 'topRight',
    'centerLeft', 'center', 'centerRight',
    'bottomLeft', 'bottomCenter', 'bottomRight',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              childAspectRatio: 2.0,
              children: _gridOrder.map((alignmentId) {
                final option = widget.options.firstWhere(
                      (opt) => opt['id'] == alignmentId,
                  orElse: () => {'id': alignmentId, 'name': 'Unknown'},
                );
                final String displayName = option['name'] ?? alignmentId;
                final bool isSelected = widget.value == alignmentId;

                return Tooltip(
                  message: displayName,
                  child: InkWell(
                    onTap: () {
                      widget.onChanged(alignmentId);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : null,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          width: isSelected ? 2.0 : 0.5,
                        ),
                      ),
                      child: Center(
                        child: _buildAlignmentIcon(alignmentId, isSelected, context),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlignmentIcon(String alignmentId, bool isSelected, BuildContext context) {
    double dotSize = 6.0;
    Color dotColor = isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;

    Alignment iconAlignment;
    switch (alignmentId) {
      case 'topLeft': iconAlignment = Alignment.topLeft; break;
      case 'topCenter': iconAlignment = Alignment.topCenter; break;
      case 'topRight': iconAlignment = Alignment.topRight; break;
      case 'centerLeft': iconAlignment = Alignment.centerLeft; break;
      case 'center': iconAlignment = Alignment.center; break;
      case 'centerRight': iconAlignment = Alignment.centerRight; break;
      case 'bottomLeft': iconAlignment = Alignment.bottomLeft; break;
      case 'bottomCenter': iconAlignment = Alignment.bottomCenter; break;
      case 'bottomRight': iconAlignment = Alignment.bottomRight; break;
      default: iconAlignment = Alignment.center;
    }

    return Align(
      alignment: iconAlignment,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}