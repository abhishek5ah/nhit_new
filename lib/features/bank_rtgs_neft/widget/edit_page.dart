import 'package:flutter/material.dart';
import 'package:ppv_components/features/bank_rtgs_neft/models/bank_models/bank_rtgs_neft_model.dart';


class EditRtgsFormPage extends StatefulWidget {
  final BankRtgsNeft record;
  final Function(BankRtgsNeft) onSave;

  const EditRtgsFormPage({
    super.key,
    required this.record,
    required this.onSave,
  });

  static Future<void> show(
      BuildContext context, BankRtgsNeft record, Function(BankRtgsNeft) onSave) async {
    await showGeneralDialog(
      context: context,
      barrierLabel: "Edit RTGS / NEFT",
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) =>
          Center(child: EditRtgsFormPage(record: record, onSave: onSave)),
      transitionBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<EditRtgsFormPage> createState() => _EditRtgsFormPageState();
}

class _EditRtgsFormPageState extends State<EditRtgsFormPage> {
  late TextEditingController _vendorController;
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late String _status;

  @override
  void initState() {
    super.initState();
    _vendorController = TextEditingController(text: widget.record.vendorName);
    _amountController = TextEditingController(text: widget.record.amount);
    _dateController = TextEditingController(text: widget.record.date);
    _status = widget.record.status;
  }

  @override
  void dispose() {
    _vendorController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _saveData() {
    final updated = BankRtgsNeft(
      id: widget.record.id,
      slNo: widget.record.slNo,
      vendorName: _vendorController.text,
      amount: _amountController.text,
      date: _dateController.text,
      status: _status,
    );

    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toIso8601String().split("T").first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: size.width * 0.5,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outline, width: 1),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Edit RTGS / NEFT Record",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            /// Vendor Name
            _buildInputCard(
              context,
              icon: Icons.person,
              label: "Vendor Name",
              child: TextField(
                controller: _vendorController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),

            /// Amount
            _buildInputCard(
              context,
              icon: Icons.attach_money,
              label: "Amount",
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),

            /// Date
            _buildInputCard(
              context,
              icon: Icons.calendar_today,
              label: "Date",
              child: TextField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.date_range),
                    onPressed: _pickDate,
                  ),
                ),
              ),
            ),

            /// Status Dropdown
            _buildInputCard(
              context,
              icon: Icons.flag,
              label: "Status",
              child: DropdownButtonFormField<String>(
                value: _status,
                items: ["Draft", "Pending", "Approved", "Rejected"]
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => _status = val ?? "Draft"),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _saveData,
                  icon: const Icon(Icons.save),
                  label: const Text("Save Changes"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// Reusable input card (same look as detail cards in view page)
  Widget _buildInputCard(BuildContext context,
      {required IconData icon,
        required String label,
        required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: colorScheme.primary, size: 22),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
