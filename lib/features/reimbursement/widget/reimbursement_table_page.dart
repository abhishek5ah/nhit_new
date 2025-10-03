import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/toggle_button.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/features/reimbursement/data/reimbursement_dummydata/reimbursement_note_dummy.dart';
import 'package:ppv_components/features/reimbursement/models/reimbursement_models/travel_detail_model.dart';
import 'package:ppv_components/features/reimbursement/widget/reimbursement_grid.dart';

class ReimbursementTablePage extends StatefulWidget {
  const ReimbursementTablePage({super.key});

  @override
  State<ReimbursementTablePage> createState() => _ReimbursementTablePageState();
}

class _ReimbursementTablePageState extends State<ReimbursementTablePage> {
  late List<ReimbursementNote> allNotes;
  List<ReimbursementNote> paginatedNotes = [];
  int rowsPerPage = 10;
  int currentPage = 0;
  int toggleIndex = 0;

  late TextEditingController projectController;
  late TextEditingController employeeController;
  late TextEditingController amountController;
  late TextEditingController dateController;
  late TextEditingController approverController;
  late TextEditingController utrController;
  late TextEditingController utrDateController;
  late String statusValue;
  late GlobalKey<FormState> formKey;

  List<String> get availableStatus {
    // Extracts unique statuses from current notes
    return allNotes
        .map((n) => n.status)
        .toSet()
        .toList()
      ..sort();
  }

  @override
  void initState() {
    super.initState();
    allNotes = List<ReimbursementNote>.from(dummyReimbursementNotes);
    projectController = TextEditingController();
    employeeController = TextEditingController();
    amountController = TextEditingController();
    dateController = TextEditingController();
    approverController = TextEditingController();
    utrController = TextEditingController();
    utrDateController = TextEditingController();
    statusValue = availableStatus.isNotEmpty ? availableStatus.first : '';
    _updatePagination();
  }

  @override
  void dispose() {
    projectController.dispose();
    employeeController.dispose();
    amountController.dispose();
    dateController.dispose();
    approverController.dispose();
    utrController.dispose();
    utrDateController.dispose();
    super.dispose();
  }

