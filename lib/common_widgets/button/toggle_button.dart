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
    final colorScheme = Theme
        .of(context)
        .colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24, width: 1),
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
                color: isSelected ? colorScheme.primary : colorScheme.onPrimary,
                borderRadius: BorderRadius.horizontal(
                  left: i == 0 ? const Radius.circular(18) : Radius.zero,
                  right: i == 1 ? const Radius.circular(18) : Radius.zero,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                labels[i],
                style: TextStyle(
                  color: isSelected ? colorScheme.onPrimary : colorScheme
                      .primary,
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