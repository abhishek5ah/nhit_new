import 'package:flutter/material.dart';
import 'package:ppv_components/features/payment_notes/widget/detail_page_widgets/payment_note_pdf.dart';

class PaymentNoteSummary extends StatelessWidget {
  final dynamic note;
  const PaymentNoteSummary({required this.note, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Note (${note.paymentNoteNo})', style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => PaymentNotePdf.generatePdf(context, note),
          child: const Text('Download'),
        ),
        Center(
          child: Column(
            children: [
              Text(
                'NHIT Western Projects Private Limited',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Note for Approval of Payment',
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        DefaultTextStyle(
          style: theme.textTheme.bodyMedium!.copyWith(height: 2.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Date: ${note.date}'),
                  Text('Note No.: ${note.noteNo}'),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Green Note No: ${note.greenNoteNo}'),
                  Text('Department: ${note.department}'),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Green Note App. Date: ${note.greenNoteAppDate}'),
                  Text('Green Note Approver: ${note.greenNoteApprover}'),
                ],
              ),
              const SizedBox(height: 12),
              Text('Subject: ${note.subject}'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Vendor Code: ${note.vendorCode}'),
                  Text('Vendor Name: ${note.vendorName}'),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Invoice No.: ${note.invoiceNo}'),
                  Text('Date: ${note.invoiceDate}'),
                  Text('Amount: ${note.invoiceAmount}'),
                ],
              ),
              const SizedBox(height: 6),
              Text('Invoice Approved by: ${note.invoiceApprovedBy}'),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('LOA/PO No.: ${note.loaPoNo}'),
                  Text('LOA/PO Amount: ${note.loaPoAmount}'),
                  Text('LOA/PO Date: ${note.loaPoDate}'),
                ],
              ),
              const SizedBox(height: 16),
              Text('Summary of payment', style: theme.textTheme.titleMedium),
              _buildSummaryTable(context, note.paymentSummary),
              const SizedBox(height: 8),
              Text('Net Payable Amount (Words): ${note.paymentSummary.netPayableWords}'),
              const SizedBox(height: 16),
              Text('Bank Details:', style: theme.textTheme.titleMedium),
              Text('Name of Account holder: ${note.bankAccountHolder}'),
              Text('Bank Name: ${note.bankName}'),
              Text('Bank Account: ${note.bankAccountNumber}'),
              Text('IFSC: ${note.bankIfsc}'),
              const SizedBox(height: 10),
              Text('Recommendation of Payment', style: theme.textTheme.titleMedium),
              Text(note.recommendation),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Approval Matrix', style: theme.textTheme.titleMedium),
        DataTable(
          columns: const [
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Designation')),
            DataColumn(label: Text('Date & Signature')),
          ],
          rows: note.approvalMatrix.map<DataRow>((entry) {
            return DataRow(
              cells: [
                DataCell(Text(entry.role)),
                DataCell(Text(entry.name)),
                DataCell(Text(entry.designation)),
                DataCell(Text(entry.dateSignature)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSummaryTable(BuildContext context, dynamic summary) {
    final colorScheme = Theme.of(context).colorScheme;
    return Table(
      border: TableBorder.all(color: colorScheme.outline, width: 1),
      columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(2)},
      children: [
        TableRow(
          decoration: BoxDecoration(color: colorScheme.surfaceContainer),
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Particulars', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Payable Amount', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        _buildSummaryTableRow('Taxable Amount', summary.taxableAmount),
        _buildSummaryTableRow('Add : GST', summary.gst),
        _buildSummaryTableRow('Add: Other charges', summary.otherCharges),
        _buildSummaryTableRow('Gross Amount', summary.grossAmount),
        _buildSummaryTableRow('Less: TDS @ 2% U/s 194C', summary.tds),
        _buildSummaryTableRow('Net Payable Amount', summary.netPayableAmount),
        _buildSummaryTableRow('Net Payable Amount (Round Off)', summary.netPayableAmountRoundOff),
      ],
    );
  }

  TableRow _buildSummaryTableRow(String key, String value) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(key)),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(value)),
      ],
    );
  }
}
