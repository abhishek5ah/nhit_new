import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keep your custom button classes if you have them; otherwise the simple ElevatedButton below is used.
class _CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _CustomButton({required this.label, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class ApprovalRulesForm extends StatefulWidget {
  const ApprovalRulesForm({super.key});

  @override
  State<ApprovalRulesForm> createState() => _ApprovalRulesFormState();
}

class _ApprovalRulesFormState extends State<ApprovalRulesForm> {
  final _formKey = GlobalKey<FormState>();

  // Dropdown selections
  String? selectedDepartment;
  String? selectedProject;
  String? selectedApprover1;
  String? selectedHRAdmin;
  String? selectedQS;
  String? selectedApprover2;
  String? selectedApprover3;
  String? selectedApprover4;
  String? selectedApprover5;
  String? selectedConcurrentAuditor;

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final Map<String, TextEditingController> amountControllers = {
    "approver1": TextEditingController(),
    "hrAdmin": TextEditingController(),
    "qs": TextEditingController(),
    "approver2": TextEditingController(),
    "approver3": TextEditingController(),
    "approver4": TextEditingController(),
    "approver5": TextEditingController(),
    "concurrentAuditor": TextEditingController(),
  };

  // Dummy Data
  final List<String> dummyUsers = ["John Doe", "Alice", "Bob", "Charlie", "David"];
  final List<String> dummyDepartments = ["Operations", "Finance", "HR", "IT"];
  final List<String> dummyProjects = ["Project A", "Project B", "Project C"];

  @override
  void dispose() {
    nameController.dispose();
    for (final c in amountControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// --- Responsive Layout ---
  Widget _buildResponsiveLayout(bool isMobile, List<Widget> children) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.map((e) => Padding(padding: const EdgeInsets.only(bottom: 14), child: e)).toList(),
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .map((e) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: e)))
            .toList(),
      );
    }
  }

  Widget _buildTextWidget(String label, TextEditingController controller, String? Function(String?) validator) {
    final colors = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      validator: validator,
      style: TextStyle(fontSize: 14, color: colors.onSurface),
      decoration: _inputDecoration(label, context),
    );
  }

  Widget _buildDropdownWidget(String label, String? value, List<String> items, void Function(String?) onChanged) {
    final colors = Theme.of(context).colorScheme;
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      validator: (val) => val == null || val.isEmpty ? 'Select option' : null,
      decoration: _inputDecoration(label, context),
      items: items.map((e) => DropdownMenuItem<String>(value: e, child: Text(e, style: TextStyle(fontSize: 14, color: colors.onSurface)))).toList(),
    );
  }

  Widget _buildNumberWidget(String label, TextEditingController controller) {
    final colors = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 14, color: colors.onSurface),
      decoration: _inputDecoration(label, context),
    );
  }

  InputDecoration _inputDecoration(String label, BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colors.outline)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colors.outline)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colors.primary)),
      isDense: true,
    );
  }

  String? _requiredValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 900;

      return Container(
        width: double.infinity,
        child: Card(
          elevation: 3,
          color: colors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Create Approval Rules",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface)),
                const SizedBox(height: 18),

                _buildResponsiveLayout(isMobile, [
                  _buildTextWidget("Name", nameController, _requiredValidator),
                  _buildDropdownWidget("Project Name", selectedProject, dummyProjects, (val) => setState(() => selectedProject = val)),
                ]),
                const SizedBox(height: 20),

                _buildResponsiveLayout(isMobile, [
                  _buildDropdownWidget("User Department", selectedDepartment, dummyDepartments, (val) => setState(() => selectedDepartment = val)),
                  _buildDropdownWidget("Select Approver 1", selectedApprover1, dummyUsers, (val) => setState(() => selectedApprover1 = val)),
                  _buildNumberWidget("Amount", amountControllers["approver1"]!),
                ]),
                const SizedBox(height: 20),

                _buildResponsiveLayout(isMobile, [
                  _buildDropdownWidget("HR & Admin (Only for Operations)", selectedHRAdmin, dummyUsers, (val) => setState(() => selectedHRAdmin = val)),
                  _buildNumberWidget("Amount", amountControllers["hrAdmin"]!),
                  _buildDropdownWidget("QS (Only for Operations)", selectedQS, dummyUsers, (val) => setState(() => selectedQS = val)),
                  _buildNumberWidget("Amount", amountControllers["qs"]!),
                ]),
                const SizedBox(height: 20),

                _buildResponsiveLayout(isMobile, [
                  _buildDropdownWidget("Approver 2 (Invoice > 1,00,000)", selectedApprover2, dummyUsers, (val) => setState(() => selectedApprover2 = val)),
                  _buildNumberWidget("Amount", amountControllers["approver2"]!),
                  _buildDropdownWidget("Approver 3 (Invoice > 2,50,000)", selectedApprover3, dummyUsers, (val) => setState(() => selectedApprover3 = val)),
                  _buildNumberWidget("Amount", amountControllers["approver3"]!),
                ]),
                const SizedBox(height: 20),

                _buildResponsiveLayout(isMobile, [
                  _buildDropdownWidget("Concurrent Auditor (Invoice > 25,00,000)", selectedConcurrentAuditor, dummyUsers,
                          (val) => setState(() => selectedConcurrentAuditor = val)),
                  _buildNumberWidget("Amount", amountControllers["concurrentAuditor"]!),
                  _buildDropdownWidget("Approver 4 (Invoice > 25,00,000)", selectedApprover4, dummyUsers, (val) => setState(() => selectedApprover4 = val)),
                  _buildNumberWidget("Amount", amountControllers["approver4"]!),
                ]),
                const SizedBox(height: 20),

                _buildResponsiveLayout(isMobile, [
                  _buildDropdownWidget("Approver 5 (Invoice > 50,00,000)", selectedApprover5, dummyUsers, (val) => setState(() => selectedApprover5 = val)),
                  _buildNumberWidget("Amount", amountControllers["approver5"]!),
                ]),
                const SizedBox(height: 30),

                Center(
                  child: _CustomButton(
                    label: "Submit",
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Form Submitted Successfully'), backgroundColor: colors.primary));
                      }
                    },
                  ),
                ),
              ]),
            ),
          ),
        ),
      );
    });
  }
}
