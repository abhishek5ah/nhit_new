import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/form_widget.dart';

final List<FormFieldConfig> addExpenseFields = [
  FormFieldConfig(
    label: 'Approval For',
    type: FormFieldType.dropdown,
    name: 'approvalFor',
    options: ['Invoice', 'Purchase Order', 'Other'],
    validator: (value) =>
    value == null || value.isEmpty ? 'Approval type required' : null,
  ),
  FormFieldConfig(
    label: 'User Department',
    type: FormFieldType.dropdown,
    name: 'userDepartment',
    options: ['Operations', 'Finance', 'HR', 'Engineering'],
    validator: (value) =>
    value == null || value.isEmpty ? 'Department required' : null,
  ),
  FormFieldConfig(
    label: 'Work/Purchase Order Date',
    type: FormFieldType.date,
    name: 'workPoDate',
    validator: (value) =>
    value == null || value.isEmpty ? 'Date required' : null,
  ),
  FormFieldConfig(
    label: 'Project Name',
    type: FormFieldType.dropdown,
    name: 'projectName',
    options: ['Corporate Office Delhi', 'Kothakota Bypass', 'Other'],
    validator: (value) =>
    value == null || value.isEmpty ? 'Project name required' : null,
  ),
  FormFieldConfig(
    label: 'Work/Purchase Order No.',
    type: FormFieldType.text,
    name: 'workPoNo',
    validator: (value) =>
    value == null || value.isEmpty ? 'PO number required' : null,
  ),
  FormFieldConfig(
    label: 'Name of Supplier',
    type: FormFieldType.dropdown,
    name: 'supplierName',
    options: [
      'National Highways Invit Project Managers',
      'Surya Cartridge Solution',
      'Other'
    ],
    validator: (value) =>
    value == null || value.isEmpty ? 'Supplier required' : null,
  ),
  FormFieldConfig(
    label: 'Amount of Work/Purchase Order Base Value',
    type: FormFieldType.text,
    name: 'orderBaseValue',
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'Other Charges',
    type: FormFieldType.text,
    name: 'orderOtherCharges',
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'GST on Above',
    type: FormFieldType.text,
    name: 'orderGST',
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'Total Amount',
    type: FormFieldType.text,
    name: 'totalAmount',
    validator: (value) => null,
    readOnly: true,
  ),
  FormFieldConfig(
    label: 'MSME Classification',
    type: FormFieldType.dropdown,
    name: 'msmeClassification',
    options: ['N/A', 'MSE', 'Other'],
    validator: (value) => null,
    readOnly: true,
  ),
  FormFieldConfig(
    label: 'Activity Type',
    type: FormFieldType.dropdown,
    name: 'activityType',
    options: ['N/A', 'Construction', 'Consultancy', 'Other'],
    validator: (value) => null,
    readOnly: true,
  ),
  FormFieldConfig(
    label: 'Protest Note Raised',
    type: FormFieldType.dropdown,
    name: 'protestNote',
    options: ['Yes', 'No', 'Select'],
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'Brief of Goods / Services',
    type: FormFieldType.text,
    name: 'goodsBrief',
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'Invoice Date',
    type: FormFieldType.date,
    name: 'invoiceDate',
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'Invoice Number',
    type: FormFieldType.text,
    name: 'invoiceNumber',
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'Taxable Value',
    type: FormFieldType.text,
    name: 'taxableValue',
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'Add: GST on above',
    type: FormFieldType.text,
    name: 'addedGST',
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'Invoice Other Charges',
    type: FormFieldType.text,
    name: 'invoiceOtherCharges',
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'Invoice Value',
    type: FormFieldType.text,
    name: 'invoiceValue',
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'Appointed date/Date for start of work',
    type: FormFieldType.date,
    name: 'appointedDate',
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'Contract Period Start Date',
    type: FormFieldType.date,
    name: 'contractStartDate',
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'Contract Period End Date',
    type: FormFieldType.date,
    name: 'contractEndDate',
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'Period of Supply of services/goods Invoiced Start Date',
    type: FormFieldType.date,
    name: 'supplyStartDate',
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'Period of Supply of services/goods Invoiced End Date',
    type: FormFieldType.date,
    name: 'supplyEndDate',
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'Extension of contract period executed',
    type: FormFieldType.dropdown,
    name: 'contractExtension',
    options: ['Yes', 'No', 'Select'],
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'Budget Expenditure',
    type: FormFieldType.text,
    name: 'budgetExpenditure',
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'Actual Expenditure',
    type: FormFieldType.text,
    name: 'actualExpenditure',
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'Expenditure over budget',
    type: FormFieldType.text,
    name: 'expenditureOverBudget',
    validator: (value) => null,
    readOnly: true,
  ),
  FormFieldConfig(
    label: 'Delayed damages',
    type: FormFieldType.text,
    name: 'delayedDamages',
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'Nature of Expenses',
    type: FormFieldType.dropdown,
    name: 'natureOfExpenses',
    options: ['Construction', 'Consultancy', 'Legal', 'Other'],
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'Milestone Status - Achieved?',
    type: FormFieldType.dropdown,
    name: 'milestoneAchieved',
    options: ['Yes', 'No'],
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'Expense Amount within contract',
    type: FormFieldType.dropdown,
    name: 'expenseWithinContract',
    options: ['Yes', 'No'],
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'If payment approved with Deviation',
    type: FormFieldType.dropdown,
    name: 'paymentWithDeviation',
    options: ['Yes', 'No'],
    validator: (value) => null,
  ),
  FormFieldConfig(
    label: 'Attach File',
    type: FormFieldType.file,
    name: 'attachment',
    validator: (value) => null,
  ),
];


class CreateExpense extends StatelessWidget {
  const CreateExpense({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 12,right: 12),
        // inner padding inside border radius
        child: ReusableForm(
          title: 'Create Green Note',
          fields: addExpenseFields,
          onSubmit: (values) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Expense saved successfully'),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Theme
                    .of(context)
                    .colorScheme
                    .primary,
              ),
            );
          },
          submitButtonBuilder: (onPressed) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PrimaryButton(label: 'Save Draft', onPressed: onPressed),
                const SizedBox(width: 20),
                PrimaryButton(label: 'Submit', onPressed: onPressed),
              ],
            );
          },
        ),
      ),
    );
  }
}
