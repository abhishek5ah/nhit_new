import 'package:flutter/material.dart';

class CustomPaginationBar extends StatelessWidget {
  final int totalItems;
  final int currentPage;
  final int rowsPerPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int?> onRowsPerPageChanged;
  final List<int> availableRowsPerPage;

  const CustomPaginationBar({
    super.key,
    required this.totalItems,
    required this.currentPage,
    required this.rowsPerPage,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
    this.availableRowsPerPage = const [5, 10, 20, 50],
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final totalPages = (totalItems / rowsPerPage).ceil();
    final startItem = totalItems == 0 ? 0 : (currentPage * rowsPerPage) + 1;
    final endItem = (startItem + rowsPerPage - 1).clamp(0, totalItems);

    int windowSize = 3;
    int startWindow = 0;
    int endWindow = totalPages;

    // Logic to determine the pagination window to display
    if (totalPages > windowSize) {
      if (currentPage <= 1) {
        startWindow = 0;
        endWindow = windowSize;
      } else if (currentPage >= totalPages - 2) {
        startWindow = totalPages - windowSize;
        endWindow = totalPages;
      } else {
        startWindow = currentPage - 1;
        endWindow = currentPage + 2;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Displaying the "Showing X to Y of Z entries" text
          Text(
            "Showing $startItem to $endItem of $totalItems entries",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Row(
            children: [
              // "Back" button
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: currentPage > 0
                    ? () => onPageChanged(currentPage - 1)
                    : null,
              ),

              // Page number buttons
              for (int i = startWindow; i < endWindow; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: i == currentPage
                          ? colorScheme.primary
                          : colorScheme.surfaceContainer,
                      foregroundColor: i == currentPage
                          ? Colors.white
                          : colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      minimumSize: const Size(40, 40),
                    ),
                    onPressed: () => onPageChanged(i),
                    child: Text('${i + 1}'),
                  ),
                ),

              // "Forward" button
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: currentPage < totalPages - 1
                    ? () => onPageChanged(currentPage + 1)
                    : null,
              ),
              const SizedBox(width: 20),

              // "Rows per page" dropdown
              DropdownButton<int>(
                value: rowsPerPage,
                items: availableRowsPerPage
                    .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                    .toList(),
                onChanged: onRowsPerPageChanged,
                style: Theme.of(context).textTheme.bodyMedium,
                underline: const SizedBox(),
              ),
              const SizedBox(width: 8),
              Text("page", style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

