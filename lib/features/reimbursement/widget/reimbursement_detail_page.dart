import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/features/reimbursement/data/travel_details.dart';
import 'package:ppv_components/features/reimbursement/models/reimbursement_models/reimbursement_note.dart';

class ReimbursementDetailPage extends StatefulWidget {
  const ReimbursementDetailPage({super.key});

  @override
  State<ReimbursementDetailPage> createState() => _ReimbursementDetailPageState();
}

class _ReimbursementDetailPageState extends State<ReimbursementDetailPage> {
  // Optional: paste base64 signature to force an image
  static const String base64Signature = '';

  final List<String> _comments = [];
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Widget _labelValue(BuildContext context, String label, String value, {double labelWidth = 150}) {
    final labelStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700);
    final valueStyle = Theme.of(context).textTheme.bodyMedium;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: labelWidth, child: Text(label, style: labelStyle, softWrap: true)),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: valueStyle, softWrap: true)),
      ],
    );
  }

  TableRow _tableHeader(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold);
    return TableRow(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer),
      children: [
        Padding(padding: const EdgeInsets.all(8), child: Text('Expense Type', style: headerStyle)),
        Padding(padding: const EdgeInsets.all(8), child: Text('Bill Date', style: headerStyle)),
        Padding(padding: const EdgeInsets.all(8), child: Text('Bill number', style: headerStyle)),
        Padding(padding: const EdgeInsets.all(8), child: Text('Vendor Name', style: headerStyle)),
        Padding(padding: const EdgeInsets.all(8), child: Text('Bill Amount', style: headerStyle, textAlign: TextAlign.right)),
        Padding(padding: const EdgeInsets.all(8), child: Text('Supporting Available', style: headerStyle, textAlign: TextAlign.center)),
        Padding(padding: const EdgeInsets.all(8), child: Text('Remarks (if any)', style: headerStyle)),
      ],
    );
  }

  Widget _signatureWidget(ReimbursementNote note, {double height = 56}) {
    // prefer base64 -> url -> painted fallback
    if (base64Signature.trim().isNotEmpty) {
      try {
        final bytes = base64Decode(base64Signature);
        return Image.memory(bytes, fit: BoxFit.contain, height: height, width: double.infinity);
      } catch (e) {
        debugPrint('base64 signature decode failed: $e');
      }
    }
    if (note.preparedBySignatureUrl.isNotEmpty) {
      return Image.network(note.preparedBySignatureUrl, fit: BoxFit.contain, height: height, width: double.infinity);
    }
    // painted fallback using theme colors
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _LeftAlignedSignaturePainter(cs.onSurface, cs.onSurfaceVariant),
      ),
    );
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.insert(0, text);
      _commentController.clear();
    });

    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Comment added', style: TextStyle(color: cs.onPrimary)),
      backgroundColor: cs.primary,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // Reusable container style matching SupportingDocsPage (theme-driven)
  Widget _styledCard({required Widget child, EdgeInsetsGeometry? padding}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: cs.shadow.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 6))],
        border: Border.all(color: cs.outline.withValues(alpha: 0.06)),
      ),
      padding: padding ?? const EdgeInsets.all(18),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ReimbursementNote note = dummyReimbursement;
    const double outerPadding = 14.0;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final contentWidth = constraints.maxWidth - (outerPadding * 2);

        // column flex numbers — columns are fractional of available width and will wrap text if required.
        final colFlex = [2.2, 0.9, 1.1, 1.4, 0.9, 0.9, 2.0];
        final totalFlex = colFlex.reduce((a, b) => a + b);
        final columnWidths = {
          for (int i = 0; i < colFlex.length; i++) i: FractionColumnWidth(colFlex[i] / totalFlex)
        };

        // Threshold: when screen is smaller than this, enable horizontal scrolling.
        const double smallScreenScrollThreshold = 900;

        // Build expense table with conditional horizontal scroll (scroll ONLY when screen width < threshold)
        Widget buildExpenseTable() {
          final tableContainer = Container(
            decoration: BoxDecoration(
              border: Border.all(color: cs.outlineVariant),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Table(
              columnWidths: columnWidths,
              border: TableBorder(
                top: BorderSide(color: cs.outlineVariant),
                bottom: BorderSide(color: cs.outlineVariant),
                horizontalInside: BorderSide(color: cs.outlineVariant),
              ),
              children: [
                _tableHeader(context),
                ...note.expenses.map((e) {
                  return TableRow(children: [
                    Padding(padding: const EdgeInsets.all(10), child: Text(e.expenseType, softWrap: true)),
                    Padding(padding: const EdgeInsets.all(10), child: Text(e.billDate, softWrap: true)),
                    Padding(padding: const EdgeInsets.all(10), child: Text(e.billNumber, softWrap: true)),
                    Padding(padding: const EdgeInsets.all(10), child: Text(e.vendorName, softWrap: true)),
                    Padding(padding: const EdgeInsets.all(10), child: Align(alignment: Alignment.centerRight, child: Text(e.amount.toStringAsFixed(2)))),
                    Padding(padding: const EdgeInsets.all(10), child: Center(child: Text(e.supportingAvailable ? 'Yes' : 'No'))),
                    Padding(padding: const EdgeInsets.all(10), child: Text(e.remarks, softWrap: true)),
                  ]);
                }).toList(),
                TableRow(children: [
                  Padding(padding: const EdgeInsets.all(10), child: Text('Total Payable Amount', style: const TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox.shrink(),
                  const SizedBox.shrink(),
                  const SizedBox.shrink(),
                  const SizedBox.shrink(),
                  const SizedBox.shrink(),
                  Padding(padding: const EdgeInsets.all(10), child: Align(alignment: Alignment.centerRight, child: Text('₹ ${note.totalPayable.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)))),
                ]),
                TableRow(children: [
                  Padding(padding: const EdgeInsets.all(10), child: Text('Advance Adjusted (if Any):')),
                  const SizedBox.shrink(),
                  const SizedBox.shrink(),
                  const SizedBox.shrink(),
                  const SizedBox.shrink(),
                  const SizedBox.shrink(),
                  Padding(padding: const EdgeInsets.all(10), child: Align(alignment: Alignment.centerRight, child: Text('₹ ${note.advanceAdjusted.toStringAsFixed(2)}'))),
                ]),
                TableRow(children: [
                  Padding(padding: const EdgeInsets.all(10), child: Text('Net Payable Amount', style: const TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox.shrink(),
                  const SizedBox.shrink(),
                  const SizedBox.shrink(),
                  const SizedBox.shrink(),
                  const SizedBox.shrink(),
                  Padding(padding: const EdgeInsets.all(10), child: Align(alignment: Alignment.centerRight, child: Text('₹ ${note.netPayable.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)))),
                ]),
              ],
            ),
          );

          if (constraints.maxWidth < smallScreenScrollThreshold) {
            // on small screens enable horizontal scroll
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: math.max(contentWidth, 800)),
                child: tableContainer,
              ),
            );
          } else {
            // on larger screens render fixed table (no horizontal scrolling)
            return tableContainer;
          }
        }

        // Build attachments table with same conditional behavior
        Widget buildAttachmentsTable() {
          final attachmentsTable = Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(border: Border.all(color: cs.outlineVariant), borderRadius: BorderRadius.circular(4)),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(0.08),
                1: FlexColumnWidth(0.7),
                2: FlexColumnWidth(0.22),
              },
              border: TableBorder(
                top: BorderSide(color: cs.outlineVariant),
                bottom: BorderSide(color: cs.outlineVariant),
                horizontalInside: BorderSide(color: cs.outlineVariant),
              ),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: cs.surfaceContainer),
                  children: [
                    Padding(padding: const EdgeInsets.all(10), child: Text('#', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
                    Padding(padding: const EdgeInsets.all(10), child: Text('Preview', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
                    Padding(padding: const EdgeInsets.all(10), child: Text('Download', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
                  ],
                ),
                TableRow(children: [
                  const Padding(padding: EdgeInsets.all(12), child: Text('1')),
                  Padding(padding: const EdgeInsets.all(12), child: Text('View PDF', style: TextStyle(color: cs.primary))),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: PrimaryButton(
                        label: 'Download',
                        icon: Icons.download_rounded,
                        onPressed: () {
                          // specific file download
                        },
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          );

          if (constraints.maxWidth < smallScreenScrollThreshold) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(width: math.max(contentWidth, 420), child: attachmentsTable),
            );
          } else {
            return SizedBox(width: math.max(contentWidth, 420), child: attachmentsTable);
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: outerPadding, vertical: 16),
          child: Center(
            child: SizedBox(
              width: contentWidth,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                // ===== DETAIL CARD (uses _styledCard like SupportingDocsPage) =====
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 260),
                  child: _styledCard(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      // Header
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('NHIT Western Projects Private Limited',
                            textAlign: TextAlign.center,
                            style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 8),
                      Text('Travel / Expenses Reimbursement Form',
                          textAlign: TextAlign.center,
                          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),

                      // Top meta rows — responsive
                      LayoutBuilder(builder: (ctx, inner) {
                        final available = inner.maxWidth;
                        final useStack = available < 680;
                        if (useStack) {
                          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _labelValue(context, 'Date:', note.createdAt.toLocal().toString().split('.').first),
                            const SizedBox(height: 6),
                            _labelValue(context, 'Project Name:', note.projectName),
                            const SizedBox(height: 6),
                            _labelValue(context, 'Department:', note.department),
                            const SizedBox(height: 6),
                            _labelValue(context, 'Note No.:', note.noteNo),
                          ]);
                        } else {
                          final oneThird = inner.maxWidth / 3;
                          return Wrap(spacing: 10, runSpacing: 8, children: [
                            SizedBox(width: oneThird - 22, child: _labelValue(context, 'Date:', note.createdAt.toLocal().toString().split('.').first)),
                            SizedBox(width: oneThird - 22, child: _labelValue(context, 'Project Name:', note.projectName)),
                            SizedBox(width: oneThird - 22, child: _labelValue(context, 'Department:', note.department)),
                            SizedBox(width: oneThird - 22, child: _labelValue(context, 'Note No.:', note.noteNo)),
                          ]);
                        }
                      }),

                      const SizedBox(height: 8),

                      // Employee row (responsive)
                      LayoutBuilder(builder: (ctx, inner) {
                        final available = inner.maxWidth;
                        if (available < 600) {
                          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _labelValue(context, 'Employee Name:', note.employeeName),
                            const SizedBox(height: 6),
                            _labelValue(context, 'Employee ID:', note.employeeId),
                            const SizedBox(height: 6),
                            _labelValue(context, 'Employee Designation:', note.employeeDesignation),
                          ]);
                        } else {
                          final box = (inner.maxWidth - 36) / 3;
                          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            SizedBox(width: box, child: _labelValue(context, 'Employee Name:', note.employeeName)),
                            SizedBox(width: box, child: _labelValue(context, 'Employee ID:', note.employeeId)),
                            SizedBox(width: box, child: _labelValue(context, 'Employee Designation:', note.employeeDesignation)),
                          ]);
                        }
                      }),

                      const SizedBox(height: 8),

                      // Travel row
                      LayoutBuilder(builder: (ctx, inner) {
                        final available = inner.maxWidth;
                        if (available < 600) {
                          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _labelValue(context, 'Date of Travel:', note.dateOfTravel.toIso8601String().split('T')[0]),
                            const SizedBox(height: 6),
                            _labelValue(context, 'Mode of Travel:', note.modeOfTravel),
                            const SizedBox(height: 6),
                            _labelValue(context, 'Travel Mode Eligibility:', note.travelModeEligibility),
                          ]);
                        } else {
                          final box = (inner.maxWidth - 36) / 3;
                          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            SizedBox(width: box, child: _labelValue(context, 'Date of Travel:', note.dateOfTravel.toIso8601String().split('T')[0])),
                            SizedBox(width: box, child: _labelValue(context, 'Mode of Travel:', note.modeOfTravel)),
                            SizedBox(width: box, child: _labelValue(context, 'Travel Mode Eligibility:', note.travelModeEligibility)),
                          ]);
                        }
                      }),

                      const SizedBox(height: 10),

                      // Initial Approver, Approver's designation, Approval Date — responsive
                      LayoutBuilder(builder: (ctx, inner) {
                        final available = inner.maxWidth;
                        if (available < 700) {
                          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _labelValue(context, 'Initial Approver\'s Name:', note.initialApproverName),
                            const SizedBox(height: 6),
                            _labelValue(context, 'Approver\'s designation:', note.approverDesignation),
                            const SizedBox(height: 6),
                            _labelValue(context, 'Approval Date:', '-'),
                          ]);
                        } else {
                          return Row(children: [
                            Expanded(child: _labelValue(context, 'Initial Approver\'s Name:', note.initialApproverName)),
                            Expanded(child: _labelValue(context, 'Approver\'s designation:', note.approverDesignation)),
                            Expanded(child: _labelValue(context, 'Approval Date:', '-')),
                          ]);
                        }
                      }),

                      const SizedBox(height: 10),
                      _labelValue(context, 'Purpose of travel:', note.purpose),

                      const SizedBox(height: 12),

                      // Expense title + table
                      Text('Expense Details:', style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      // Expense table — now scrolls only on small screens
                      buildExpenseTable(),

                      const SizedBox(height: 12),

                      // Bank details table
                      Text('Bank Details:', style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Table(
                        columnWidths: const {0: FlexColumnWidth(0.95), 1: FlexColumnWidth(2.05)},
                        children: [
                          TableRow(children: [
                            Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text('Name of Account holder:', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700))),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(note.bankDetails.accountHolder, softWrap: true)),
                          ]),
                          TableRow(children: [
                            Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text('Bank Name:', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700))),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(note.bankDetails.bankName, softWrap: true)),
                          ]),
                          TableRow(children: [
                            Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text('Bank Account:', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700))),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(note.bankDetails.accountNumber, softWrap: true)),
                          ]),
                          TableRow(children: [
                            Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text('IFSC:', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700))),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(note.bankDetails.ifsc, softWrap: true)),
                          ]),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Prepared By section (signature box + details)
                      LayoutBuilder(builder: (ctx, inner) {
                        final available = inner.maxWidth;
                        // Reduced signature box width to 80.0 as requested
                        const double sigBoxWidth = 80.0;
                        const double sigBoxHeight = 56.0;
                        // Border thickness for signature container (reduced)
                        const double sigBoxBorderWidth = 0.6;

                        if (available < 480) {
                          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Prepared By:', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: cs.outlineVariant, width: sigBoxBorderWidth),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0), // slightly reduced padding
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ConstrainedBox(
                                          constraints: BoxConstraints.tightFor(width: sigBoxWidth, height: sigBoxHeight),
                                          child: Align(alignment: Alignment.centerLeft, child: _signatureWidget(note, height: sigBoxHeight)),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(child: SizedBox.shrink()),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text('Name: ${note.preparedByName}', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 3),
                                    Text('Designation: ${note.preparedByDesignation}', style: tt.bodyMedium),
                                    const SizedBox(height: 3),
                                    Text('Date: ${note.createdAt.toLocal().toString().split('.').first}', style: tt.bodyMedium),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Approved By:', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 12),
                            Text('Approval Date:', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text('-', style: tt.bodyMedium),
                          ]);
                        } else {
                          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(
                              flex: 3,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('Prepared By:', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: cs.outlineVariant, width: sigBoxBorderWidth),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ConstrainedBox(
                                              constraints: BoxConstraints.tightFor(width: sigBoxWidth, height: sigBoxHeight),
                                              child: Align(alignment: Alignment.centerLeft, child: _signatureWidget(note, height: sigBoxHeight)),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(child: SizedBox.shrink()),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text('Name: ${note.preparedByName}', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 3),
                                        Text('Designation: ${note.preparedByDesignation}', style: tt.bodyMedium),
                                        const SizedBox(height: 3),
                                        Text('Date: ${note.createdAt.toLocal().toString().split('.').first}', style: tt.bodyMedium),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              flex: 3,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('Approved By:', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                              ]),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              flex: 2,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('Approval Date:', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Text('-', style: tt.bodyMedium),
                              ]),
                            ),
                          ]);
                        }
                      }),

                      const SizedBox(height: 12),
                      Text('(Please attach supporting for above expenses along with this note)', style: tt.bodySmall?.copyWith(color: cs.outline)),
                      const SizedBox(height: 12),

                      // ===== Row: Reject (SecondaryButton) only =====
                      Row(
                        children: [
                          SecondaryButton(
                            label: 'Reject',
                            onPressed: () {
                              // hook reject action
                            },
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ===== Attachments table area (outer border, no vertical internal lines) =====
                      buildAttachmentsTable(),
                    ]),
                  ),
                ),

                const SizedBox(height: 18),

                // ===== COMMENTS CARD (styled like SupportingDocsPage) =====
                _styledCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text('Comments (${_comments.length})', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 12),
                    if (_comments.isEmpty)
                      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('No comments yet.', style: TextStyle(color: cs.onSurfaceVariant)))
                    else
                      Column(
                        children: _comments.map((c) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Card(
                              color: cs.surfaceContainerLow,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: cs.outline.withOpacity(0.06))),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(c, style: tt.bodyMedium),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Write a comment...',
                        filled: true,
                        fillColor: cs.surfaceContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: PrimaryButton(
                        label: 'Add Comment',
                        icon: Icons.add_comment_rounded,
                        onPressed: _addComment,
                      ),
                    ),
                  ]),
                ),

                const SizedBox(height: 24),
                Center(child: Text('© Copyright NHIT. All Rights Reserved', style: tt.bodySmall)),
                const SizedBox(height: 12),
              ]),
            ),
          ),
        );
      }),
    );
  }
}

