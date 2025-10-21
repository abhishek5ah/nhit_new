import 'package:flutter/material.dart';

enum ChipType { status, removable }

class BadgeChip extends StatelessWidget {
  final String label;
  final ChipType type;
  final String? statusKey;
  final Color Function(String)? statusColorFunc;
  final VoidCallback? onRemove;

  const BadgeChip({
    super.key,
    required this.label,
    this.type = ChipType.status,
    this.statusKey,
    this.statusColorFunc,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = _backgroundColor(context);
    final textColor = Colors.white;

    final labelWidget = Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.3,
      ),
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );

    return Chip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: labelWidget,
      backgroundColor: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      visualDensity: VisualDensity.compact,
      onDeleted: type == ChipType.removable ? onRemove : null,
      deleteIcon: type == ChipType.removable
          ? const Icon(Icons.close, size: 16)
          : null,
      deleteIconColor: textColor,
    );
  }

  Color _backgroundColor(BuildContext context) {
    if (statusColorFunc != null && statusKey != null) {
      return statusColorFunc!(statusKey!);
    }
    return Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha:0.4);
  }
}
