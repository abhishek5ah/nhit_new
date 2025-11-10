import 'package:flutter/material.dart';

enum ChipType { status, removable }

class BadgeChip extends StatelessWidget {
  final String label;
  final ChipType type;
  final String? statusKey;
  final Color Function(String)? statusColorFunc;
  final VoidCallback? onRemove;

  final Color? backgroundColor;
  final Color? textColor;

  const BadgeChip({
    super.key,
    required this.label,
    this.type = ChipType.status,
    this.statusKey,
    this.statusColorFunc,
    this.onRemove,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = _resolveBackgroundColor(context);
    final txtColor = textColor ?? Theme.of(context).colorScheme.onSurface;

    return Chip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Text(
        label,
        style: TextStyle(
          color: txtColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
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
      deleteIconColor: txtColor,
    );
  }

  Color _resolveBackgroundColor(BuildContext context) {
    // Priority 1: Explicit backgroundColor passed
    if (backgroundColor != null) return backgroundColor!;

    // Priority 2: Dynamic color function based on statusKey
    if (statusColorFunc != null && statusKey != null) {
      return statusColorFunc!(statusKey!);
    }

    // Priority 3: Theme fallback
    return Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4);
  }
}
