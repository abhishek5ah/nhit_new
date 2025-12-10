import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import '../models/bank_models/bank_letter_model.dart';
import '../services/letter_storage_service.dart';

class BankLetterFullPreview extends StatefulWidget {
  final String letterId;

  const BankLetterFullPreview({
    super.key,
    required this.letterId,
  });

  @override
  State<BankLetterFullPreview> createState() => _BankLetterFullPreviewState();
}

class _BankLetterFullPreviewState extends State<BankLetterFullPreview> {
  final LetterStorageService _storageService = LetterStorageService();
  BankLetter? _letter;
  bool _isLoading = true;
  bool _isDownloading = false;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLetter();
  }

  void _loadLetter() {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Try to get letter from storage
    try {
      final letter = _storageService.getLetter(widget.letterId);
      
      if (mounted) {
        setState(() {
          if (letter != null) {
            _letter = letter;
            _isLoading = false;
          } else {
            // Create fallback dummy letter if not found
            _letter = _createFallbackLetter();
            _error = null;
            _isLoading = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _letter = _createFallbackLetter();
          _error = null;
          _isLoading = false;
        });
      }
    }
  }

  BankLetter _createFallbackLetter() {
    // Create a fallback letter with dummy data if storage fails
    return BankLetter(
      id: widget.letterId,
      reference: 'NHIT/DRAFT/${DateTime.now().year}/000000',
      type: 'GENERAL_LETTER',
      subject: 'Bank Letter Preview',
      bank: 'Sample Bank - Main Branch',
      status: 'LETTER_STATUS_DRAFT',
      createdBy: 'Admin User',
      date: DateFormat('dd MMMM yyyy').format(DateTime.now()),
      content: 'This is a preview of your bank letter. The original data could not be loaded.',
    );
  }

  Future<void> _downloadPDF() async {
    if (_letter == null) return;

    setState(() => _isDownloading = true);

    try {
      final pdf = await _buildPdfDocument(_letter!);
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'bank_letter_${_letter!.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Open locally
      await OpenFilex.open(file.path);

      // Placeholder for MinIO upload when endpoint is available
      developer.log('MinIO upload pending for file: $fileName (no endpoint configured)');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'PDF saved to your device.\nLocation: $fileName',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      developer.log('PDF Download Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download PDF: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<pw.Document> _buildPdfDocument(BankLetter letter) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        build: (context) => [
          pw.Text('National Highways Infra Trust',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Banking Operations Department',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
          pw.SizedBox(height: 16),
          pw.Divider(),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Reference: ${letter.reference}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 6),
                  pw.Text('Letter Type: ${_getLetterTypeDisplay(letter.type)}'),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Date: ${letter.date}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 6),
                  pw.Text('Status: ${_getStatusDisplay(letter.status)}'),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Text('To,', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('The Branch Manager'),
          pw.Text(letter.bank),
          pw.SizedBox(height: 6),
          pw.Text('Subject: ${letter.subject}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
          pw.SizedBox(height: 18),
          pw.Text(letter.content, style: const pw.TextStyle(height: 1.4)),
          pw.SizedBox(height: 24),
          pw.Text('Yours faithfully,'),
          pw.SizedBox(height: 24),
          pw.Text(letter.createdBy, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Authorized Signatory'),
        ],
      ),
    );
    return doc;
  }

  Future<void> _sendLetter() async {
    if (_letter == null) return;

    setState(() => _isSending = true);

    try {
      // Simulate sending
      await Future.delayed(const Duration(seconds: 2));

      developer.log('Send Letter initiated for: ${widget.letterId}');
      developer.log('Letter Type: ${_letter!.type}');
      developer.log('Bank: ${_letter!.bank}');
      developer.log('Subject: ${_letter!.subject}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.send, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Letter sent successfully!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate back to bank letters list after successful send
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.go('/escrow/bank-letter');
          }
        });
      }
    } catch (e) {
      developer.log('Send Letter Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send letter: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  String _getLetterTypeDisplay(String type) {
    switch (type) {
      case 'GENERAL_LETTER':
        return 'General Letter';
      case 'TRANSFER_LETTER':
        return 'Transfer Letter';
      case 'PAYMENT_LETTER':
        return 'Payment Letter';
      default:
        return type.replaceAll('_', ' ');
    }
  }

  String _getStatusDisplay(String status) {
    switch (status) {
      case 'LETTER_STATUS_DRAFT':
        return 'Draft';
      case 'LETTER_STATUS_PENDING_APPROVAL':
        return 'Pending Approval';
      case 'LETTER_STATUS_APPROVED':
        return 'Approved';
      case 'LETTER_STATUS_SENT':
        return 'Sent';
      case 'LETTER_STATUS_ACKNOWLEDGED':
        return 'Acknowledged';
      default:
        return status.replaceAll('_', ' ');
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'LETTER_STATUS_DRAFT':
        return Colors.grey;
      case 'LETTER_STATUS_PENDING_APPROVAL':
        return Colors.orange;
      case 'LETTER_STATUS_APPROVED':
        return Colors.green;
      case 'LETTER_STATUS_SENT':
        return Colors.blue;
      case 'LETTER_STATUS_ACKNOWLEDGED':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Loading letter preview...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null || _letter == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Letter not found',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SecondaryButton(
                label: 'Back to Letters',
                icon: Icons.arrow_back,
                onPressed: () => context.go('/escrow/bank-letter'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal:24, vertical:24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, colorScheme, theme),
              const SizedBox(height: 16),
              _buildLetterContent(context, colorScheme, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme, ThemeData theme) {
    final isCompact = MediaQuery.of(context).size.width < 720;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withAlpha(80),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(38),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.preview_outlined,
                  size: 26,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preview Bank Letter',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Review details for ${_getLetterTypeDisplay(_letter!.type)} and proceed with download or send',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withAlpha(160),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCompact) const SizedBox(width: 16),
              if (!isCompact)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _headerActions(includeSpacing: true),
                ),
            ],
          ),
          if (isCompact) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _headerActions(),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _headerActions({bool includeSpacing = false}) {
    final actions = <Widget>[
      SecondaryButton(
        label: _isDownloading ? 'Downloading...' : 'Download Letter',
        icon: _isDownloading ? Icons.hourglass_empty : Icons.download,
        onPressed: _isDownloading ? null : _downloadPDF,
      ),
      PrimaryButton(
        label: _isSending ? 'Sending...' : 'Send Letter',
        icon: _isSending ? Icons.hourglass_empty : Icons.send,
        onPressed: _isSending ? null : _sendLetter,
      ),
      SecondaryButton(
        label: 'Cancel',
        onPressed: () => context.go('/escrow/bank-letter'),
      ),
    ];

    if (!includeSpacing) {
      return actions;
    }

    final spaced = <Widget>[];
    for (var i = 0; i < actions.length; i++) {
      spaced.add(actions[i]);
      if (i != actions.length - 1) {
        spaced.add(const SizedBox(width: 12));
      }
    }
    return spaced;
  }

  Widget _buildLetterContent(BuildContext context, ColorScheme colorScheme, ThemeData theme) {
    final placeholderTokens = _extractTemplatePlaceholders();
    final sanitizedContent = _getSanitizedContent();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withAlpha(60),
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            spreadRadius: 2,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (placeholderTokens.isNotEmpty) ...[
            _buildTemplateDetails(theme, colorScheme, placeholderTokens),
            const SizedBox(height: 32),
          ],
          _buildLetterhead(theme),
          const SizedBox(height: 40),
          _buildReferenceSection(theme),
          const SizedBox(height: 32),
          _buildBankAddress(theme),
          const SizedBox(height: 32),
          _buildSubject(theme),
          const SizedBox(height: 24),
          _buildContent(theme, sanitizedContent),
          const SizedBox(height: 40),
          _buildSignature(theme),
          const SizedBox(height: 40),
          _buildFooter(theme),
        ],
      ),
    );
  }

  Widget _buildLetterhead(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.account_balance,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'National Highways Infra Trust',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Banking Operations Department',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceSection(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reference: ${_letter!.reference}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  _getLetterTypeDisplay(_letter!.type),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Date: ${_letter!.date}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(_letter!.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _getStatusColor(_letter!.status).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _getStatusDisplay(_letter!.status),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _getStatusColor(_letter!.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBankAddress(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'To,',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'The Branch Manager',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          _letter!.bank,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '15, Parliament Street, Connaught Place',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.black87,
          ),
        ),
        Text(
          'New Delhi - 110001',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSubject(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Subject: ',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextSpan(
              text: _letter!.subject,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, String displayContent) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        displayContent,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: Colors.black87,
          height: 1.8,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildSignature(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 60),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Yours faithfully,',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.black87,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _letter!.createdBy,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Authorized Signatory',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.email, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'admin@nhit.co.in',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    '+91 9876543210',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade400,
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            'National Highways Infra Trust',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Corporate Office: G-5 & 6, Sector 10, Dwarka, New Delhi - 110075',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Email: info@nhit.co.in | Phone: +91 11 2345 6789 | Website: www.nhit.co.in',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateDetails(
    ThemeData theme,
    ColorScheme colorScheme,
    Set<String> placeholders,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withAlpha(60),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(28),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Template Details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'The following placeholders still need actual data before sending.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withAlpha(160),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: placeholders
                .map(
                  (token) => Chip(
                    label: Text(token),
                    backgroundColor: colorScheme.primary.withAlpha(20),
                    labelStyle: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Set<String> _extractTemplatePlaceholders() {
    if (_letter == null || _letter!.content.isEmpty) {
      return {};
    }
    final regex = RegExp(r'\{\{?([a-zA-Z0-9_]+)\}\}?');
    final matches = regex.allMatches(_letter!.content);
    return matches.map((match) => match.group(1)!).toSet();
  }

  String _getSanitizedContent() {
    if (_letter == null) {
      return '';
    }
    final regex = RegExp(r'\{\{?[a-zA-Z0-9_]+\}\}?');
    return _letter!.content.replaceAllMapped(
      regex,
      (_) => '________',
    );
  }
}
