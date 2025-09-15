import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/profile_card.dart';
import 'package:ppv_components/core/utils/status_utils.dart';
import 'package:ppv_components/core/utils/responsive.dart';
import 'package:ppv_components/features/finance/data/mock_invoice_db.dart';

class InvoiceGridView extends StatefulWidget {
  const InvoiceGridView({super.key});

  @override
  State<InvoiceGridView> createState() => _InvoiceGridViewState();
}

class _InvoiceGridViewState extends State<InvoiceGridView> {
  int? _hoveredCardIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = getResponsiveCrossAxisCount(screenWidth);

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: mockInvoices.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.3,
                ),
                itemBuilder: (context, index) {
                  final invoice = mockInvoices[index];
                  final isHovered = _hoveredCardIndex == index;

                  return MouseRegion(
                    onEnter: (_) => setState(() => _hoveredCardIndex = index),
                    onExit: (_) => setState(() => _hoveredCardIndex = null),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 4),
                      decoration: BoxDecoration(
                        border: isHovered
                            ? Border(
                          top: BorderSide(
                            color: getStatusColor(invoice.status),
                            width: 6,
                          ),
                          left: BorderSide(
                            color: getStatusColor(invoice.status),
                            width: 6,
                          ),
                        )
                            : null,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                        ),
                      ),
                      child: ProfileInfoCard(
                        title: invoice.customer,
                        company: invoice.customer,
                        email: invoice.email,
                        phone: invoice.phone,
                        source: invoice.source,
                        topBarColor: getStatusColor(invoice.status),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
