import 'package:flutter/material.dart';

class TabsBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Axis direction;

  const TabsBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final pillBg = colorScheme.surfaceContainer;
    final borderColor = colorScheme.outline;
    final selectedTabBg = colorScheme.primary;
    final unselectedTabBg = Colors.transparent;
    final selectedText = colorScheme.surface;
    final unselectedText = colorScheme.onSurface;

    return Material(
      color: pillBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          alignment: WrapAlignment.start,
          children: List.generate(tabs.length, (i) {
            //  border radius logic
            BorderRadius borderRadius;

            if (tabs.length == 1) {
              // only one tab  round both sides
              borderRadius = BorderRadius.circular(20);
            } else if (i == 0) {
              // first tab  round left only
              borderRadius = const BorderRadius.horizontal(
                left: Radius.circular(20),
                right: Radius.circular(0),
              );
            } else if (i == tabs.length - 1) {
              // last tab  round right only
              borderRadius = const BorderRadius.horizontal(
                left: Radius.circular(0),
                right: Radius.circular(20),
              );
            } else {
              // middle tabs no rounded corners
              borderRadius = BorderRadius.zero;
            }

            return GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: selectedIndex == i ? selectedTabBg : unselectedTabBg,
                  borderRadius: borderRadius,
                ),
                child: Text(
                  tabs[i],
                  style: TextStyle(
                    color: selectedIndex == i ? selectedText : unselectedText,
                    fontWeight: selectedIndex == i
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
