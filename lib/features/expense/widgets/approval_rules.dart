import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/features/expense/dart/approval_mockdb.dart';
import 'package:ppv_components/features/expense/model/approval_model.dart';

class ApprovalRulesTablePage extends StatefulWidget {
  const ApprovalRulesTablePage({super.key});

  @override
  State<ApprovalRulesTablePage> createState() => _ApprovalRulesTableState();
}

class _ApprovalRulesTableState extends State<ApprovalRulesTablePage> {
  List<ApprovalRule> allRules = [];
  List<ApprovalRule> paginatedRules = [];

  int rowsPerPage = 10;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    allRules = List.from(dummyApprovalRules);
    _updatePagination();
  }

  void _updatePagination() {
    if (allRules.isEmpty) {
      paginatedRules = [];
      if (mounted) setState(() {});
      return;
    }

    final totalPages = (allRules.length / rowsPerPage).ceil();
    if (currentPage >= totalPages && totalPages > 0) currentPage = totalPages - 1;

    final s = currentPage * rowsPerPage;
    final e = (s + rowsPerPage) > allRules.length ? allRules.length : (s + rowsPerPage);
    final newSlice = allRules.sublist(s, e);

    if (mounted) {
      setState(() => paginatedRules = newSlice);
    } else {
      paginatedRules = newSlice;
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

  // ---------------- Add / Edit / View / Delete ----------------

  Future<void> onAddRule() async {
    final newRule = await AddApprovalRuleFormPage.show(context);
    if (newRule != null) {
      setState(() {
        allRules.insert(0, newRule);
        currentPage = 0;
        _updatePagination();
      });
    }
  }

  Future<void> onEditRule(ApprovalRule rule) async {
    final updated = await showDialog<ApprovalRule>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return EditApprovalRuleDialog(rule: rule);
      },
    );

    if (updated != null) {
      setState(() {
        final idx = allRules.indexWhere((r) => r.id == updated.id);
        if (idx != -1) {
          allRules[idx] = updated;
          _updatePagination();
        }
      });
    }
  }

  void onViewRule(ApprovalRule rule) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.36,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Approval Rule Details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: Icon(Icons.close, color: cs.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _detailRow('ID', rule.id ?? ''),
                const SizedBox(height: 6),
                _detailRow('Project', rule.project ?? ''),
                const SizedBox(height: 6),
                _detailRow('Department', rule.department ?? ''),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Steps', style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface)),
                ),
                if ((rule.steps ?? []).isEmpty)
                  Text('-', style: TextStyle(color: cs.onSurface))
                else
                  ...List<Widget>.from((rule.steps ?? []).map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(s, style: TextStyle(color: cs.onSurface))),
                      ],
                    ),
                  ))),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: PrimaryButton(
                    label: 'Close',
                    onPressed: () => Navigator.of(ctx).pop(),
                    backgroundColor: cs.primary,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> onDeleteRule(ApprovalRule rule) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${rule.id ?? ''}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (shouldDelete == true) {
      setState(() {
        allRules.removeWhere((r) => r.id == rule.id);
        final totalPagesNow = (allRules.isEmpty ? 1 : (allRules.length / rowsPerPage).ceil());
        if (currentPage >= totalPagesNow && currentPage > 0) {
          currentPage = totalPagesNow - 1;
        }
        _updatePagination();
      });
    }
  }

  // ---------------- small helpers ----------------

  Widget _detailRow(String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary))),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: TextStyle(color: cs.onSurface))),
        ],
      ),
    );
  }

  Widget _buildSingleStepCell(ApprovalRule rule) {
    final steps = rule.steps ?? <String>[];
    if (steps.isEmpty) {
      return const Text('-', overflow: TextOverflow.ellipsis);
    }

    final first = steps.first;

    // show only the first step as a single-line ellipsized text (no "View" button)
    return Text(
      first,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  OutlinedButton _editOutlined(BuildContext context, VoidCallback onPressed) {
    final cs = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.onSurface,
        side: BorderSide(color: cs.outline),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      child: const Text('Edit'),
    );
  }

  OutlinedButton _viewOutlined(BuildContext context, VoidCallback onPressed) {
    final cs = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.primary,
        side: BorderSide(color: cs.outline),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      child: const Text('View'),
    );
  }

  OutlinedButton _deleteOutlined(BuildContext context, VoidCallback onPressed) {
    final cs = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.error,
        side: BorderSide(color: cs.outline),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      child: const Text('Delete'),
    );
  }

  Widget _buildActionButtonsForRow(ApprovalRule rule) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _editOutlined(context, () => onEditRule(rule)),
        const SizedBox(width: 8),
        _viewOutlined(context, () => onViewRule(rule)),
        const SizedBox(width: 8),
        _deleteOutlined(context, () => onDeleteRule(rule)),
      ],
    );
  }

  Widget _addNewButton(ColorScheme cs) {
    return InkWell(
      onTap: onAddRule,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            const Icon(Icons.add, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              "Add New",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final totalPages = (allRules.isEmpty ? 1 : (allRules.length / rowsPerPage).ceil());

    // Columns: ID, Project, Department, Steps, Action (Action explicitly placed after Steps)
    final columns = [
      DataColumn(label: Text('ID', style: TextStyle(color: cs.onSurface))),
      DataColumn(label: Text('Project', style: TextStyle(color: cs.onSurface))),
      DataColumn(label: Text('Department', style: TextStyle(color: cs.onSurface))),
      DataColumn(label: Text('Steps', style: TextStyle(color: cs.onSurface))),
      DataColumn(label: Text('Actions', style: TextStyle(color: cs.onSurface))),

    ];

    final rows = paginatedRules.map((rule) {
      return DataRow(cells: [
        DataCell(Text(rule.id ?? '')),
        DataCell(Text(rule.project ?? '', overflow: TextOverflow.ellipsis)),
        DataCell(Text(rule.department ?? '', overflow: TextOverflow.ellipsis)),
        DataCell(_buildSingleStepCell(rule)),
        DataCell(_buildActionButtonsForRow(rule)),
      ]);
    }).toList();



    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage Approval Rules',
                    style: TextStyle(
                      color: cs.onPrimaryContainer,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Create and manage approval rules',
                    style: TextStyle(
                      color: cs.onPrimaryContainer.withOpacity(0.85),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              // right controls: Add button
              Row(
                children: [
                  _addNewButton(cs),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Table (wrap with Theme to ensure DataTable heading style is applied)
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 220),
            child: CustomTable(
              minTableWidth: 900,
              columns: columns,
              rows: rows,
            ),
          ),


          // pagination BELOW the table
          _paginationBar(context, totalPages),
        ],
      ),
    );
  }

  Widget _paginationBar(BuildContext context, int totalPages) {
    final cs = Theme.of(context).colorScheme;

    final start = allRules.isEmpty ? 0 : (currentPage * rowsPerPage);
    final end = (start + rowsPerPage) > allRules.length ? allRules.length : (start + rowsPerPage);

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
            "Showing ${allRules.isEmpty ? 0 : start + 1} to $end of ${allRules.length} entries",
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

/// ----------------- Add dialog (included to remove undefined errors) -----------------
class AddApprovalRuleFormPage extends StatefulWidget {
  const AddApprovalRuleFormPage({super.key});

  static Future<ApprovalRule?> show(BuildContext context) async {
    return await showGeneralDialog<ApprovalRule>(
      context: context,
      barrierLabel: "Add Approval Rule",
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) => const Center(child: AddApprovalRuleFormPage()),
      transitionBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<AddApprovalRuleFormPage> createState() => _AddApprovalRuleFormPageState();
}

class _AddApprovalRuleFormPageState extends State<AddApprovalRuleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController projectController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController stepsController = TextEditingController(); // comma-separated steps
  bool _isSubmitting = false;

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final project = projectController.text.trim();
      final department = departmentController.text.trim();
      final stepsRaw = stepsController.text.trim();
      final steps = stepsRaw.isEmpty ? <String>[] : stepsRaw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

      final newRule = ApprovalRule(
        id: id,
        project: project,
        department: department,
        steps: steps,
      );

      // small delay to show loading state briefly (optional)
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          Navigator.of(context).pop(newRule);
        }
      });
    }
  }

  @override
  void dispose() {
    projectController.dispose();
    departmentController.dispose();
    stepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = (size.width * 0.36).clamp(320.0, 760.0);

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: width,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6))],
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  children: [
                    const Expanded(child: Text("Add Approval Rule", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: projectController,
                  decoration: InputDecoration(labelText: 'Project', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Project is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: departmentController,
                  decoration: InputDecoration(labelText: 'Department', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Department is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: stepsController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Steps (comma separated)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SecondaryButton(
                      label: 'Cancel',
                      onPressed: () => Navigator.of(context).pop(),
                      isDisabled: _isSubmitting,
                    ),
                    const SizedBox(width: 12),
                    PrimaryButton(
                      label: 'Add Rule',
                      onPressed: _submit,
                      isLoading: _isSubmitting,
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class EditApprovalRuleDialog extends StatefulWidget {
  final ApprovalRule rule;
  const EditApprovalRuleDialog({required this.rule, super.key});

  @override
  State<EditApprovalRuleDialog> createState() => _EditApprovalRuleDialogState();
}

class _EditApprovalRuleDialogState extends State<EditApprovalRuleDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController projectController;
  late TextEditingController departmentController;
  late TextEditingController stepsController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    projectController = TextEditingController(text: widget.rule.project ?? '');
    departmentController = TextEditingController(text: widget.rule.department ?? '');
    stepsController = TextEditingController(text: (widget.rule.steps ?? []).join(', '));
  }

  @override
  void dispose() {
    projectController.dispose();
    departmentController.dispose();
    stepsController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      final updated = ApprovalRule(
        id: widget.rule.id,
        project: projectController.text.trim(),
        department: departmentController.text.trim(),
        steps: stepsController.text.trim().isEmpty
            ? <String>[]
            : stepsController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      );

      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) Navigator.of(context).pop(updated);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width * 0.36).clamp(320.0, 760.0);
    return Dialog(
      child: Container(
        width: width,
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(
                children: [
                  const Expanded(child: Text('Edit Approval Rule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: projectController,
                decoration: InputDecoration(labelText: 'Project', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                validator: (v) => v == null || v.trim().isEmpty ? 'Project is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: departmentController,
                decoration: InputDecoration(labelText: 'Department', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                validator: (v) => v == null || v.trim().isEmpty ? 'Department is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: stepsController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(labelText: 'Steps (comma separated)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SecondaryButton(label: 'Cancel', onPressed: () => Navigator.of(context).pop(), isDisabled: _isSubmitting),
                  const SizedBox(width: 12),
                  PrimaryButton(label: 'Save', onPressed: _save, isLoading: _isSubmitting),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