/// Left-aligned signature painter (uses theme colors passed in).
class _LeftAlignedSignaturePainter extends CustomPainter {
  final Color strokeColor;
  final Color flourishColor;

  _LeftAlignedSignaturePainter(this.strokeColor, this.flourishColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path p = Path();
    // start lower-left, make compact left-to-right flourish
    p.moveTo(2, size.height * 0.75);
    p.cubicTo(size.width * 0.12, size.height * 0.22, size.width * 0.26, size.height * 0.85, size.width * 0.40, size.height * 0.5);
    p.cubicTo(size.width * 0.52, size.height * 0.22, size.width * 0.68, size.height * 0.78, size.width * 0.86, size.height * 0.56);
    canvas.drawPath(p, paint);

    final flourish = Paint()
      ..color = flourishColor
      ..strokeWidth = 1.1;
    canvas.drawLine(Offset(size.width * 0.04, size.height * 0.88), Offset(size.width * 0.32, size.height * 0.92), flourish);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.60), 1.2, flourish);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// SecondaryButton implementation (theme-driven).
class SecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;

  const SecondaryButton({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final effectiveOnPressed = (isDisabled || isLoading) ? null : onPressed;

    final ButtonStyle style = FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      minimumSize: const Size(0, 44),
      side: BorderSide(
        color: cs.outline.withValues(alpha: 0.5),
        width: 1.0,
      ),
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        final baseColor = backgroundColor ?? cs.secondaryContainer;
        if (states.contains(WidgetState.disabled)) return baseColor.withValues(alpha: 0.4);
        if (states.contains(WidgetState.pressed)) return baseColor.withValues(alpha: 0.7);
        if (states.contains(WidgetState.hovered)) return baseColor.withValues(alpha: 0.9);
        return baseColor;
      }),
      foregroundColor: WidgetStateProperty.all(cs.onSecondaryContainer),
    );

    Widget childContent;
    if (isLoading) {
      childContent = SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(cs.onSecondaryContainer),
        ),
      );
    } else if (icon != null) {
      childContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)],
      );
    } else {
      childContent = Text(label);
    }
    return FilledButton.tonal(
      onPressed: effectiveOnPressed,
      style: style,
      child: childContent,
    );
  }
}
