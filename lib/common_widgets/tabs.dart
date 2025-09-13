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
    final selectedTabBg = colorScheme.onSurface;
    final unselectedTabBg = Colors.transparent;
    final selectedText = colorScheme.surface;
    final unselectedText = colorScheme.onSurface;

    return Material(
      color: pillBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderColor, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          alignment: WrapAlignment.start,
          children: List.generate(tabs.length, (i) {
            return GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selectedIndex == i ? selectedTabBg : unselectedTabBg,
                  borderRadius: BorderRadius.circular(14),
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
