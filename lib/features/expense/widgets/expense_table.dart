import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/toggle_button.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/features/expense/model/expense_model.dart';
import 'package:ppv_components/features/expense/widgets/expense_grid.dart';

class ExpenseTableView extends StatefulWidget {
  final List<GreenNote> expenseData;
  final void Function(GreenNote) onDelete;
  final void Function(GreenNote) onEdit;

  const ExpenseTableView({
    super.key,
    required this.expenseData,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<ExpenseTableView> createState() => _ExpenseTableViewState();
}

class _ExpenseTableViewState extends State<ExpenseTableView> {
  int toggleIndex = 0;
  int rowsPerPage = 10;
  int currentPage = 0;
  late List<GreenNote> paginatedNotes;

  @override
  void initState() {
    super.initState();
    _updatePagination();
  }

  @override
  void didUpdateWidget(covariant ExpenseTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePagination();
  }

  void _updatePagination() {
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, widget.expenseData.length);
    setState(() {
      paginatedNotes = widget.expenseData.sublist(start, end);
      final totalPages = (widget.expenseData.length / rowsPerPage).ceil();
      if (currentPage >= totalPages && totalPages > 0) {
        currentPage = totalPages - 1;
        paginatedNotes = widget.expenseData.sublist(start, end);
      }
    });
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

  Future<void> deleteNote(GreenNote note) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete expense SN ${note.sNo}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      widget.onDelete(note);
      _updatePagination();
    }
  }

  Future<void> onEditNote(GreenNote note) async {
    final formKey = GlobalKey<FormState>();
    final projectController = TextEditingController(text: note.projectName);
    final vendorController = TextEditingController(text: note.vendorName);
    final invoiceController = TextEditingController(text: note.invoiceValue);
    final statusController = TextEditingController(text: note.status);
    final nextApproverController = TextEditingController(text: note.nextApprover);
    final dateController = TextEditingController(text: note.date);

    final result = await showDialog<bool>(
      context: context,
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
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Edit Expense",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            icon: Icon(Icons.close, color: colorScheme.onSurface),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(ctx, Icons.business, "Project Name", projectController),
                      const SizedBox(height: 14),
                      _buildInputField(ctx, Icons.person, "Vendor Name", vendorController),
                      const SizedBox(height: 14),
                      _buildInputField(ctx, Icons.receipt, "Invoice Value", invoiceController),
                      const SizedBox(height: 14),
                      _buildInputField(ctx, Icons.date_range, "Date", dateController),
                      const SizedBox(height: 14),
                      _buildInputField(ctx, Icons.flag, "Status", statusController),
                      const SizedBox(height: 14),
                      _buildInputField(ctx, Icons.verified_user, "Next Approver", nextApproverController),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text("Cancel"),
                          ),
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
      barrierDismissible: false,
    );

    if (result == true) {
      final updatedNote = GreenNote(
        sNo: note.sNo,
        projectName: projectController.text,
        vendorName: vendorController.text,
        invoiceValue: invoiceController.text,
        date: dateController.text,
        status: statusController.text,
        nextApprover: nextApproverController.text,
      );
      widget.onEdit(updatedNote);
      _updatePagination();
    }
  }

  Widget _buildInputField(
      BuildContext context,
      IconData icon,
      String label,
      TextEditingController controller,
      ) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
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
      validator: (val) => (val == null || val.isEmpty) ? 'Please enter $label' : null,
    );
  }

  Future<void> onViewNote(GreenNote note) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                      "Expense Details",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: Icon(Icons.close, color: colorScheme.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetail(ctx, Icons.confirmation_number, "S. No.", note.sNo),
                _buildDetail(ctx, Icons.business, "Project Name", note.projectName),
                _buildDetail(ctx, Icons.person, "Vendor Name", note.vendorName),
                _buildDetail(ctx, Icons.receipt, "Invoice Value", note.invoiceValue),
                _buildDetail(ctx, Icons.date_range, "Date", note.date),
                _buildDetail(ctx, Icons.flag, "Status", note.status),
                _buildDetail(ctx, Icons.verified_user, "Next Approver", note.nextApprover),
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

  Widget _buildDetail(BuildContext ctx, IconData icon, String label, String value) {
    final colorScheme = Theme.of(ctx).colorScheme;
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
          Icon(icon, color: colorScheme.primary, size: 22),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final columns = [
      DataColumn(label: Text('S. No.', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Project Name', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Vendor Name', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Invoice Value', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Date', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Status', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Next Approver', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Actions', style: TextStyle(color: colorScheme.onSurface))),
    ];

    final rows = paginatedNotes.map((note) {
      return DataRow(
        cells: [
          DataCell(Text(note.sNo, style: TextStyle(color: colorScheme.onSurface))),
          DataCell(Text(note.projectName, style: TextStyle(color: colorScheme.onSurface))),
          DataCell(Text(note.vendorName, style: TextStyle(color: colorScheme.onSurface))),
          DataCell(Text(note.invoiceValue, style: TextStyle(color: colorScheme.onSurface))),
          DataCell(Text(note.date, style: TextStyle(color: colorScheme.onSurface))),
          DataCell(Text(note.status, style: TextStyle(color: colorScheme.onSurface))),
          DataCell(Text(note.nextApprover, style: TextStyle(color: colorScheme.onSurface))),
          DataCell(Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: () => onEditNote(note),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.onSurface,
                  side: BorderSide(color: colorScheme.outline),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('Edit'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => onViewNote(note),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.outline),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('View'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => deleteNote(note),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.outline),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('Delete'),
              ),
            ],
          )),
        ],
      );
    }).toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
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
                              'Expenses',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage your expense approvals',
                              style: TextStyle(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        ToggleBtn(
                          labels: ['Table', 'Grid'],
                          selectedIndex: toggleIndex,
                          onChanged: (index) => setState(() => toggleIndex = index),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: toggleIndex == 0
                          ? Column(
                        children: [
                          Expanded(child: CustomTable(columns: columns, rows: rows)),
                          _paginationBar(context),
                        ],
                      )
                          : ExpenseGridView(
                        expenseList: widget.expenseData,
                        rowsPerPage: rowsPerPage,
                        currentPage: currentPage,
                        onPageChanged: (page) => setState(() => currentPage = page),
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

  Widget _paginationBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalPages = (widget.expenseData.length / rowsPerPage).ceil();
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, widget.expenseData.length);

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
            "Showing ${widget.expenseData.isEmpty ? 0 : start + 1} to $end of ${widget.expenseData.length} entries",
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
                      backgroundColor: i == currentPage ? colorScheme.primary : colorScheme.surfaceContainer,
                      foregroundColor: i == currentPage ? Colors.white : colorScheme.onSurface,
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
