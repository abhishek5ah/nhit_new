import 'package:flutter/material.dart';
import 'package:ppv_components/features/bank_rtgs_neft/models/bank_models/bank_rtgs_neft_model.dart';


class AddRtgsFormPage extends StatefulWidget {
  const AddRtgsFormPage({super.key});

  static Future<BankRtgsNeft?> show(BuildContext context) async {
    return await showGeneralDialog<BankRtgsNeft>(
      context: context,
      barrierLabel: "Add RTGS / NEFT",
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => const Center(child: AddRtgsFormPage()),
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
  State<AddRtgsFormPage> createState() => _AddRtgsFormPageState();
}

class _AddRtgsFormPageState extends State<AddRtgsFormPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController slNoController = TextEditingController();
  final TextEditingController vendorController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  String status = "Draft";

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newRecord = BankRtgsNeft(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        slNo: slNoController.text,
        vendorName: vendorController.text,
        amount: amountController.text,
        date: dateController.text,
        status: status,
      );
      Navigator.of(context).pop(newRecord); // return new record
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: size.width * 0.35,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Add RTGS / NEFT",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /// Fields
              _buildTextField("SL No.", slNoController),
              const SizedBox(height: 16),
              _buildTextField("Vendor Name", vendorController),
              const SizedBox(height: 16),
              _buildTextField("Amount", amountController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField("Date", dateController,
                  keyboardType: TextInputType.datetime),
              const SizedBox(height: 16),

              /// Status Dropdown
              DropdownButtonFormField<String>(
                // initialValue: status,
                items: ["Draft", "Approved", "Rejected"]
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => status = val ?? "Draft"),
                decoration: InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              /// Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                    ),
                    child: const Text("Add Record"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) =>
      value == null || value.isEmpty ? "$label is required" : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
