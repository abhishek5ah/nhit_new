import 'dart:io';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/features/expense/dart/expense_detail_mockdb.dart';
import 'package:ppv_components/features/expense/model/expense_detail_model.dart';

class SupportingDocsPage extends StatefulWidget {
  final String title;
  final GreenNoteData? data;

  const SupportingDocsPage({super.key, this.title = 'Green Note (W/25-26/EN/2548)', this.data});

  @override
  State<SupportingDocsPage> createState() => _SupportingDocsPageState();
}

class _SupportingDocsPageState extends State<SupportingDocsPage> {
  late GreenNoteData _data;

  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _docNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  late List<Map<String, String>> _attachments;
  late List<Map<String, String>> _comments;

  String _searchQuery = '';
  String? _pickedFileName;
  String? _pickedFilePath;

  @override
  void initState() {
    super.initState();

    // fallback to dummy data if none passed
    _data = widget.data ?? GreenNoteDummy().dummy;

    _attachments = List<Map<String, String>>.from(
        _data.initialAttachments.map((m) => Map<String, String>.from(m)));
    _comments = List<Map<String, String>>.from(
        _data.initialComments.map((m) => Map<String, String>.from(m)));

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _docNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool isMobile(BuildContext c) => MediaQuery.of(c).size.width < 900;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);
    if (result != null && result.files.isNotEmpty) {
      final f = result.files.single;
      setState(() {
        _pickedFileName = f.name;
        _pickedFilePath = f.path;
        if (_docNameController.text.trim().isEmpty) _docNameController.text = f.name;
      });
    }
  }

  void _removePickedFile() {
    setState(() {
      _pickedFileName = null;
      _pickedFilePath = null;
    });
  }

  void _showSnack(String text) {
    final cs = Theme.of(context).colorScheme;
    final onPrimary = cs.onPrimary;
    final primary = cs.primary;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: TextStyle(color: onPrimary)),
        backgroundColor: primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _uploadDoc() {
    final docName = _docNameController.text.trim();
    if (docName.isEmpty) {
      _showSnack('Please enter Doc Name');
      return;
    }
    if (_pickedFilePath == null || _pickedFileName == null) {
      _showSnack('Please choose a file');
      return;
    }

    final now = DateTime.now();
    final newEntry = {
      'sno': (_attachments.length + 1).toString(),
      'fileName': docName,
      'uploadDate':
      '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      'uploadedBy': 'You',
      'path': _pickedFilePath!,
    };

    setState(() {
      _attachments.add(newEntry);
      _docNameController.clear();
      _pickedFileName = null;
      _pickedFilePath = null;
    });

    _showSnack('Uploaded');
  }

  Future<void> _openFile(String path) async {
    if (path.isEmpty) {
      _showSnack('No local file available to open');
      return;
    }
    final file = File(path);
    if (!file.existsSync()) {
      _showSnack('File not found on device');
      return;
    }
    await OpenFilex.open(path);
  }

  void _deleteAttachment(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete attachment'),
        content: const Text('Are you sure you want to delete this attachment?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('No')),
          TextButton(
            onPressed: () {
              setState(() {
                _attachments.removeAt(index);
                for (var i = 0; i < _attachments.length; i++) {
                  _attachments[i]['sno'] = (i + 1).toString();
                }
              });
              Navigator.of(ctx).pop();
              _showSnack('Deleted');
            },
            child: const Text('Yes'),
          )
        ],
      ),
    );
  }

  List<Map<String, String>> get _filteredAttachments {
    if (_searchQuery.isEmpty) return _attachments;
    return _attachments.where((a) {
      final sno = (a['sno'] ?? '').toLowerCase();
      final name = (a['fileName'] ?? '').toLowerCase();
      return sno.contains(_searchQuery) || name.contains(_searchQuery);
    }).toList();
  }


  // ---------- Responsive label-value pair ----------
  Widget _labelValuePair(String label, String value, {bool showLabelBold = true}) {
    // Use available width on mobile, constrain on larger screens
    final mobile = isMobile(context);
    final cs = Theme.of(context).colorScheme;
    final textColor = cs.onSurface;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: mobile ? double.infinity : 340),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: mobile ? 120 : 170,
            child: Text(label,
                maxLines: 3,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: TextStyle(fontWeight: showLabelBold ? FontWeight.w700 : FontWeight.w600, color: textColor)),
          ),
          const SizedBox(width: 8),
          // let value wrap and take remaining space
          Expanded(
              child: SelectableText(
                value,
                maxLines: null,
                style: TextStyle(color: textColor),
                // allow value to wrap into multiple lines
              )
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: cs.onSurface)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);

    final cs = Theme.of(context).colorScheme;
    final textColor = cs.onSurface;
    final muted = cs.onSurface.withValues(alpha:0.7);

    // compact icon-only choose button (prevents overflow)
    Widget chooseIconButton() {
      return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 44, maxWidth: 44, minHeight: 40, maxHeight: 44),
        child: ElevatedButton(
          onPressed: _pickFile,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: cs.surfaceContainer,
            elevation: 0,
            side: BorderSide(color: cs.outline),
          ),
          child: Icon(Icons.attach_file, color: cs.onSurface, size: 20),
        ),
      );
    }

    // NOTE: we're explicitly hiding any AppBar by using PreferredSize with zero height.
    return Scaffold(
      // hide any visible/top appbar (removes that purple sticky header)
      appBar: const PreferredSize(preferredSize: Size.zero, child: SizedBox.shrink()),
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: mobile ? 16 : 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Document header card (uses _data)
                    Container(
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: cs.shadow.withValues(alpha:0.04), blurRadius: 12, offset: const Offset(0, 6))],
                        border: Border.all(color: cs.outline.withValues(alpha:0.08)),
                      ),
                      padding: EdgeInsets.all(mobile ? 16 : 28),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // Left aligned heading + subheading
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(_data.companyName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: mobile ? 18 : 20, color: textColor)),
                          const SizedBox(height: 6),
                          Text(_data.noteTitle, style: TextStyle(fontSize: mobile ? 15 : 16, color: muted)),
                        ]),
                        const SizedBox(height: 16),
                        Divider(color: cs.outline.withValues(alpha:0.12)),
                        const SizedBox(height: 8),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          runSpacing: 12,
                          children: [
                            _labelValuePair('Date:', _data.date),
                            _labelValuePair('Project:', _data.project),
                            _labelValuePair('Department:', _data.department),
                            _labelValuePair('Note No.:', _data.noteNo),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Card(
                          elevation: 0,
                          color: cs.surfaceContainerLow,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: cs.outline.withValues(alpha:0.08))),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 10,
                              children: [
                                _labelValuePair('Purchase/Work Order No:', _data.purchaseWorkOrderNo, showLabelBold: true),
                                _labelValuePair('Purchase/Work order Date:', _data.purchaseWorkOrderDate),
                                _labelValuePair('Amount of PO/WO', _data.amountPOWO, showLabelBold: true),
                                _labelValuePair('Taxable Value:', _data.taxableValue),
                                _labelValuePair('Other Charges:', _data.otherCharges),
                                _labelValuePair('GST:', _data.gst),
                                _labelValuePair('Total PO/WO Value:', _data.totalPOWOValue),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _sectionTitle('Supplier & Classification'),

                        // Supplier section: use Wrap so items can wrap on small screens
                        LayoutBuilder(builder: (ctx, cons) {
                          final small = cons.maxWidth < 700;
                          if (small) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _labelValuePair('Name of Supplier:', _data.supplierName),
                                const SizedBox(height: 8),
                                _labelValuePair("Vendor's MSME Classification:", _data.vendorMSME),
                                const SizedBox(height: 8),
                                _labelValuePair('Activity Type:', _data.activityType),
                              ],
                            );
                          } else {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _labelValuePair('Name of Supplier:', _data.supplierName)),
                                const SizedBox(width: 12),
                                Expanded(child: _labelValuePair("Vendor's MSME Classification:", _data.vendorMSME)),
                                const SizedBox(width: 12),
                                Expanded(child: _labelValuePair('Activity Type:', _data.activityType)),
                              ],
                            );
                          }
                        }),

                        const SizedBox(height: 12),
                        _labelValuePair('Protest Note Required:', _data.protestNoteRequired),
                        const SizedBox(height: 12),
                        _sectionTitle('Brief of Goods / Services'),
                        const SizedBox(height: 6),
                        Text(_data.briefDescription, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                        const SizedBox(height: 10),
                        Wrap(
                          runSpacing: 8,
                          spacing: 20,
                          children: [
                            _labelValuePair('Invoice No.:', _data.invoiceNo),
                            _labelValuePair('Invoice Date:', _data.invoiceDate),
                            _labelValuePair('Taxable Value:', _data.invoiceTaxableValue),
                            _labelValuePair('Add GST on above:', _data.invoiceGST),
                            _labelValuePair('Invoice Other Charges:', _data.invoiceOtherCharges),
                            _labelValuePair('Invoice Value:', _data.invoiceValue),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(color: cs.outline.withValues(alpha:0.08)),
                        const SizedBox(height: 8),

                        _labelValuePair('Contract Period:', _data.contractPeriod),
                        const SizedBox(height: 8),
                        _labelValuePair('Period of Supply of services/goods Invoiced:', _data.periodOfSupply),
                        const SizedBox(height: 8),
                        _labelValuePair('Whether contract period completed:', _data.contractCompleted),
                        const SizedBox(height: 8),
                        _labelValuePair('Extension of contract period executed:', _data.extensionExecuted),
                        const SizedBox(height: 8),
                        _labelValuePair('Delayed damages:', _data.delayedDamages),
                        const SizedBox(height: 12),
                        _sectionTitle('Budget Utilisation'),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(border: Border.all(color: cs.outline.withValues(alpha:0.08)), color: cs.surfaceContainerLow),
                          child: Table(
                            border: TableBorder.symmetric(outside: BorderSide.none, inside: BorderSide(color: cs.outline.withValues(alpha:0.06))),
                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                            children: [
                              TableRow(children: [
                                Container(padding: const EdgeInsets.all(10), child: Text('Budget Expenditure Rs.', style: TextStyle(fontWeight: FontWeight.w600, color: textColor))),
                                Container(padding: const EdgeInsets.all(10), child: Text('Actual Expenditure Rs.', style: TextStyle(fontWeight: FontWeight.w600, color: textColor))),
                                Container(padding: const EdgeInsets.all(10), child: Text('Expenditure over budget', style: TextStyle(fontWeight: FontWeight.w600, color: textColor))),
                              ]),
                              TableRow(children: [
                                Container(padding: const EdgeInsets.all(10), child: Text(_data.budgetExpenditure, style: TextStyle(color: textColor))),
                                Container(padding: const EdgeInsets.all(10), child: Text(_data.actualExpenditure, style: TextStyle(color: textColor))),
                                Container(padding: const EdgeInsets.all(10), child: Text(_data.expenditureOverBudget, style: TextStyle(color: textColor))),
                              ]),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _labelValuePair('Nature of Expenses', _data.natureOfExpenses),
                        const SizedBox(height: 8),
                        _labelValuePair('Milestone Status Achived ?', _data.milestoneStatus),
                        const SizedBox(height: 8),
                        _labelValuePair('Milestone Remarks', _data.milestoneRemarks),
                        const SizedBox(height: 8),
                        _labelValuePair('Expense amount within contract', _data.expenseWithinContract),
                        const SizedBox(height: 12),

                        // ===== Heading row: both left-aligned: "Upload documents" followed by "Tax Invoice" =====
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Upload documents', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: textColor)),
                            const SizedBox(width: 12),
                            Text('Tax Invoice,', style: TextStyle(color: muted)),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // === signature box below, left side ===
                        LayoutBuilder(builder: (ctx, cons) {
                          final small = cons.maxWidth < 700;
                          if (small) {
                            // Stack vertically on small screens
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 120,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(border: Border.all(color: cs.outline.withValues(alpha:0.08)), color: cs.surfaceContainer),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        // left spacing area to keep layout
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text('Signature', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Name: ${_data.signatureName}\nDesignation: ${_data.signatureDesignation}\nDate: ${_data.signatureDate}',
                                                style: TextStyle(fontSize: 12, color: muted),
                                                softWrap: true,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // placeholder below
                                Container(
                                  width: double.infinity,
                                  height: 72,
                                  decoration: BoxDecoration(border: Border.all(color: cs.outline.withValues(alpha:0.06)), color: cs.surfaceContainerLow),
                                  child: Center(child: Text('Additional area / notes', style: TextStyle(color: muted))),
                                ),
                              ],
                            );
                          } else {
                            // Desktop: keep side-by-side but ensure signature text wraps
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Signature box on the left (smaller column)
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    height: 120,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(border: Border.all(color: cs.outline.withValues(alpha:0.08)), color: cs.surfaceContainer),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 6),
                                          Text('Signature', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Name: ${_data.signatureName}\nDesignation: ${_data.signatureDesignation}\nDate: ${_data.signatureDate}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 12, color: muted),
                                            softWrap: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // empty area next to signature (keeps layout aligned)
                                Expanded(flex: 2, child: SizedBox.shrink()),
                              ],
                            );
                          }
                        }),
                        // === end signature section ===
                      ]),
                    ),

                    const SizedBox(height: 20),

                    // HR Department section
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: cs.shadow.withValues(alpha:0.04), blurRadius: 12, offset: const Offset(0, 6))],
                        border: Border.all(color: cs.outline.withValues(alpha:0.08)),
                      ),
                      child: LayoutBuilder(builder: (ctx, cons) {
                        final small = cons.maxWidth < 700;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                color: cs.secondaryContainer,
                                child: Text('HR Department', style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSecondaryContainer))),
                            const SizedBox(height: 14),
                            if (small)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Documents verified for the Period of Workdone/Supply:', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                                  const SizedBox(height: 8),
                                  Row(children: [Expanded(child: Text('Whether all the documents required submitted?:', style: TextStyle(fontWeight: FontWeight.w600, color: textColor))), const SizedBox(width: 6), Text('NO', style: TextStyle(color: muted))]),
                                  const SizedBox(height: 18),
                                  Text('Amount to be retained for non submission/non compliance of HR:', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                                  const SizedBox(height: 12),
                                  Text('Expense Approved:', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                                  const SizedBox(height: 12),
                                  Row(children: [Expanded(child: Text('If payment approved with Deviation:', style: TextStyle(fontWeight: FontWeight.w600, color: textColor))), const SizedBox(width: 6), Text('NO', style: TextStyle(color: muted))]),
                                  const SizedBox(height: 12),
                                  Text('Documents discrepancy:', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                                  const SizedBox(height: 8),
                                  Container(height: 120, alignment: Alignment.topLeft, child: Text('', style: TextStyle(color: muted))), // placeholder
                                ],
                              )
                            else
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text('Documents verified for\nthe Period of\nWorkdone/Supply:', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                                      const SizedBox(height: 8),
                                      Row(children: [Expanded(child: Text('Whether all the documents required submitted?:', style: TextStyle(fontWeight: FontWeight.w600, color: textColor))), const SizedBox(width: 6), Text('NO', style: TextStyle(color: muted))]),
                                      const SizedBox(height: 18),
                                      Text('Amount to be retained\nfor non submission/non\ncompliance of HR:', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                                      const SizedBox(height: 12),
                                      Text('Expense Approved:', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                                      const SizedBox(height: 12),
                                      Row(children: [Expanded(child: Text('If payment approved\nwith Deviation:', style: TextStyle(fontWeight: FontWeight.w600, color: textColor))), const SizedBox(width: 6), Text('NO', style: TextStyle(color: muted))]),
                                    ]),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text('Documents discrepancy:', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                                      const SizedBox(height: 8),
                                      Container(height: 120, alignment: Alignment.topLeft, child: Text('', style: TextStyle(color: muted))), // placeholder
                                    ]),
                                  )
                                ],
                              ),
                            const SizedBox(height: 12),
                            Row(children: [Expanded(child: Divider(color: cs.outline.withValues(alpha:0.08))), const SizedBox(width: 16), Expanded(child: Divider(color: cs.outline.withValues(alpha:0.08)))]),
                          ],
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    // Supporting docs card (inputs + upload + table)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: cs.surfaceContainer, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: cs.shadow.withValues(alpha:0.04), blurRadius: 12, offset: const Offset(0, 6))], border: Border.all(color: cs.outline.withValues(alpha:0.08))),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Supporting Docs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
                        const SizedBox(height: 12),

                        // Inputs row
                        LayoutBuilder(builder: (context, constraints) {
                          final small = constraints.maxWidth < 700;
                          if (small) {
                            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              TextField(
                                controller: _docNameController,
                                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)), hintText: 'Doc Name', isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                              ),
                              const SizedBox(height: 12),
                              Row(children: [
                                chooseIconButton(),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    height: 40,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(6), border: Border.all(color: cs.outline.withValues(alpha:0.08))),
                                    child: _pickedFileName == null
                                        ? Text('No file chosen', style: TextStyle(color: cs.onSurface.withValues(alpha:0.6)))
                                        : Row(children: [Expanded(child: Text(_pickedFileName!, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor))), IconButton(icon: Icon(Icons.close, size: 18, color: cs.error), onPressed: _removePickedFile)]),
                                  ),
                                )
                              ])
                            ]);
                          } else {
                            return Row(children: [
                              Expanded(
                                  flex: 5,
                                  child: TextField(
                                    controller: _docNameController,
                                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)), hintText: 'Doc Name', isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
                                  )),
                              const SizedBox(width: 12),
                              chooseIconButton(),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 6,
                                child: Container(
                                  height: 44,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(6), border: Border.all(color: cs.outline.withValues(alpha:0.08))),
                                  child: _pickedFileName == null
                                      ? Text('No file chosen', style: TextStyle(color: cs.onSurface.withValues(alpha:0.6)))
                                      : Row(children: [Expanded(child: Text(_pickedFileName!, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor))), IconButton(icon: Icon(Icons.close, size: 18, color: cs.error), onPressed: _removePickedFile)]),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ]);
                          }
                        }),

                        const SizedBox(height: 14),

                        // Upload button (PrimaryButton)
                        Center(
                          child: PrimaryButton(
                            label: 'Upload',
                            onPressed: _uploadDoc,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Table area (files)
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(color: cs.surfaceContainer, borderRadius: BorderRadius.circular(8), border: Border.all(color: cs.outline.withValues(alpha:0.08))),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Column(children: [
                            // Use LayoutBuilder to make search box flexible
                            LayoutBuilder(builder: (ct, cons) {
                              final maxSearchWidth = math.min(220.0, cons.maxWidth * 0.5);
                              return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text('10  entries per page', style: TextStyle(color: textColor)),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: maxSearchWidth),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: TextField(
                                      controller: _searchController,
                                      decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), hintText: 'Search by name or id...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)), isDense: true),
                                    ),
                                  ),
                                )
                              ]);
                            }),
                            const SizedBox(height: 12),

                            LayoutBuilder(builder: (context, tableConstraints) {
                              // Use a minimum width for the table columns so they don't collapse too much.
                              // This will allow horizontal scroll on narrow screens instead of overflow.
                              final minTableWidth = math.max(tableConstraints.maxWidth, 640.0);
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: minTableWidth),
                                  child: DataTable(
                                    columnSpacing: 20,
                                    headingRowHeight: 40,
                                    dataRowMinHeight: 52,
                                    dataRowMaxHeight: 148,
                                    headingTextStyle: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600),
                                    dataTextStyle: TextStyle(color: cs.onSurface),
                                    columns: [
                                      DataColumn(label: Text('S no.', style: TextStyle(color: cs.onSurface))),
                                      DataColumn(label: Text('File name', style: TextStyle(color: cs.onSurface))),
                                      DataColumn(label: Text('File', style: TextStyle(color: cs.onSurface))),
                                      DataColumn(label: Text('Upload Date', style: TextStyle(color: cs.onSurface))),
                                      DataColumn(label: Text('Uploaded By', style: TextStyle(color: cs.onSurface))),
                                      DataColumn(label: Text('Action', style: TextStyle(color: cs.onSurface))),
                                    ],
                                    rows: _filteredAttachments.asMap().entries.map((entry) {
                                      final _ = entry.key;
                                      final a = entry.value;
                                      return DataRow(cells: [
                                        DataCell(Text(a['sno'] ?? '', style: TextStyle(color: cs.onSurface))),
                                        DataCell(ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 240),
                                          child: Text(a['fileName'] ?? '', overflow: TextOverflow.ellipsis, style: TextStyle(color: cs.onSurface)),
                                        )),
                                        // keep file icon cell simple (not "image"), using a minimal icon
                                        DataCell(Icon(Icons.file_present_outlined, size: 18, color: cs.onSurfaceVariant)),
                                        DataCell(Text(a['uploadDate'] ?? '', style: TextStyle(color: cs.onSurface))),
                                        DataCell(Text(a['uploadedBy'] ?? '', style: TextStyle(color: cs.onSurface))),
                                        DataCell(Row(children: [
                                          // download/open the specific file
                                          IconButton(icon: Icon(Icons.download_rounded, size: 18, color: cs.primary), onPressed: () => _openFile(a['path'] ?? '')),
                                          IconButton(icon: Icon(Icons.delete_outline, size: 18, color: cs.error), onPressed: () {
                                            final originalIndex = _attachments.indexWhere((el) => el['sno'] == a['sno'] && el['fileName'] == a['fileName']);
                                            if (originalIndex != -1) _deleteAttachment(originalIndex);
                                          }),
                                        ])),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                            Align(alignment: Alignment.centerLeft, child: Text('Showing 1 to ${_filteredAttachments.length} of ${_attachments.length} entries', style: TextStyle(color: cs.onSurface.withValues(alpha:0.7))))
                          ]),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 20),

                    // Comments card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: cs.surfaceContainer, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: cs.shadow.withValues(alpha:0.04), blurRadius: 12, offset: const Offset(0, 6))], border: Border.all(color: cs.outline.withValues(alpha:0.08))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Comments (${_comments.length})', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: textColor)),
                          const SizedBox(height: 12),
                          ..._comments.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Card(
                              color: cs.surfaceContainerLow,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(c['time'] ?? '', style: TextStyle(color: cs.onSurface.withValues(alpha:0.7), fontSize: 12)),
                                  const SizedBox(height: 8),
                                  Text(c['author'] ?? '', style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),
                                  const SizedBox(height: 6),
                                  Text(c['text'] ?? '', style: TextStyle(color: textColor)),
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    // use theme primary color for "Reply"
                                    Text('Reply', style: TextStyle(color: cs.primary)),
                                    const SizedBox(width: 10),
                                    const Text('|'),
                                    const SizedBox(width: 10),
                                    Text('0 Replies', style: TextStyle(color: cs.onSurface.withValues(alpha:0.7)))
                                  ])
                                ]),
                              ),
                            ),
                          )),
                          const SizedBox(height: 12),
                          TextField(controller: _commentController, minLines: 2, maxLines: 4, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)), hintText: 'Write a comment...')),
                          const SizedBox(height: 10),
                          Row(children: [
                            const Spacer(),
                            PrimaryButton(
                              label: 'Add Comment',
                              onPressed: () {
                                final text = _commentController.text.trim();
                                if (text.isEmpty) return;
                                setState(() {
                                  _comments.add({'author': 'You', 'time': 'Just now', 'text': text});
                                  _commentController.clear();
                                });
                              },
                            )
                          ]),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Right Flow column (desktop)
            if (!isMobile(context))
              SizedBox(
                width: 320,
                child: Padding(
                  padding: const EdgeInsets.only(right: 24, left: 8),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Flow', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                            const SizedBox(height: 12),
                            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              SizedBox(
                                  width: 32,
                                  child: Column(children: [
                                    Container(width: 10, height: 10, decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle)),
                                    Container(width: 2, height: 40, color: cs.primary),
                                    Container(width: 10, height: 10, decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle)),
                                  ])),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(_data.flowStepTitle, style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),
                                const SizedBox(height: 6),
                                Text('Maker: ${_data.flowMaker}', style: TextStyle(fontSize: 13, color: muted)),
                                const SizedBox(height: 6),
                                Text('Date ${_data.flowDate}', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha:0.6))),
                                const SizedBox(height: 8),
                                PrimaryButton(
                                  label: _data.flowStatus,
                                  onPressed: () {
                                    // button action
                                  },
                                  backgroundColor: cs.primary,
                                ),
                                const SizedBox(height: 8),
                                const Divider(),
                                const SizedBox(height: 8),
                                const Text('Next Approver:', style: TextStyle(fontSize: 13)),
                                const SizedBox(height: 6),
                                Text(_data.nextApprover, style: TextStyle(fontWeight: FontWeight.w800, color: textColor)),
                              ]))
                            ]),
                          ]),
                        ),
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