  void _updatePagination() {
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, allNotes.length);
    final totalPages = (allNotes.length / rowsPerPage).ceil();
    if (currentPage >= totalPages && totalPages > 0) {
      currentPage = totalPages - 1;
    }
    if (mounted) {
      setState(() {
        paginatedNotes = allNotes.sublist(start, end);
      });
    } else {
      paginatedNotes = allNotes.sublist(start, end);
    }
  }

  void changeRowsPerPage(int? value) {
    setState(() {
      rowsPerPage = value ?? 10;
      currentPage = 0;
      _updatePagination();
    });
  }

  void gotoPage(int page) {
    setState(() {
      currentPage = page;
      _updatePagination();
    });
  }

  DataCell _buildCell(String text) {
    return DataCell(
      Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }

  Widget _statusBadge(BuildContext context, String status) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: cs.primary,
        border: Border.all(color: cs.primary, width: 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        status,
        textAlign: TextAlign.center,
        style: TextStyle(color: cs.onPrimary, fontSize: 11, fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildExtraInfo(ReimbursementNote note) {
    if (note.status == "Sent for Approval" && note.nextApprover.isNotEmpty) {
      return Text("Next Approver: ${note.nextApprover}", style: TextStyle(color: Theme.of(context).colorScheme.onSurface));
    } else if (note.status == "Paid" && note.utrNumber.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("UTR No: ${note.utrNumber}", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          Text("UTR Date: ${note.utrDate}", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        ],
      );
    }
    return Text("-", style: TextStyle(color: Theme.of(context).colorScheme.onSurface));
  }

  Future<void> onAddNote() async {
    formKey = GlobalKey<FormState>();
    projectController.text = '';
    employeeController.text = '';
    amountController.text = '';
    dateController.text = '';
    approverController.text = '';
    utrController.text = '';
    utrDateController.text = '';
    statusValue = availableStatus.isNotEmpty ? availableStatus.first : '';

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return Dialog(
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.4,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline, width: 0.5),
              borderRadius: BorderRadius.circular(20),
              color: colorScheme.surface,
            ),
            child: StatefulBuilder(
              builder: (context, setState) => SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Add New Reimbursement",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            icon: Icon(Icons.close, color: colorScheme.onSurface),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(ctx, "Project", projectController),
                      const SizedBox(height: 16),
                      _buildInputField(ctx, "Employee", employeeController),
                      const SizedBox(height: 16),
                      _buildInputField(ctx, "Amount", amountController),
                      const SizedBox(height: 16),
                      _buildInputField(ctx, "Date", dateController),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: statusValue,
                        decoration: InputDecoration(
                          labelText: "Status",
                          labelStyle: TextStyle(color: colorScheme.onSurface),
                          filled: true,
                          fillColor: colorScheme.surfaceContainer,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: colorScheme.outline),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: colorScheme.primary),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: availableStatus.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => statusValue = v);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(ctx, "Next Approver", approverController),
                      const SizedBox(height: 16),
                      _buildInputField(ctx, "UTR Number", utrController),
                      const SizedBox(height: 16),
                      _buildInputField(ctx, "UTR Date", utrDateController),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("Cancel")),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState?.validate() ?? false) {
                                Navigator.of(ctx).pop(true);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Save"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (result == true) {
      setState(() {
        final newNote = ReimbursementNote(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sNo: (allNotes.length + 1).toString(),
          projectName: projectController.text,
          employeeName: employeeController.text,
          amount: amountController.text,
          date: dateController.text,
          status: statusValue,
          nextApprover: approverController.text,
          utrNumber: utrController.text,
          utrDate: utrDateController.text,
        );
        allNotes.insert(0, newNote);
        statusValue = availableStatus.isNotEmpty ? availableStatus.first : '';
        currentPage = 0;
        _updatePagination();
      });
    }
  }

  Future<void> onEditNote(ReimbursementNote note) async {
    formKey = GlobalKey<FormState>();
    projectController.text = note.projectName;
    employeeController.text = note.employeeName;
    amountController.text = note.amount;
    dateController.text = note.date;
    approverController.text = note.nextApprover;
    utrController.text = note.utrNumber;
    utrDateController.text = note.utrDate;
    statusValue = note.status;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return Dialog(
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.4,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline, width: 0.5),
              borderRadius: BorderRadius.circular(20),
              color: colorScheme.surface,
            ),
            child: StatefulBuilder(
              builder: (context, setState) => SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Edit Reimbursement",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            icon: Icon(Icons.close, color: colorScheme.onSurface),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(ctx, "Project", projectController),
                      const SizedBox(height: 16),
                      _buildInputField(ctx, "Employee", employeeController),
                      const SizedBox(height: 16),
                      _buildInputField(ctx, "Amount", amountController),
                      const SizedBox(height: 16),
                      _buildInputField(ctx, "Date", dateController),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: statusValue,
                        decoration: InputDecoration(
                          labelText: "Status",
                          labelStyle: TextStyle(color: colorScheme.onSurface),
                          filled: true,
                          fillColor: colorScheme.surfaceContainer,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: colorScheme.outline),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: colorScheme.primary),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: availableStatus.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => statusValue = v);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(ctx, "Next Approver", approverController),
                      const SizedBox(height: 16),
                      _buildInputField(ctx, "UTR Number", utrController),
                      const SizedBox(height: 16),
                      _buildInputField(ctx, "UTR Date", utrDateController),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("Cancel")),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState?.validate() ?? false) {
                                Navigator.of(ctx).pop(true);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Save"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (result == true) {
      setState(() {
        final idx = allNotes.indexWhere((n) => n.sNo == note.sNo);
        if (idx != -1) {
          final updated = ReimbursementNote(
            id: note.id,
            sNo: note.sNo,
            projectName: projectController.text,
            employeeName: employeeController.text,
            amount: amountController.text,
            date: dateController.text,
            status: statusValue,
            nextApprover: approverController.text,
            utrNumber: utrController.text,
            utrDate: utrDateController.text,
          );
          allNotes[idx] = updated;
          statusValue = availableStatus.isNotEmpty ? availableStatus.first : '';
          _updatePagination();
        }
      });
    }
  }

  Future<void> onViewNote(ReimbursementNote note) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: colorScheme.surface,
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.4,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline, width: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Reimbursement Details",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: Icon(Icons.close, color: colorScheme.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetail(ctx, "S.No", note.sNo),
                _buildDetail(ctx, "Project", note.projectName),
                _buildDetail(ctx, "Employee", note.employeeName),
                _buildDetail(ctx, "Amount", note.amount),
                _buildDetail(ctx, "Date", note.date),
                _buildDetail(ctx, "Status", note.status),
                if (note.nextApprover.isNotEmpty)
                  _buildDetail(ctx, "Next Approver", note.nextApprover),
                if (note.utrNumber.isNotEmpty)
                  _buildDetail(ctx, "UTR Number", note.utrNumber),
                if (note.utrDate.isNotEmpty)
                  _buildDetail(ctx, "UTR Date", note.utrDate),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> onDeleteNote(ReimbursementNote note) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete ${note.projectName}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      setState(() {
        allNotes.removeWhere((n) => n.sNo == note.sNo);
        statusValue = availableStatus.isNotEmpty ? availableStatus.first : '';
        final totalPagesNow = (allNotes.isEmpty ? 1 : (allNotes.length / rowsPerPage).ceil());
        if (currentPage >= totalPagesNow && currentPage > 0) {
          currentPage = totalPagesNow - 1;
        }
        _updatePagination();
      });
    }
  }

  Widget _buildInputField(BuildContext context, String label, TextEditingController controller) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.edit, color: theme.colorScheme.onSurfaceVariant),
        labelText: label,
        labelStyle: TextStyle(color: theme.colorScheme.onSurface),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainer,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.primary),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildDetail(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline, width: 0.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: colorScheme.onSurface)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalPages = (allNotes.isEmpty ? 1 : (allNotes.length / rowsPerPage).ceil());

    final columns = [
      DataColumn(label: Text('S.No', style: TextStyle(color: cs.onSurface))),
      DataColumn(label: Text('Project', style: TextStyle(color: cs.onSurface))),
      DataColumn(label: Text('Employee', style: TextStyle(color: cs.onSurface))),
      DataColumn(label: Text('Amount', style: TextStyle(color: cs.onSurface))),
      DataColumn(label: Text('Date', style: TextStyle(color: cs.onSurface))),
      DataColumn(label: Text('Status', style: TextStyle(color: cs.onSurface))),
      DataColumn(label: Text('Extra Info', style: TextStyle(color: cs.onSurface))),
      DataColumn(label: Text('Actions', style: TextStyle(color: cs.onSurface))),
    ];

    final rows = paginatedNotes.map((note) {
      return DataRow(
        cells: [
          _buildCell(note.sNo),
          _buildCell(note.projectName),
          _buildCell(note.employeeName),
          _buildCell("₹${note.amount}"),
          _buildCell(note.date),
          DataCell(_statusBadge(context, note.status)),
          DataCell(_buildExtraInfo(note)),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () => onEditNote(note),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.onSurface,
                    side: BorderSide(color: cs.outline),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => onViewNote(note),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.primary,
                    side: BorderSide(color: cs.outline),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text('View'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => onDeleteNote(note),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.error,
                    side: BorderSide(color: cs.outline),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();

    return Scaffold(
      backgroundColor: cs.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reimbursements',
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage your reimbursement notes',
                              style: TextStyle(
                                color: cs.onSurface.withOpacity(0.6),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            ToggleBtn(
                              labels: ['Table', 'Grid'],
                              selectedIndex: toggleIndex,
                              onChanged: (i) => setState(() => toggleIndex = i),
                            ),
                            const SizedBox(width: 12),
                            PrimaryButton(
                              label: "Add New Reimbursement",
                              icon: Icons.add,
                              onPressed: onAddNote,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: toggleIndex == 0
                          ? Column(
                        children: [
                          Expanded(
                            child: CustomTable(
                              minTableWidth: 1200,
                              columns: columns,
                              rows: rows,
                            ),
                          ),
                          _paginationBar(context, totalPages),
                        ],
                      )
                          : ReimbursementGridView(
                          noteList: allNotes,
                          rowsPerPage: rowsPerPage,
                          currentPage: currentPage,
                        onPageChanged: (page) =>
                            setState(() => currentPage = page),
                        onRowsPerPageChanged: (rows) => setState(() {
                          rowsPerPage = rows ?? rowsPerPage;
                          currentPage = 0;
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paginationBar(BuildContext context, int totalPages) {
    final cs = Theme.of(context).colorScheme;
    final start = allNotes.isEmpty ? 0 : (currentPage * rowsPerPage);
    final end = (start + rowsPerPage).clamp(0, allNotes.length);

    int windowSize = 3;
    int startWindow = 0;
    int endWindow = totalPages;

    if (totalPages > windowSize) {
      if (currentPage <= 1) {
        startWindow = 0;
        endWindow = windowSize;
      } else if (currentPage >= totalPages - 2) {
        startWindow = totalPages - windowSize;
        endWindow = totalPages;
      } else {
        startWindow = currentPage - 1;
        endWindow = currentPage + 2;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Showing ${allNotes.isEmpty ? 0 : start + 1} to $end of ${allNotes.length} entries",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: currentPage > 0 ? () => gotoPage(currentPage - 1) : null,
              ),
              for (int i = startWindow; i < endWindow; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: i == currentPage ? cs.primary : cs.surfaceContainer,
                      foregroundColor: i == currentPage ? Colors.white : cs.onSurface,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      minimumSize: const Size(40, 40),
                    ),
                    onPressed: () => gotoPage(i),
                    child: Text('${i + 1}'),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: currentPage < totalPages - 1 ? () => gotoPage(currentPage + 1) : null,
              ),
              const SizedBox(width: 20),
              DropdownButton<int>(
                value: rowsPerPage,
                items: [5, 10, 20, 50].map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
                onChanged: changeRowsPerPage,
                style: Theme.of(context).textTheme.bodyMedium,
                underline: const SizedBox(),
              ),
              const SizedBox(width: 8),
              Text("page", style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
