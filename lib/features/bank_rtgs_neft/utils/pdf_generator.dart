import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/bank_models/bank_letter_form_data.dart';

class BankLetterPdfGenerator {
  static Future<void> generateAndDownloadPdf(BankLetterFormData formData) async {
    final pdf = pw.Document();

    // Add page to PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              pw.SizedBox(height: 30),

              // Date
              pw.Align(
                alignment: pw.Alignment.topRight,
                child: pw.Text(
                  'Date: ${formData.date.day}/${formData.date.month}/${formData.date.year}',
                  style: pw.TextStyle(fontSize: 11),
                ),
              ),
              pw.SizedBox(height: 20),

              // Bank Details
              pw.Text(
                'To,',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'The Manager,',
                style: pw.TextStyle(fontSize: 11),
              ),
              pw.Text(
                formData.bankName,
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                formData.branchName,
                style: pw.TextStyle(fontSize: 11),
              ),
              pw.Text(
                formData.bankAddress,
                style: pw.TextStyle(fontSize: 11),
              ),
              pw.SizedBox(height: 20),

              // Subject
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Subject: ',
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      formData.subject,
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Salutation
              pw.Text(
                'Dear Sir/Madam,',
                style: pw.TextStyle(fontSize: 11),
              ),
              pw.SizedBox(height: 15),

              // Content
              pw.Text(
                formData.content,
                style: pw.TextStyle(fontSize: 11, lineSpacing: 1.5),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 20),

              // Account Details Section
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Account Details:',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    _buildDetailRow('Account Holder Name:', formData.accountHolderName),
                    _buildDetailRow('Account Number:', formData.accountNumber),
                    _buildDetailRow('IFSC Code:', formData.ifscCode),
                    _buildDetailRow('Bank:', formData.bankName),
                    _buildDetailRow('Branch:', formData.branchName),
                  ],
                ),
              ),
              pw.SizedBox(height: 25),

              // Closing
              pw.Text(
                'Thank you for your cooperation.',
                style: pw.TextStyle(fontSize: 11),
              ),
              pw.SizedBox(height: 20),

              pw.Text(
                'Yours faithfully,',
                style: pw.TextStyle(fontSize: 11),
              ),
              pw.SizedBox(height: 30),

              // Signature Section
              pw.Text(
                formData.requestedBy,
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                formData.designation,
                style: pw.TextStyle(fontSize: 11),
              ),
            ],
          );
        },
      ),
    );

    // Save and download PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'BANK LETTER',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Container(
          width: 100,
          height: 2,
          color: PdfColors.blue800,
        ),
      ],
    );
  }

  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  // Preview PDF without downloading
  static Future<void> previewPdf(BankLetterFormData formData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              pw.SizedBox(height: 30),
              pw.Align(
                alignment: pw.Alignment.topRight,
                child: pw.Text(
                  'Date: ${formData.date.day}/${formData.date.month}/${formData.date.year}',
                  style: pw.TextStyle(fontSize: 11),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'To,',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text('The Manager,', style: pw.TextStyle(fontSize: 11)),
              pw.Text(
                formData.bankName,
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(formData.branchName, style: pw.TextStyle(fontSize: 11)),
              pw.Text(formData.bankAddress, style: pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 20),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Subject: ',
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      formData.subject,
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Dear Sir/Madam,', style: pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 15),
              pw.Text(
                formData.content,
                style: pw.TextStyle(fontSize: 11, lineSpacing: 1.5),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Account Details:',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    _buildDetailRow('Account Holder Name:', formData.accountHolderName),
                    _buildDetailRow('Account Number:', formData.accountNumber),
                    _buildDetailRow('IFSC Code:', formData.ifscCode),
                    _buildDetailRow('Bank:', formData.bankName),
                    _buildDetailRow('Branch:', formData.branchName),
                  ],
                ),
              ),
              pw.SizedBox(height: 25),
              pw.Text('Thank you for your cooperation.', style: pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 20),
              pw.Text('Yours faithfully,', style: pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 30),
              pw.Text(
                formData.requestedBy,
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(formData.designation, style: pw.TextStyle(fontSize: 11)),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'bank_letter.pdf');
  }
}
