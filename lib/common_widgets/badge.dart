import 'package:flutter/material.dart';

enum ChipType { status, removable }
enum StatusType { newStatus, active, error }

class BadgeChip extends StatelessWidget {
  final String label;
  final ChipType type;
  final StatusType? status;
  final VoidCallback? onRemove;

  const BadgeChip({
    super.key,
    required this.label,
    this.type = ChipType.status,
    this.status,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (type == ChipType.status) {
      return Chip(
        label: Text(
          label,
          style: TextStyle(
            color: _textColor(status, context),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _backgroundColor(status, context),
      );
    } else {
      return Chip(
        label: Text(label),
        onDeleted: onRemove,
        deleteIcon: const Icon(Icons.close, size: 18),
        deleteIconColor: Colors.grey[700],
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      );
    }
  }

  // status colors
  Color _backgroundColor(StatusType? status, BuildContext context) {
    switch (status) {
      case StatusType.newStatus:
        return Colors.blue[100]!;
      case StatusType.active:
        return Colors.green[100]!;
      case StatusType.error:
        return Colors.red[100]!;
      default:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
  }

  Color _textColor(StatusType? status, BuildContext context) {
    switch (status) {
      case StatusType.newStatus:
        return Colors.blue[800]!;
      case StatusType.active:
        return Colors.green[800]!;
      case StatusType.error:
        return Colors.red[800]!;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }
}
