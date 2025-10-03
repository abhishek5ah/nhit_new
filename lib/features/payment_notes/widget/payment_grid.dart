import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/profile_card.dart';
import 'package:ppv_components/core/utils/responsive.dart';
import 'package:ppv_components/core/utils/status_utils.dart';
import 'package:ppv_components/features/payment_notes/model/payment_notes_model.dart';

class PaymentGrid extends StatefulWidget {
  final List<PaymentNote> paymentList;
  final int rowsPerPage;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int?> onRowsPerPageChanged;

  const PaymentGrid({
    super.key,
    required this.paymentList,
    required this.rowsPerPage,
    required this.currentPage,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
  });

  @override
  State<PaymentGrid> createState() => _PaymentGridState();
}

class _PaymentGridState extends State<PaymentGrid> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = getResponsiveCrossAxisCount(screenWidth);

    final start = widget.currentPage * widget.rowsPerPage;
    final end = (start + widget.rowsPerPage).clamp(0, widget.paymentList.length);
    final paginated = widget.paymentList.sublist(start, end);

    final totalPages = (widget.paymentList.length / widget.rowsPerPage).ceil();

    int windowStart = 0;
    int windowEnd = totalPages;
    const windowSize = 3;

    if (totalPages > windowSize) {
      if (widget.currentPage <= 1) {
        windowStart = 0;
        windowEnd = windowSize;
      } else if (widget.currentPage >= totalPages - 2) {
        windowStart = totalPages - windowSize;
        windowEnd = totalPages;
      } else {
        windowStart = widget.currentPage - 1;
        windowEnd = widget.currentPage + 2;
      }
    }

    return Column(
      children: [
        Expanded(
          child: Container(
            color: colorScheme.surfaceContainerHigh,
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              itemCount: paginated.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.2),
              itemBuilder: (context, index) {
                final payment = paginated[index];
                final globalIndex = start + index;

                final isHovered = _hoveredIndex == globalIndex;

                final color = gridStatusColors[globalIndex % gridStatusColors.length];

                return MouseRegion(
                  onEnter: (_) => setState(() => _hoveredIndex = globalIndex),
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: isHovered
                          ? Border(
                        top: BorderSide(color: color, width: 6),
                        left: BorderSide(color: color, width: 6),
                      )
                          : null,
                    ),
                    child: ProfileCard(
                      invoiceId: '#${payment.sno.toString().padLeft(3, '0')}',
                      topBarColor: color,
                      fields: {
                        'Project Name': payment.projectName,
                        'Vendor Name': payment.vendorName,
                        'Invoice Value': payment.invoiceValue,
                        'Date': payment.date,
                        'Status': payment.status,
                        'Next Approver': payment.nextApprover,
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
                  'Showing ${widget.paymentList.isEmpty ? 0 : start + 1} to $end of ${widget.paymentList.length} entries',
                  style: Theme.of(context).textTheme.bodySmall),
              Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: widget.currentPage > 0
                          ? () => widget.onPageChanged(widget.currentPage - 1)
                          : null),
                  for (int i = windowStart; i < windowEnd; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: i == widget.currentPage
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surfaceContainerLow,
                            foregroundColor: i == widget.currentPage
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                            minimumSize: const Size(28, 36),
                          ),
                          onPressed: () => widget.onPageChanged(i),
                          child: Text('${i + 1}')),
                    )
                  ],
                  IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: widget.currentPage < totalPages - 1
                          ? () => widget.onPageChanged(widget.currentPage + 1)
                          : null),
                  const SizedBox(width: 16),
                  DropdownButton<int>(
                    value: widget.rowsPerPage,
                    items: [5, 10, 20, 50]
                        .map(
                          (e) => DropdownMenuItem<int>(
                        value: e,
                        child: Text(e.toString()),
                      ),
                    )
                        .toList(),
                    onChanged: widget.onRowsPerPageChanged,
                    underline: Container(),
                  ),
                  const SizedBox(width: 8),
                  const Text('page'),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
