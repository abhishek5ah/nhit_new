import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import '../models/bank_models/bank_letter_model.dart';

class BankLetterPreviewFullPage extends StatefulWidget {
  final String letterId;

  const BankLetterPreviewFullPage({
    super.key,
    required this.letterId,
  });

  @override
  State<BankLetterPreviewFullPage> createState() => _BankLetterPreviewFullPageState();
}

class _BankLetterPreviewFullPageState extends State<BankLetterPreviewFullPage> {
  // BankLetterService will be used for API calls in production
  BankLetter? _letter;
  bool _isLoading = true;
  bool _isSending = false;
  bool _isDownloading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLetterData();
  }

  Future<void> _loadLetterData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // TODO: Replace with actual API call to fetch letter by ID
      // final letter = await _bankLetterService.getBankLetterById(widget.letterId);
      
      // Mock data for now - replace with actual API response
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _letter = BankLetter(
          id: widget.letterId,
          reference: 'NHIT/BL/${widget.letterId.substring(0, 8).toUpperCase()}',
          type: 'GENERAL_LETTER',
          bank: 'State Bank of India - Connaught Place Branch',
          subject: 'Request for Account Statement',
          content: '''Dear Sir/Madam,

We are writing to request a detailed account statement for our company account.

Account Details:
- Account Number: 1234567890
- Account Name: National Highways Infra Trust
- Period: January 2024 to December 2024

We would appreciate your prompt attention to this matter.

Thank you for your cooperation.

Yours faithfully,
Admin User
Finance Manager''',
          status: 'LETTER_STATUS_APPROVED',
          date: DateFormat('dd MMMM yyyy').format(DateTime.now()),
          createdBy: 'Admin User',
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load letter: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadLetter() async {
    if (_letter == null) return;

    setState(() => _isDownloading = true);

    try {
      // TODO: Implement PDF download functionality
      // await _bankLetterService.downloadLetterPDF(widget.letterId);
      
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Letter downloaded successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${e.toString()}'),
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

  Future<void> _sendLetter() async {
    if (_letter == null) return;

    setState(() => _isSending = true);

    try {
      // TODO: Implement send letter functionality (email/SMS)
      // await _bankLetterService.sendLetter(widget.letterId);
      
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Letter sent successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Navigate back to bank letters list
        context.go('/escrow/bank-letter');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Send failed: ${e.toString()}'),
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
        return status;
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
                'Loading letter...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SecondaryButton(
                label: 'Go Back',
                icon: Icons.arrow_back,
                onPressed: () => context.go('/escrow/bank-letter'),
              ),
            ],
          ),
        ),
      );
    }

    if (_letter == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: Text(
            'Letter not found',
            style: theme.textTheme.bodyLarge,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: Column(
        children: [
          _buildHeader(context, colorScheme, theme),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  padding: const EdgeInsets.all(24),
                  child: _buildLetterPreview(context, colorScheme, theme),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.preview,
              size: 24,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bank Letter Preview',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Review and send your bank letter',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SecondaryButton(
            label: 'Download PDF',
            icon: Icons.download,
            onPressed: _isDownloading ? null : _downloadLetter,
          ),
          const SizedBox(width: 12),
          PrimaryButton(
            label: _isSending ? 'Sending...' : 'Send Letter',
            icon: Icons.send,
            onPressed: _isSending ? null : _sendLetter,
          ),
          const SizedBox(width: 12),
          SecondaryButton(
            label: 'Back',
            icon: Icons.arrow_back,
            onPressed: () => context.go('/escrow/bank-letter'),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterPreview(BuildContext context, ColorScheme colorScheme, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // A4 Paper simulation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Letterhead
                _buildLetterhead(theme),
                const SizedBox(height: 32),

                // Letter Reference & Date
                _buildReferenceSection(theme),
                const SizedBox(height: 24),

                // Bank Address
                _buildBankAddress(theme),
                const SizedBox(height: 24),

                // Subject
                _buildSubject(theme),
                const SizedBox(height: 24),

                // Letter Content
                _buildContent(theme),
                const SizedBox(height: 32),

                // Signature Section
                _buildSignature(theme),
                const SizedBox(height: 32),

                // Footer
                _buildFooter(theme),
              ],
            ),
          ),
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.account_balance,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'National Highways Infra Trust',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Banking Operations Department',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 2,
          color: Colors.blue.shade700,
        ),
      ],
    );
  }

  Widget _buildReferenceSection(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ref: NHIT/BL/${widget.letterId.substring(0, 8).toUpperCase()}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Type: ${_getLetterTypeDisplay(_letter!.type)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Date: ${_letter!.date}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Text(
                _getStatusDisplay(_letter!.status),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.green.shade700,
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
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'The Branch Manager',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          _letter!.bank,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '15, Parliament Street, Connaught Place',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.black87,
          ),
        ),
        Text(
          'New Delhi - 110001',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSubject(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subject: ${_letter!.subject}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Text(
      _letter!.content,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: Colors.black87,
        height: 1.6,
      ),
    );
  }

  Widget _buildSignature(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 48),
        Text(
          _letter!.createdBy,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Authorized Signatory',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Email: admin@nhit.co.in',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          'Phone: +91 9876543210',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            'National Highways Infra Trust',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Corporate Office: G-5 & 6, Sector 10, Dwarka, New Delhi - 110075',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Email: info@nhit.co.in | Phone: +91 11 2345 6789',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
