import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReimbursementForm extends StatefulWidget {
  const ReimbursementForm({super.key});
  @override
  ReimbursementFormState createState() => ReimbursementFormState();
}

class ReimbursementFormState extends State<ReimbursementForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedFile;
  String? _selectedFilePath;
  List<Map<String, dynamic>> expenseRows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    await _loadExpenseRows();
    setState(() => _loading = false);
  }

  Future<void> _loadExpenseRows() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString("expenseRows");
    if (savedData != null) {
      expenseRows = List<Map<String, dynamic>>.from(json.decode(savedData));
    } else {
      expenseRows = List.generate(5, (_) => {
        "expenseType": "",
        "billDate": "",
        "billNumber": "",
        "vendorName": "",
        "billAmount": "",
        "supporting": "Yes",
        "remarks": "",
      });
    }
  }

  Future<void> _saveExpenseRows() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("expenseRows", json.encode(expenseRows));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final tableWidth = math.max(screenWidth, 1200.0);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorScheme.outline, width: 0.5),
    );

    return Container(
      color: colorScheme.surface,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme, colorScheme),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  _buildSectionCard(
                    context: context,
                    icon: Icons.flight_takeoff,
                    title: 'Travel & Request Details',
                    description: 'Provide employee and trip information for this reimbursement request.',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildTextField(context, "Note No", Icons.note, border: borderStyle)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildDropdown(context, "Project Name", Icons.work, ["Project A", "Project B"], border: borderStyle)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(context, "User Department", Icons.apartment, border: borderStyle)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(context, "Employee Name", Icons.person, border: borderStyle)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(context, "Employee ID", Icons.badge, border: borderStyle)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(context, "Employee Designation", Icons.engineering, border: borderStyle)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildDatePicker(context, "Date of Travel/Expenses", Icons.calendar_today, border: borderStyle)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(context, "Mode of Travel", Icons.directions_car, border: borderStyle)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(context, "Travel Mode Eligibility", Icons.verified, border: borderStyle)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildDropdown(context, "Initial Approver's Name", Icons.supervisor_account, ["Manager", "HR"], border: borderStyle)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(context, "Purpose of Travel", Icons.notes, maxLines: 2, border: borderStyle),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    context: context,
                    icon: Icons.table_chart,
                    title: 'Expense Details',
                    description: 'Itemize all reimbursable expenses and attach the necessary proofs.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: tableWidth,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: const [
                                      Expanded(flex: 2, child: Text("Expense Type", style: TextStyle(fontWeight: FontWeight.bold))),
                                      Expanded(flex: 2, child: Text("Bill Date", style: TextStyle(fontWeight: FontWeight.bold))),
                                      Expanded(flex: 2, child: Text("Bill Number", style: TextStyle(fontWeight: FontWeight.bold))),
                                      Expanded(flex: 3, child: Text("Vendor Name", style: TextStyle(fontWeight: FontWeight.bold))),
                                      Expanded(flex: 2, child: Text("Bill Amount", style: TextStyle(fontWeight: FontWeight.bold))),
                                      Expanded(flex: 3, child: Text("Supporting Available", style: TextStyle(fontWeight: FontWeight.bold))),
                                      Expanded(flex: 3, child: Text("Remarks (if any)", style: TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: List.generate(expenseRows.length, (index) => _buildExpenseRow(context, index, borderStyle)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            PrimaryButton(
                              label: "Add Row",
                              icon: Icons.add,
                              onPressed: () {
                                setState(() {
                                  expenseRows.add({
                                    "expenseType": "",
                                    "billDate": "",
                                    "billNumber": "",
                                    "vendorName": "",
                                    "billAmount": "",
                                    "supporting": "Yes",
                                    "remarks": "",
                                  });
                                  _saveExpenseRows();
                                });
                              },
                            ),
                            const SizedBox(width: 12),
                            SecondaryButton(
                              label: "Delete Row",
                              icon: Icons.delete,
                              backgroundColor: colorScheme.error,
                              onPressed: () {
                                if (expenseRows.isNotEmpty) {
                                  setState(() {
                                    expenseRows.removeLast();
                                    _saveExpenseRows();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    context: context,
                    icon: Icons.account_balance_wallet,
                    title: 'Payment Details',
                    description: 'Enter the settlement details for reimbursing the employee.',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildTextField(context, "Total Payable Amount", Icons.account_balance_wallet, keyboardType: TextInputType.number, border: borderStyle)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(context, "Advance Adjusted (if Any)", Icons.money_off, keyboardType: TextInputType.number, border: borderStyle)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(context, "Net Payable Amount", Icons.payments, keyboardType: TextInputType.number, border: borderStyle)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(context, "Name of Account Holder", Icons.person, border: borderStyle)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(context, "Bank Name", Icons.account_balance, border: borderStyle)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(context, "Bank Account", Icons.account_balance_wallet, border: borderStyle)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(context, "IFSC", Icons.confirmation_number, border: borderStyle)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildFileUpload(context, "Attach File", border: borderStyle)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SecondaryButton(
                        label: "Cancel",
                        icon: Icons.close,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 12),
                      PrimaryButton(
                        label: "Submit",
                        icon: Icons.send,
                        onPressed: () {
                          if (_formKey.currentState!.validate() && _selectedFilePath != null) {
                            _saveExpenseRows();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Form Submitted ✅")),
                            );
                          } else if (_selectedFilePath == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please attach a file ❌")),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withAlpha(128), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha(38),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.receipt_long, color: colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Reimbursement Request',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Submit employee travel expenses and supporting documents for review.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              ],
            ),
          ),
          SecondaryButton(
            label: 'Back to Dashboard',
            icon: Icons.arrow_back,
            onPressed: () => context.go('/dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? description,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withAlpha(128), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String label, IconData icon,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text, OutlineInputBorder? border}) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: cs.onSurfaceVariant),
          labelText: label,
          filled: true,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? cs.surfaceContainer,
          border: border ?? OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: border,
          focusedBorder: border,
          errorBorder: border,
          focusedErrorBorder: border,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter $label";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, String label, IconData icon, List<String> items,
      {OutlineInputBorder? border}) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: cs.onSurfaceVariant),
          labelText: label,
          filled: true,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? cs.surfaceContainer,
          border: border ?? OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: border,
          focusedBorder: border,
          errorBorder: border,
          focusedErrorBorder: border,
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (value) {
          // Handle value change if needed
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please select $label";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, IconData icon, {OutlineInputBorder? border}) {
    final cs = Theme.of(context).colorScheme;
    TextEditingController controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: cs.onSurfaceVariant),
          labelText: label,
          filled: true,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? cs.surfaceContainer,
          border: border ?? OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: border,
          focusedBorder: border,
          errorBorder: border,
          focusedErrorBorder: border,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please pick $label";
          }
          return null;
        },
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            initialDate: DateTime.now(),
          );
          if (pickedDate != null) {
            controller.text = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
          }
        },
      ),
    );
  }

  Widget _buildExpenseRow(BuildContext context, int index, OutlineInputBorder border) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 2,
              child: _miniTextField(context, "Expense Type",
                  initialValue: expenseRows[index]["expenseType"],
                  onChanged: (val) {
                    expenseRows[index]["expenseType"] = val;
                    _saveExpenseRows();
                  },
                  border: border)),
          SizedBox(width: 8),
          Expanded(flex: 2, child: _miniDatePicker(context, "Bill Date", index, border: border)),
          SizedBox(width: 8),
          Expanded(
              flex: 2,
              child: _miniTextField(context, "Bill Number",
                  initialValue: expenseRows[index]["billNumber"],
                  onChanged: (val) {
                    expenseRows[index]["billNumber"] = val;
                    _saveExpenseRows();
                  },
                  border: border)),
          SizedBox(width: 8),
          Expanded(
              flex: 3,
              child: _miniTextField(context, "Vendor Name",
                  initialValue: expenseRows[index]["vendorName"],
                  onChanged: (val) {
                    expenseRows[index]["vendorName"] = val;
                    _saveExpenseRows();
                  },
                  border: border)),
          SizedBox(width: 8),
          Expanded(
              flex: 2,
              child: _miniTextField(context, "Bill Amount",
                  keyboardType: TextInputType.number,
                  initialValue: expenseRows[index]["billAmount"],
                  onChanged: (val) {
                    expenseRows[index]["billAmount"] = val;
                    _saveExpenseRows();
                  },
                  border: border)),
          SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              value: expenseRows[index]["supporting"],
              decoration: InputDecoration(
                border: border,
                enabledBorder: border,
                focusedBorder: border,
                errorBorder: border,
                focusedErrorBorder: border,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).colorScheme.surfaceContainer,
                filled: true,
              ),
              items: ["Yes", "No"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) {
                setState(() {
                  expenseRows[index]["supporting"] = val;
                  _saveExpenseRows();
                });
              },
            ),
          ),
          SizedBox(width: 8),
          Expanded(
              flex: 3,
              child: _miniTextField(context, "Remarks",
                  initialValue: expenseRows[index]["remarks"],
                  onChanged: (val) {
                    expenseRows[index]["remarks"] = val;
                    _saveExpenseRows();
                  },
                  border: border)),
        ],
      ),
    );
  }

  Widget _miniTextField(BuildContext context, String hint,
      {int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
        String? initialValue,
        Function(String)? onChanged,
        OutlineInputBorder? border}) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      maxLines: maxLines,
      initialValue: initialValue,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        border: border ?? OutlineInputBorder(),
        enabledBorder: border,
        focusedBorder: border,
        errorBorder: border,
        focusedErrorBorder: border,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? cs.surfaceContainer,
        filled: true,
      ),
    );
  }

  Widget _miniDatePicker(BuildContext context, String hint, int index, {OutlineInputBorder? border}) {
    final cs = Theme.of(context).colorScheme;
    TextEditingController controller = TextEditingController(text: expenseRows[index]["billDate"]);
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        hintText: hint,
        border: border ?? OutlineInputBorder(),
        enabledBorder: border,
        focusedBorder: border,
        errorBorder: border,
        focusedErrorBorder: border,
        suffixIcon: Icon(Icons.calendar_today, size: 18, color: cs.onSurfaceVariant),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? cs.surfaceContainer,
        filled: true,
      ),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          String formatted = "${picked.day}-${picked.month}-${picked.year}";
          setState(() {
            expenseRows[index]["billDate"] = formatted;
            controller.text = formatted;
            _saveExpenseRows();
          });
        }
      },
    );
  }

  Widget _buildFileUpload(BuildContext context, String label, {OutlineInputBorder? border}) {
    final cs = Theme.of(context).colorScheme;
    final fill = Theme.of(context).inputDecorationTheme.fillColor ?? cs.surfaceContainerLow;
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.attach_file, color: cs.primary),
          SizedBox(width: 10),
          PrimaryButton(
            label: "Choose File",
            icon: Icons.upload_file,
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                allowMultiple: false,
                type: FileType.any,
              );
              if (result != null && result.files.isNotEmpty) {
                setState(() {
                  _selectedFile = result.files.single.name;
                  _selectedFilePath = result.files.single.path;
                });
              }
            },
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 36,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: _selectedFilePath == null
                  ? Text(
                "No file chosen",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: cs.onSurface.withAlpha(165)),
              )
                  : GestureDetector(
                onTap: () => OpenFilex.open(_selectedFilePath!),
                child: Text(
                  _selectedFile!,
                  overflow: TextOverflow.ellipsis,
                  style:
                  TextStyle(color: cs.primary, decoration: TextDecoration.underline),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
