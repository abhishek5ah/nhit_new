import 'package:flutter/material.dart';

class AccordionItem {
  final String title;
  final Widget content;
  final bool isExpanded;

  AccordionItem({
    required this.title,
    required this.content,
    this.isExpanded = false,
  });

  AccordionItem copyWith({bool? isExpanded}) {
    return AccordionItem(
      title: title,
      content: content,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

class Accordion extends StatefulWidget {
  final List<AccordionItem> items;
  final bool allowMultipleOpen;
  final Color? headerColor;
  final Color? contentBackgroundColor;

  const Accordion({
    super.key,
    required this.items,
    this.allowMultipleOpen = false,
    this.headerColor,
    this.contentBackgroundColor,
  });

  @override
  State<Accordion> createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  late List<AccordionItem> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.items;
  }

  void _toggleExpand(int index) {
    setState(() {
      if (widget.allowMultipleOpen) {
        _items[index] =
            _items[index].copyWith(isExpanded: !_items[index].isExpanded);
      } else {
        _items = _items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return item.copyWith(isExpanded: i == index ? !item.isExpanded : false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      expandedHeaderPadding: EdgeInsets.zero,
      elevation: 1,
      expansionCallback: (index, isExpanded) {
        _toggleExpand(index);
      },
      children: _items.map((item) {
        return ExpansionPanel(
          canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return Container(
              color: widget.headerColor ?? Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.all(16),
              alignment: Alignment.centerLeft,
              child: Text(
                item.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          },
          body: Container(
            width: double.infinity,
            color: widget.contentBackgroundColor ??
                Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.all(16),
            child: item.content,
          ),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}
