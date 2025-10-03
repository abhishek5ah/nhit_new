import 'package:flutter/material.dart';

class ToggleBtn extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const ToggleBtn({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  }) : assert(labels.length == 2, "ToggleBtn only supports two labels.");

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface, // Use theme surface color for background
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outline, // Theme border color
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(2, (i) {
          final bool isSelected = selectedIndex == i;

          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 108,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.horizontal(
                  left: i == 0 ? const Radius.circular(18) : Radius.zero,
                  right: i == 1 ? const Radius.circular(18) : Radius.zero,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                labels[i],
                style: TextStyle(
                  color: isSelected
                      ? colorScheme.onPrimary // Text color primary when selected
                      : colorScheme.primary, // Text color when not selected
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
