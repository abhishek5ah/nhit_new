import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/profile_card.dart';
import 'package:ppv_components/core/utils/status_utils.dart';
import 'package:ppv_components/features/bank_rtgs_neft/models/bank_models/bank_rtgs_neft_model.dart';

class RtgsGridView extends StatefulWidget {
  final List<BankRtgsNeft> rtgsList;
  final int rowsPerPage;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int?> onRowsPerPageChanged;

  const RtgsGridView({
    super.key,
    required this.rtgsList,
    required this.rowsPerPage,
    required this.currentPage,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
  });

  @override
  State<RtgsGridView> createState() => _RtgsGridViewState();
}

class _RtgsGridViewState extends State<RtgsGridView> {
  int? _hoveredCardIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Use a responsive cross axis count function if you have one, else default
    int crossAxisCount = 2;
    if (screenWidth > 1200) {
      crossAxisCount = 4;
    } else if (screenWidth > 800) {
      crossAxisCount = 3;
    }

    final start = widget.currentPage * widget.rowsPerPage;
    final end = (start + widget.rowsPerPage).clamp(0, widget.rtgsList.length);
    final paginatedRtgs = widget.rtgsList.sublist(start, end);

    final totalPages = (widget.rtgsList.length / widget.rowsPerPage).ceil();

    // Pagination window logic for showing just 3 page buttons at a time
    const windowSize = 3;
    int startWindow = 0;
    int endWindow = totalPages;
    if (totalPages > windowSize) {
      if (widget.currentPage == 0) {
        startWindow = 0;
        endWindow = windowSize;
      } else if (widget.currentPage == totalPages - 1) {
        startWindow = totalPages - windowSize;
        endWindow = totalPages;
      } else {
        startWindow = widget.currentPage - 1;
        endWindow = widget.currentPage + 2;
      }
    }

    return Column(
      children: [
        Expanded(
          child: Container(
            color: colorScheme.surfaceContainerHigh,
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              itemCount: paginatedRtgs.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.2, // adjust for compact card height
              ),
              itemBuilder: (context, index) {
                final rtgs = paginatedRtgs[index];
                final globalIndex = start + index;
                final isHovered = _hoveredCardIndex == globalIndex;

                final Color statusColor =
                gridStatusColors[globalIndex % gridStatusColors.length];

                return MouseRegion(
                  onEnter: (_) => setState(() => _hoveredCardIndex = globalIndex),
                  onExit: (_) => setState(() => _hoveredCardIndex = null),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      border: isHovered
                          ? Border(
                        top: BorderSide(color: statusColor, width: 6),
                        left: BorderSide(color: statusColor, width: 6),
                      )
                          : null,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(22),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                      color: colorScheme.surface,
                    ),
                    child: ProfileCard(
                      invoiceId: '#RTGS-${rtgs.id.toString().padLeft(3, '0')}',
                      topBarColor: statusColor,
                      fields: {
                        'S.No': rtgs.slNo,
                        'Vendor': rtgs.vendorName,
                        'Amount': rtgs.amount,
                        'Date': rtgs.date,
                        'Status': rtgs.status,
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Showing ${widget.rtgsList.isEmpty ? 0 : start + 1} to $end of ${widget.rtgsList.length} entries",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: widget.currentPage > 0
                        ? () => widget.onPageChanged(widget.currentPage - 1)
                        : null,
                  ),
                  for (int i = startWindow; i < endWindow; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: i == widget.currentPage
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerLow,
                          foregroundColor: i == widget.currentPage
                              ? Colors.white
                              : colorScheme.onSurface,
                          padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(0, 36),
                        ),
                        child: Text("${i + 1}"),
                        onPressed: () => widget.onPageChanged(i),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: widget.currentPage < totalPages - 1
                        ? () => widget.onPageChanged(widget.currentPage + 1)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: widget.rowsPerPage,
                    items: [5, 10, 20, 50]
                        .map((count) => DropdownMenuItem<int>(
                      value: count,
                      child: Text('$count'),
                    ))
                        .toList(),
                    onChanged: widget.onRowsPerPageChanged,
                    style: Theme.of(context).textTheme.bodyLarge,
                    underline: const SizedBox(),
                  ),
                  Text("page", style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
