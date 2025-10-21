import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:ppv_components/features/bank_rtgs_neft/data/bank_dummydata/dummy_approvers.dart';
import 'package:ppv_components/features/bank_rtgs_neft/models/bank_models/approver_model.dart';

class ApprovalFlowPage extends StatefulWidget {
  const ApprovalFlowPage({super.key});

  @override
  State<ApprovalFlowPage> createState() => _ApprovalFlowPageState();
}

class _ApprovalFlowPageState extends State<ApprovalFlowPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();

  final List<String> approverRoles = [
    'Approver 1',
    'Approver 2',
    'Approver 3',
  ];

  List<_ApproverRow> approverRows = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadApprovers();
  }

  Future<void> _loadApprovers() async {
    setState(() => _loading = true);
    try {
      final List<Approver> data = await fetchDummyApprovers();
      final loaded = data
          .map((a) => _ApproverRow(id: a.id, name: a.name, role: a.role))
          .toList();
      if (loaded.isNotEmpty) {
        approverRows = loaded;
      } else {
        approverRows = [
          _ApproverRow(id: 'r0', name: 'Select name', role: approverRoles.first)
        ];
      }
    } catch (e) {
      // fallback default row on error
      approverRows = [
        _ApproverRow(id: 'r0', name: 'Select name', role: approverRoles.first)
      ];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _addEmptyApprover() {
    setState(() {
      approverRows.add(_ApproverRow(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Select name',
        role: approverRoles.first,
      ));
    });
  }

  void _removeApprover(int index) {
    setState(() {
      if (approverRows.length > 1) approverRows.removeAt(index);
    });
  }

  bool _validateRowsAndFields() {
    final minText = _minController.text.trim();
    final maxText = _maxController.text.trim();

    if (minText.isNotEmpty) {
      final minVal = double.tryParse(minText);
      if (minVal == null || minVal < 0) return false;
    }
    if (maxText.isNotEmpty) {
      final maxVal = double.tryParse(maxText);
      if (maxVal == null || maxVal < 0) return false;
    }

    for (var r in approverRows) {
      if (r.name.trim().isEmpty || r.name == 'Select name') return false;
    }

    final seen = <String>{};
    for (var r in approverRows) {
      if (seen.contains(r.name)) return false;
      seen.add(r.name);
    }

    return true;
  }

  void _save() {
    if (!_validateRowsAndFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill valid values and approver names.',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final minAmount = _minController.text;
      final maxAmount = _maxController.text;
      final payload = approverRows
          .map((r) => Approver(id: r.id, name: r.name, role: r.role))
          .toList();
      debugPrint(
          'SAVE -> min:$minAmount max:$maxAmount approvers: ${payload.map((p) => p.toJson())}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Saved (demo)',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // page now has NO AppBar — content will render flush under parent's header (if any)
    return LayoutBuilder(builder: (context, constraints) {
      final theme = Theme.of(context);
      final divider = theme.dividerColor;
      final cs = theme.colorScheme;
      final surfaceContainer = cs.surfaceContainer;

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: SizedBox(
          width: double.infinity,
          child: Card(
            color: surfaceContainer, // use theme's container bg
            elevation: 2,
            margin: EdgeInsets.zero,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: _loading
              // full-page centered spinner while data loads
                  ? SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              )
                  : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Approval Flow Details',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 18),

                    // Amount inputs (side-by-side on wide)
                    LayoutBuilder(builder: (ctx, inner) {
                      if (inner.maxWidth > 600) {
                        return Row(
                          children: [
                            // left field with a small right padding so text doesn't touch seam visually
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 6.0, left: 6.0),
                                child: _buildAttachedLeftAmountField(
                                    _minController,
                                    'Minimum Amount (Lakhs)'),
                              ),
                            ),

                            // gap between fields
                            const SizedBox(width: 12),

                            // right field with a small left padding
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                                child: _buildAttachedRightAmountField(
                                    _maxController,
                                    'Maximum Amount (Lakhs)'),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildAmountField(
                                _minController, 'Minimum Amount (Lakhs)'),
                            const SizedBox(height: 12),
                            _buildAmountField(
                                _maxController, 'Maximum Amount (Lakhs)'),
                          ],
                        );
                      }
                    }),

                    const SizedBox(height: 24),
                    const Text('Approvers',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: approverRows.length,
                      itemBuilder: (context, index) {
                        final row = approverRows[index];
                        return Padding(
                          padding:
                          const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: divider),
                                    borderRadius: BorderRadius.circular(6),
                                    color: cs.surfaceContainer,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child:
                                        DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            value: row.name ==
                                                'Select name'
                                                ? null
                                                : row.name,
                                            hint:
                                            const Text('Select name'),
                                            items: approverRows
                                                .map((r) => r.name)
                                                .toSet()
                                                .map((n) => DropdownMenuItem(
                                                value: n,
                                                child: Text(n)))
                                                .toList(),
                                            onChanged: (val) {
                                              if (val == null) return;
                                              setState(() => row.name = val);
                                            },
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _removeApprover(index),
                                        icon: const Icon(Icons.more_vert),
                                        tooltip: 'Options',
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: divider),
                                    borderRadius: BorderRadius.circular(6),
                                    color: cs.surfaceContainer,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: row.role,
                                      items: approverRoles
                                          .map((r) => DropdownMenuItem(
                                          value: r, child: Text(r)))
                                          .toList(),
                                      onChanged: (val) {
                                        if (val == null) return;
                                        setState(() => row.role = val);
                                      },
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              IconButton(
                                onPressed: () => _removeApprover(index),
                                tooltip: 'Remove',
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        PrimaryButton(
                          label: 'Add Approver',
                          icon: Icons.add,
                          backgroundColor: cs.primary,
                          onPressed: _addEmptyApprover,
                        ),
                        const SizedBox(width: 12),
                        SecondaryButton(
                          label: 'Reset',
                          backgroundColor:
                          cs.inversePrimary.withOpacity(0.08),
                          onPressed: () {
                            setState(() {
                              _minController.clear();
                              _maxController.clear();
                              // reload approvers (will show spinner until reload completes)
                              _loadApprovers();
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Align(
                      alignment: Alignment.centerRight,
                      child: PrimaryButton(
                        label: 'Save',
                        backgroundColor: cs.primary,
                        onPressed: _save,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  // --- Input field variants ---

  /// Normal single field used when stacked (mobile).
  Widget _buildAmountField(
      TextEditingController controller, String label) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // prefer InputDecorationTheme.fillColor if the app theme provides one,
    // otherwise fall back to a sensible color from the color scheme.
    final fill = theme.inputDecorationTheme.fillColor ?? cs.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontSize: 14, color: theme.textTheme.bodyMedium?.color)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
          ],
          validator: (v) {
            if (v == null || v.trim().isEmpty) return null;
            final parsed = double.tryParse(v);
            if (parsed == null) return 'Invalid number';
            if (parsed < 0) return 'Cannot be negative';
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: fill,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Theme.of(context).dividerColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Theme.of(context).dividerColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                BorderSide(color: cs.primary, width: 1.6)),
            hintText: '0.00',
          ),
        )
      ],
    );
  }

  /// Left field of attached pair (rounded on left side only)
  Widget _buildAttachedLeftAmountField(
      TextEditingController controller, String label) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fill = theme.inputDecorationTheme.fillColor ?? cs.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontSize: 14, color: theme.textTheme.bodyMedium?.color)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
          ],
          validator: (v) {
            if (v == null || v.trim().isEmpty) return null;
            final parsed = double.tryParse(v);
            if (parsed == null) return 'Invalid number';
            if (parsed < 0) return 'Cannot be negative';
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: fill,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              borderSide: BorderSide(color: cs.primary, width: 1.6),
            ),
            hintText: '0.00',
          ),
        )
      ],
    );
  }

  /// Right field of attached pair (rounded on right side only)
  Widget _buildAttachedRightAmountField(
      TextEditingController controller, String label) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fill = theme.inputDecorationTheme.fillColor ?? cs.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontSize: 14, color: theme.textTheme.bodyMedium?.color)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
          ],
          validator: (v) {
            if (v == null || v.trim().isEmpty) return null;
            final parsed = double.tryParse(v);
            if (parsed == null) return 'Invalid number';
            if (parsed < 0) return 'Cannot be negative';
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: fill,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              borderSide: BorderSide(color: cs.primary, width: 1.6),
            ),
            hintText: '0.00',
          ),
        )
      ],
    );
  }
}

class _ApproverRow {
  final String id;
  String name;
  String role;

  _ApproverRow({required this.id, required this.name, required this.role});
}
