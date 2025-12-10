import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/general_letter_form.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/payment_letter_form.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/transfer_letter_form.dart';

class CreateBankLetterPage extends StatefulWidget {
  const CreateBankLetterPage({super.key});

  @override
  State<CreateBankLetterPage> createState() => _CreateBankLetterPageState();
}

class _CreateBankLetterPageState extends State<CreateBankLetterPage> {
  String? selectedLetterType;
  String? hoveredLetterType;

  final List<Map<String, dynamic>> letterTypes = [
    {
      'type': 'Transfer Letter',
      'icon': Icons.swap_horiz,
      'color': Colors.cyan,
      'description': 'For fund transfers between accounts',
    },
    {
      'type': 'Payment Letter',
      'icon': Icons.payment,
      'color': Colors.green,
      'description': 'For payment authorizations',
    },
    {
      'type': 'General Letter',
      'icon': Icons.description,
      'color': Colors.orange,
      'description': 'For general banking requests',
    },
  ];

  void _resetLetterType() {
    setState(() {
      selectedLetterType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal:24, vertical:24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, constraints),
                  const SizedBox(height: 24),
                  _buildFormSection(context, constraints),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BoxConstraints constraints) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isSmallScreen = constraints.maxWidth < 900;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_circle_outline,
                  size: 28,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Bank Letter',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Generate professional bank letters for transfers and payments',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isSmallScreen) ...[
                const SizedBox(width: 16),
                SecondaryButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icons.arrow_back,
                  label: 'Back',
                ),
              ],
            ],
          ),
          if (isSmallScreen) ...[
            const SizedBox(height: 16),
            SecondaryButton(
              onPressed: () => Navigator.pop(context),
              icon: Icons.arrow_back,
              label: 'Back',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormSection(BuildContext context, BoxConstraints constraints) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isSmallScreen = constraints.maxWidth < 900;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Letter Details',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Letter Type Label
          Row(
            children: [
              Text(
                'Letter Type',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Letter Type Cards
          isSmallScreen
              ? Column(
            children: letterTypes.map((type) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildLetterTypeCard(
                  context,
                  type: type['type'],
                  icon: type['icon'],
                  color: type['color'],
                  description: type['description'],
                ),
              );
            }).toList(),
          )
              : Row(
            children: letterTypes.map((type) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildLetterTypeCard(
                    context,
                    type: type['type'],
                    icon: type['icon'],
                    color: type['color'],
                    description: type['description'],
                  ),
                ),
              );
            }).toList(),
          ),

          // Display selected letter form
          if (selectedLetterType != null) ...[
            const SizedBox(height: 24),
            _buildSelectedLetterForm(),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedLetterForm() {
    switch (selectedLetterType) {
      case 'Transfer Letter':
        return CreateTransferLetterForm(onCancel: _resetLetterType);
      case 'Payment Letter':
        return CreatePaymentLetterForm(onCancel: _resetLetterType);
      case 'General Letter':
        return CreateGeneralLetterForm(onCancel: _resetLetterType);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLetterTypeCard(
      BuildContext context, {
        required String type,
        required IconData icon,
        required Color color,
        required String description,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isSelected = selectedLetterType == type;
    final isHovered = hoveredLetterType == type;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hoveredLetterType = type;
        });
      },
      onExit: (_) {
        setState(() {
          hoveredLetterType = null;
        });
      },
      child: InkWell(
        onTap: () {
          setState(() {
            selectedLetterType = type;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 180,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected || isHovered ? colorScheme.primary : colorScheme.outline,
              width: isSelected || isHovered ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                type,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
