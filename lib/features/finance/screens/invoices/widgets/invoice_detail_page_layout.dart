import 'package:flutter/material.dart';
import 'package:ppv_components/features/finance/data/mock_invoice_view.dart';
import 'package:ppv_components/features/finance/screens/invoices/widgets/activity.dart';
import 'package:ppv_components/features/finance/screens/invoices/widgets/invoice_header_widget.dart';
import 'package:ppv_components/features/finance/screens/invoices/widgets/payment_status.dart';
import 'package:ppv_components/features/finance/screens/invoices/widgets/invoice_detail_page.dart';

class InvoiceDetailPageLayout extends StatelessWidget {
  final String invoiceId;
  const InvoiceDetailPageLayout({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    final invoice = mockInvoices.firstWhere(
          (inv) => inv.number == invoiceId,
      orElse: () => mockInvoices.first,
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return Column(
              children: [
                SizedBox(
                  height: 80,
                  child: InvoiceHeaderWidget(invoiceNumber: invoice.number),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Expanded(
                              flex: 2,
                              child: InvoiceDetailsCard(invoice: invoice),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: const [
                            Expanded(flex: 2, child: PaymentStatusWidget()),
                            SizedBox(height: 12),
                            Expanded(flex: 2, child: ActivityWidget()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 80,
                    child: InvoiceHeaderWidget(invoiceNumber: invoice.number), // ✅ fixed
                  ),
                  InvoiceDetailsCard(invoice: invoice),
                  const PaymentStatusWidget(),
                  const ActivityWidget(),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
