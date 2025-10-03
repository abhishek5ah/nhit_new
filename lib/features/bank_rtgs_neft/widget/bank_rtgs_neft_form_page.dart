import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';

class BankRtgsNeftPage extends StatefulWidget {
  const BankRtgsNeftPage({super.key});

  @override
  State<BankRtgsNeftPage> createState() => _BankRtgsNeftPageState();
}

class _BankRtgsNeftPageState extends State<BankRtgsNeftPage> {
  final _formKey = GlobalKey<FormState>();

  String? _templateType;
  String? _project;
  String? _paymentFrom;
  String? _paymentTo;
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();

  final List<String> _templateOptions = [
    '--Select Options--',
    'Any Bulk',
    'SBI Bulk',
    'One To Many Bulk',
    'Any Single',
  ];

  final List<String> _projectOptions = [
    'Select Options',
    'Project A',
    'Project B',
  ];

  final List<String> _bankOptions = [
    'Select',
    'Bank A - 1111',
    'Bank B - 2222',
    'Bank C - 3333',
    'Bank D - 4444',
  ];

  // queue of added items
  final List<Map<String, String>> _queue = [];

  @override
  void dispose() {
    _amountController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Widget _buildLabel(String text, TextStyle? style) {
    return Row(
      children: [
        Flexible(child: Text(text, style: style ?? const TextStyle(fontWeight: FontWeight.w600))),
      ],
    );
  }

  Widget _requiredLabel(String text, Color errorColor, TextStyle? style) {
    return Row(
      children: [
        Flexible(child: Text(text, style: style ?? const TextStyle(fontWeight: FontWeight.w600))),
        const SizedBox(width: 6),
        Text('*', style: TextStyle(color: errorColor)),
      ],
    );
  }

  void _addToQueue() {
    // basic validation: require template, project, paymentFrom, paymentTo and amount
    if ((_templateType == null || _templateType == _templateOptions.first) ||
        (_project == null || _project == _projectOptions.first) ||
        (_paymentFrom == null || _paymentFrom == _bankOptions.first) ||
        (_paymentTo == null || _paymentTo == _bankOptions.first) ||
        (_amountController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill required fields before adding to queue'),
          backgroundColor: Theme.of(context).colorScheme.errorContainer.withOpacity(0.12),
        ),
      );
      return;
    }

    setState(() {
      _queue.add({
        'template': _templateType ?? '',
        'project': _project ?? '',
        'from': _paymentFrom ?? '',
        'to': _paymentTo ?? '',
        'amount': _amountController.text.trim(),
        'purpose': _purposeController.text.trim(),
      });

      // clear form for next entry
      _templateType = null;
      _project = null;
      _paymentFrom = null;
      _paymentTo = null;
      _amountController.clear();
      _purposeController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Added to queue'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _clearFormAndQueue() {
    setState(() {
      _templateType = null;
      _project = null;
      _paymentFrom = null;
      _paymentTo = null;
      _amountController.clear();
      _purposeController.clear();
      _queue.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Cleared request queue and form'),
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final divider = theme.dividerColor;
    final textStyle = theme.textTheme.bodyMedium;
    final boldTextStyle = theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final fullWidth = constraints.maxWidth;
          final isWide = fullWidth > 900;

          // field width calculation for wide layouts (keeps reasonable sizes)
          final sidePadding = 32.0; // used approx when wide
          final fixedTotal = 320.0; // amount + purpose approx
          final remaining = (fullWidth - sidePadding - fixedTotal).clamp(300.0, fullWidth);
          final fieldWidth = (remaining / 4).clamp(140.0, 360.0);

          // NOTE: minWidth set to 0 to avoid forcing overflow inside Wrap
          Widget fieldContainer({required Widget child, double? width}) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 0,
                maxWidth: width ?? double.infinity,
              ),
              child: SizedBox(
                width: width ?? double.infinity,
                child: child,
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("(*) fields are mandatory", style: TextStyle(color: colorScheme.error, fontSize: 13)),
                        const SizedBox(height: 12),

                        // Responsive header: on small widths we stack labels vertically
                        LayoutBuilder(builder: (ctx, headCons) {
                          final smallHeader = headCons.maxWidth < 780;
                          if (smallHeader) {
                            // stacked labels for clarity on mobile / narrow screens
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Template Type', style: TextStyle(fontWeight: FontWeight.bold, color: textStyle?.color)),
                                const SizedBox(height: 6),
                                Text('Project', style: TextStyle(fontWeight: FontWeight.bold, color: textStyle?.color)),
                                const SizedBox(height: 6),
                                Text('Payment From', style: TextStyle(fontWeight: FontWeight.bold, color: textStyle?.color)),
                                const SizedBox(height: 6),
                                Text('Payment To', style: TextStyle(fontWeight: FontWeight.bold, color: textStyle?.color)),
                                const SizedBox(height: 6),
                                Text('Amount', style: TextStyle(fontWeight: FontWeight.bold, color: textStyle?.color)),
                                const SizedBox(height: 6),
                                Text('Purpose', style: TextStyle(fontWeight: FontWeight.bold, color: textStyle?.color)),
                              ],
                            );
                          } else {
                            // original header line for wide screens, using Flexible instead of fixed SizedBox
                            return Container(
                              width: double.infinity,
                              color: colorScheme.surfaceContainerHigh,
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              child: Row(
                                children: [
                                  Expanded(child: Text('Template Type', style: TextStyle(fontWeight: FontWeight.bold, color: textStyle?.color))),
                                  Expanded(child: Text('Project', style: TextStyle(fontWeight: FontWeight.bold, color: textStyle?.color))),
                                  Expanded(child: Text('Payment From', style: TextStyle(fontWeight: FontWeight.bold, color: textStyle?.color))),
                                  Expanded(child: Text('Payment To', style: TextStyle(fontWeight: FontWeight.bold, color: textStyle?.color))),
                                  // For amount & purpose use Flexible with constrained min widths to avoid overflow
                                  Flexible(
                                    flex: 0,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(minWidth: 100, maxWidth: 160),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold, color: textStyle?.color)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    flex: 0,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(minWidth: 120, maxWidth: 220),
                                      child: Text('Purpose', style: TextStyle(fontWeight: FontWeight.bold, color: textStyle?.color)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        }),

                        const SizedBox(height: 16),

                        Form(
                          key: _formKey,
                          child: LayoutBuilder(builder: (ctx, formCons) {
                            final narrow = formCons.maxWidth < 700;
                            // Use Wrap so fields automatically go to next line without overflow
                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              alignment: WrapAlignment.start,
                              children: [
                                // Template Type
                                fieldContainer(
                                  width: isWide && !narrow ? fieldWidth : double.infinity,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _requiredLabel('Template Type', colorScheme.error, boldTextStyle),
                                      const SizedBox(height: 8),
                                      DropdownButtonFormField<String>(
                                        value: (_templateType != null && _templateOptions.contains(_templateType)) ? _templateType : _templateOptions.first,
                                        isExpanded: true,
                                        items: _templateOptions
                                            .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
                                            .toList(),
                                        onChanged: (v) => setState(() => _templateType = v),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(borderSide: BorderSide(color: divider)),
                                          filled: true,
                                          fillColor: colorScheme.surface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Project
                                fieldContainer(
                                  width: isWide && !narrow ? fieldWidth : double.infinity,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _requiredLabel('Project', colorScheme.error, boldTextStyle),
                                      const SizedBox(height: 8),
                                      DropdownButtonFormField<String>(
                                        value: (_project != null && _projectOptions.contains(_project)) ? _project : _projectOptions.first,
                                        isExpanded: true,
                                        items: _projectOptions
                                            .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
                                            .toList(),
                                        onChanged: (v) => setState(() => _project = v),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(borderSide: BorderSide(color: divider)),
                                          filled: true,
                                          fillColor: colorScheme.surface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Payment From
                                fieldContainer(
                                  width: isWide && !narrow ? fieldWidth : double.infinity,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _requiredLabel('Payment From', colorScheme.error, boldTextStyle),
                                      const SizedBox(height: 8),
                                      DropdownButtonFormField<String>(
                                        value: (_paymentFrom != null && _bankOptions.contains(_paymentFrom)) ? _paymentFrom : _bankOptions.first,
                                        isExpanded: true,
                                        items: _bankOptions
                                            .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
                                            .toList(),
                                        onChanged: (v) => setState(() => _paymentFrom = v),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(borderSide: BorderSide(color: divider)),
                                          filled: true,
                                          fillColor: colorScheme.surface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Payment To
                                fieldContainer(
                                  width: isWide && !narrow ? fieldWidth : double.infinity,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _requiredLabel('Payment To', colorScheme.error, boldTextStyle),
                                      const SizedBox(height: 8),
                                      DropdownButtonFormField<String>(
                                        value: (_paymentTo != null && _bankOptions.contains(_paymentTo)) ? _paymentTo : _bankOptions.first,
                                        isExpanded: true,
                                        items: _bankOptions
                                            .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
                                            .toList(),
                                        onChanged: (v) => setState(() => _paymentTo = v),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(borderSide: BorderSide(color: divider)),
                                          filled: true,
                                          fillColor: colorScheme.surface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Amount
                                fieldContainer(
                                  width: isWide && !narrow ? 140 : double.infinity,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Amount', boldTextStyle),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _amountController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(borderSide: BorderSide(color: divider)),
                                          isDense: true,
                                          filled: true,
                                          fillColor: colorScheme.surface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Purpose (multi-line, flexible)
                                fieldContainer(
                                  width: isWide && !narrow ? 180 : double.infinity,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Purpose', boldTextStyle),
                                      const SizedBox(height: 8),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(minHeight: 56, maxHeight: 220),
                                        child: TextFormField(
                                          controller: _purposeController,
                                          maxLines: null,
                                          minLines: 2,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(borderSide: BorderSide(color: divider)),
                                            isDense: true,
                                            filled: true,
                                            fillColor: colorScheme.surfaceContainer,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),

                        const SizedBox(height: 18),
                        Divider(color: divider),
                        const SizedBox(height: 12),

                        // Action buttons
                        Wrap(
                          spacing: 12,
                          children: [
                            PrimaryButton(
                              label: 'Add In Queue',
                              icon: Icons.add,
                              backgroundColor: colorScheme.primary,
                              onPressed: _addToQueue,
                            ),
                            SecondaryButton(
                              label: 'Clear Request Queue',
                              icon: Icons.clear,
                              backgroundColor: colorScheme.secondaryContainer,
                              onPressed: _clearFormAndQueue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Queue area
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Request Queue', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        if (_queue.isEmpty)
                          SizedBox(
                            height: 140,
                            child: Center(
                              child: Text(
                                'Queue is empty. Add items using "Add In Queue".',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            // fixed but responsive height
                            height: MediaQuery.of(context).size.height * 0.45 > 320 ? 320 : MediaQuery.of(context).size.height * 0.45,
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: ListView.builder(
                                itemCount: _queue.length,
                                itemBuilder: (context, index) {
                                  final item = _queue[index];
                                  // Each tile is responsive: on narrow widths convert row -> column for readability
                                  return LayoutBuilder(builder: (ctx, tileCons) {
                                    final narrowTile = tileCons.maxWidth < 600;
                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 6),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: colorScheme.onSurface,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: divider),
                                      ),
                                      child: narrowTile
                                          ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item['template'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, color: textStyle?.color)),
                                          const SizedBox(height: 6),
                                          Text(item['project'] ?? '', style: textStyle),
                                          const SizedBox(height: 6),
                                          Text('From: ${item['from'] ?? ''}', style: textStyle),
                                          const SizedBox(height: 6),
                                          Text('To: ${item['to'] ?? ''}', style: textStyle),
                                          const SizedBox(height: 6),
                                          Text('₹ ${item['amount'] ?? ''}', style: textStyle),
                                          const SizedBox(height: 8),
                                          Text('Purpose: ${item['purpose'] ?? ''}', maxLines: 3, overflow: TextOverflow.ellipsis, style: textStyle),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _queue.removeAt(index);
                                                });
                                              },
                                              icon: Icon(Icons.delete, color: colorScheme.error),
                                            ),
                                          ),
                                        ],
                                      )
                                          : Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(flex: 2, child: Text(item['template'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, color: textStyle?.color))),
                                          Expanded(flex: 2, child: Text(item['project'] ?? '', overflow: TextOverflow.ellipsis, style: textStyle)),
                                          Expanded(flex: 3, child: Text('From: ${item['from'] ?? ''}', overflow: TextOverflow.ellipsis, style: textStyle)),
                                          Expanded(flex: 3, child: Text('To: ${item['to'] ?? ''}', overflow: TextOverflow.ellipsis, style: textStyle)),
                                          Expanded(flex: 2, child: Text('₹ ${item['amount'] ?? ''}', textAlign: TextAlign.right, style: textStyle)),
                                          const SizedBox(width: 12),
                                          // Keep delete icon inside fixed box so it doesn't push layout
                                          SizedBox(
                                            width: 40,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () {
                                                setState(() {
                                                  _queue.removeAt(index);
                                                });
                                              },
                                              icon: Icon(Icons.delete, color: colorScheme.error),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
