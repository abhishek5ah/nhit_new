import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PaymentNotePdf {
  static Future<void> generatePdf(BuildContext context, dynamic note) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text('Payment Note (${note.paymentNoteNo})',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          pw.Text('NHIT Western Projects Private Limited',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Text('Note for Approval of Payment',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Date: ${note.date}'),
              pw.Text('Note No.: ${note.noteNo}'),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Green Note No: ${note.greenNoteNo}'),
              pw.Text('Department: ${note.department}'),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Green Note App. Date: ${note.greenNoteAppDate}'),
              pw.Text('Green Note Approver: ${note.greenNoteApprover}'),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text('Subject: ${note.subject}'),
          pw.SizedBox(height: 8),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Vendor Code: ${note.vendorCode}'),
              pw.Text('Vendor Name: ${note.vendorName}'),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Invoice No.: ${note.invoiceNo}'),
              pw.Text('Date: ${note.invoiceDate}'),
              pw.Text('Amount: ${note.invoiceAmount}'),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text('Invoice Approved by: ${note.invoiceApprovedBy}'),
          pw.SizedBox(height: 4),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('LOA/PO No.: ${note.loaPoNo}'),
              pw.Text('LOA/PO Amount: ${note.loaPoAmount}'),
              pw.Text('LOA/PO Date: ${note.loaPoDate}'),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text('Summary of Payment', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          _pdfSummaryTable(note.paymentSummary),
          pw.SizedBox(height: 10),
          pw.Text('Net Payable Amount (Words): ${note.paymentSummary.netPayableWords}'),
          pw.SizedBox(height: 16),
          pw.Text('Bank Details:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Name of Account holder: ${note.bankAccountHolder}'),
          pw.Text('Bank Name: ${note.bankName}'),
          pw.Text('Bank Account: ${note.bankAccountNumber}'),
          pw.Text('IFSC: ${note.bankIfsc}'),
          pw.SizedBox(height: 10),
          pw.Text('Recommendation of Payment', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(note.recommendation),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: "Payment Note ${note.paymentNoteNo}.pdf",
    );
  }

  static pw.Widget _pdfSummaryTable(dynamic summary) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text('Particulars', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text('Payable Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        _pdfSummaryRow('Taxable Amount', summary.taxableAmount),
        _pdfSummaryRow('Add : GST', summary.gst),
        _pdfSummaryRow('Add: Other charges', summary.otherCharges),
        _pdfSummaryRow('Gross Amount', summary.grossAmount),
        _pdfSummaryRow('Less: TDS @ 2% U/s 194C', summary.tds),
        _pdfSummaryRow('Net Payable Amount', summary.netPayableAmount),
        _pdfSummaryRow('Net Payable Amount (Round Off)', summary.netPayableAmountRoundOff),
      ],
    );
  }

  static pw.TableRow _pdfSummaryRow(String k, String v) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(k)),
        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(v)),
      ],
    );
  }
}
