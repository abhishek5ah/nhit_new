import 'package:flutter/material.dart';

class DropdownItem {
  final String label;
  final String value;

  const DropdownItem({
    required this.label,
    required this.value,
  });
}

class CustomDropdown extends StatelessWidget {
  final String? value;
  final List<String>? items;
  final List<DropdownItem>? itemsWithLabels;
  final String hint;
  final ValueChanged<String?>? onChanged;
  final bool enabled;

  const CustomDropdown({
    super.key,
    this.value,
    this.items,
    this.itemsWithLabels,
    required this.hint,
    this.onChanged,
    this.enabled = true,
  }) : assert(items != null || itemsWithLabels != null, 'Either items or itemsWithLabels must be provided');

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Build dropdown items from either simple strings or label/value pairs
    final dropdownItems = itemsWithLabels != null
        ? itemsWithLabels!.map((item) {
      return DropdownMenuItem<String>(
        value: item.value,
        child: Text(
          item.label,
          style: TextStyle(
            color: colorScheme.onSurface,
          ),
        ),
      );
    }).toList()
        : items!.map((String item) {
      return DropdownMenuItem<String>(
        value: item,
        child: Text(
          item,
          style: TextStyle(
            color: colorScheme.onSurface,
          ),
        ),
      );
    }).toList();

    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(
        hint,
        style: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
      items: dropdownItems,
      onChanged: enabled ? onChanged : null,
      isExpanded: true,
      menuMaxHeight: 300,
      alignment: AlignmentDirectional.centerStart,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: !enabled,
        fillColor: enabled
            ? null
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      dropdownColor: colorScheme.surface,
      icon: Icon(
        Icons.arrow_drop_down,
        color: enabled ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }
}

