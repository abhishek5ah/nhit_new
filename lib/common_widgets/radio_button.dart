import 'package:flutter/material.dart';

class RadioButtonGroup<T> extends StatelessWidget {
  final List<T> options;
  final T? selectedOption;
  final ValueChanged<T?> onChanged;
  final String Function(T) labelBuilder;
  final EdgeInsetsGeometry optionSpacing;

  const RadioButtonGroup({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
    required this.labelBuilder,
    this.optionSpacing = const EdgeInsets.only(bottom: 12),
  });

  @override
  Widget build(BuildContext context) {
    final children = options.map((option) {
      return Padding(
        padding: optionSpacing,
        child: InkWell(
          onTap: () => onChanged(option),
          borderRadius: BorderRadius.circular(6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<T>(
                value: option,
                groupValue: selectedOption,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.padded,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  labelBuilder(option),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}