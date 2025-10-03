import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/toggle_button.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/features/bank_rtgs_neft/models/bank_models/bank_rtgs_neft_model.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/rtgs_grid.dart';

class RtgsTableView extends StatefulWidget {
  final List<BankRtgsNeft> rtgsData;
  final Future<void> Function(BankRtgsNeft) onDelete;
  final Future<void> Function(BankRtgsNeft) onEdit;

  const RtgsTableView({
    super.key,
    required this.rtgsData,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<RtgsTableView> createState() => _RtgsTableViewState();
}

class _RtgsTableViewState extends State<RtgsTableView> {
  int toggleIndex = 0;
  int rowsPerPage = 10;
  int currentPage = 0;
  late List<BankRtgsNeft> paginatedRtgs;

  @override
  void initState() {
    super.initState();
    _updatePagination();
  }

  @override
  void didUpdateWidget(covariant RtgsTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePagination();
  }

  void _updatePagination() {
    final totalPages = (widget.rtgsData.length / rowsPerPage).ceil();
    setState(() {
      if (currentPage >= totalPages && totalPages > 0) {
        currentPage = totalPages - 1;
      }
      final start = currentPage * rowsPerPage;
      final end = (start + rowsPerPage).clamp(0, widget.rtgsData.length);
      paginatedRtgs = widget.rtgsData.sublist(start, end);
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

  Future<void> onViewRtgs(BankRtgsNeft rtgs) async {
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
                      "RTGS Details",
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
                _buildDetail(ctx, "S.No", rtgs.slNo),
                _buildDetail(ctx, "Vendor Name", rtgs.vendorName),
                _buildDetail(ctx, "Amount", rtgs.amount),
                _buildDetail(ctx, "Date", rtgs.date),
                _buildDetail(ctx, "Status", rtgs.status),
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

  Future<void> deleteRtgs(BankRtgsNeft rtgs) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete RTGS #${rtgs.slNo}?'),
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
      await widget.onDelete(rtgs);
      _updatePagination();
    }
  }

  Future<void> onEditRtgs(BankRtgsNeft rtgs) async {
    final updatedRtgs = await showDialog<BankRtgsNeft?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RtgsEditDialog(rtgs: rtgs),
    );

    if (updatedRtgs != null) {
      await widget.onEdit(updatedRtgs);
      _updatePagination();
    }
  }

  Widget _buildInputField(
    BuildContext ctx,
    String label,
    TextEditingController controller,
  ) {
    final colorScheme = Theme.of(ctx).colorScheme;
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
      ),
      validator: (val) =>
          val == null || val.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildDetail(BuildContext ctx, String label, String value) {
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
            child: Text(value, style: TextStyle(color: colorScheme.onSurface)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final columns = [
      DataColumn(
        label: Text('S.No', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text(
          'Vendor Name',
          style: TextStyle(color: colorScheme.onSurface),
        ),
      ),
      DataColumn(
        label: Text('Amount', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Date', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Status', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Actions', style: TextStyle(color: colorScheme.onSurface)),
      ),
    ];

    final rows = paginatedRtgs.map((rtgs) {
      return DataRow(
        cells: [
          DataCell(
            Text(rtgs.slNo, style: TextStyle(color: colorScheme.onSurface)),
          ),
          DataCell(
            Text(
              rtgs.vendorName,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Text(rtgs.amount, style: TextStyle(color: colorScheme.onSurface)),
          ),
          DataCell(
            Text(rtgs.date, style: TextStyle(color: colorScheme.onSurface)),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                rtgs.status,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () => onViewRtgs(rtgs),
                  child: const Text('View'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => onEditRtgs(rtgs),
                  child: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => deleteRtgs(rtgs),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.outline),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
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
                              'RTGS/NEFT Entries',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage your bank RTGS/NEFT details',
                              style: TextStyle(
                                color: colorScheme.onSurface.withAlpha(153),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        ToggleBtn(
                          labels: const ['Table', 'Grid'],
                          selectedIndex: toggleIndex,
                          onChanged: (index) => setState(() {
                            toggleIndex = index;
                          }),
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
                                    columns: columns,
                                    rows: rows,
                                  ),
                                ),
                                _paginationBar(context),
                              ],
                            )
                          : RtgsGridView(
                              rtgsList: widget.rtgsData,
                              rowsPerPage: rowsPerPage,
                              currentPage: currentPage,
                        onPageChanged: (page) {
                          setState(() {
                            currentPage = page;
                            _updatePagination();
                          });
                        },
                        onRowsPerPageChanged: (rows) {
                          setState(() {
                            rowsPerPage = rows ?? rowsPerPage;
                            currentPage = 0;
                            _updatePagination();
                          });
                        },
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

    final totalPages = (widget.rtgsData.length / rowsPerPage).ceil();
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, widget.rtgsData.length);

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
            "Showing ${widget.rtgsData.isEmpty ? 0 : start + 1} to $end of ${widget.rtgsData.length} entries",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: currentPage > 0
                    ? () => gotoPage(currentPage - 1)
                    : null,
              ),
              for (int i = startWindow; i < endWindow; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: i == currentPage
                          ? colorScheme.primary
                          : colorScheme.surfaceContainer,
                      foregroundColor: i == currentPage
                          ? Colors.white
                          : colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      minimumSize: const Size(40, 40),
                    ),
                    onPressed: () => gotoPage(i),
                    child: Text('${i + 1}'),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: currentPage < totalPages - 1
                    ? () => gotoPage(currentPage + 1)
                    : null,
              ),
              const SizedBox(width: 20),
              DropdownButton<int>(
                value: rowsPerPage,
                items: [5, 10, 20, 50]
                    .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                    .toList(),
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

// Separate dialog widget for editing RTGS entry
class RtgsEditDialog extends StatefulWidget {
  final BankRtgsNeft rtgs;

  const RtgsEditDialog({required this.rtgs, Key? key}) : super(key: key);

  @override
  _RtgsEditDialogState createState() => _RtgsEditDialogState();
}

class _RtgsEditDialogState extends State<RtgsEditDialog> {
  late final TextEditingController slNoController;
  late final TextEditingController vendorNameController;
  late final TextEditingController amountController;
  late final TextEditingController dateController;
  late final TextEditingController statusController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    slNoController = TextEditingController(text: widget.rtgs.slNo);
    vendorNameController = TextEditingController(text: widget.rtgs.vendorName);
    amountController = TextEditingController(text: widget.rtgs.amount);
    dateController = TextEditingController(text: widget.rtgs.date);
    statusController = TextEditingController(text: widget.rtgs.status);
  }

  @override
  void dispose() {
    slNoController.dispose();
    vendorNameController.dispose();
    amountController.dispose();
    dateController.dispose();
    statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outline, width: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Edit RTGS",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      icon: Icon(Icons.close, color: colorScheme.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInputField(context, "S.No", slNoController),
                const SizedBox(height: 16),
                _buildInputField(context, "Vendor Name", vendorNameController),
                const SizedBox(height: 16),
                _buildInputField(context, "Amount", amountController),
                const SizedBox(height: 16),
                _buildInputField(context, "Date (YYYY-MM-DD)", dateController),
                const SizedBox(height: 16),
                _buildInputField(context, "Status", statusController),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          Navigator.of(context).pop(
                            BankRtgsNeft(
                              id: widget.rtgs.id,
                              slNo: slNoController.text,
                              vendorName: vendorNameController.text,
                              amount: amountController.text,
                              date: dateController.text,
                              status: statusController.text,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
    );
  }

  Widget _buildInputField(
    BuildContext ctx,
    String label,
    TextEditingController controller,
  ) {
    final colorScheme = Theme.of(ctx).colorScheme;
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
      ),
      validator: (val) =>
          val == null || val.isEmpty ? 'Please enter $label' : null,
    );
  }
}
