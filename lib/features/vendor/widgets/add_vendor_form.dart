import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/form_widget.dart';

final List<FormFieldConfig> addVendorFields = [
  FormFieldConfig(
    label: 'Code',
    type: FormFieldType.text,
    name: 'code',
    validator: (value) {
      if (value == null || value.isEmpty) return 'Code is required';
      return null;
    },
  ),
  FormFieldConfig(
    label: 'Name',
    type: FormFieldType.text,
    name: 'name',
    validator: (value) {
      if (value == null || value.isEmpty) return 'Name is required';
      return null;
    },
  ),
  FormFieldConfig(
    label: 'Email',
    type: FormFieldType.text,
    name: 'email',
    validator: (value) {
      if (value == null || value.isEmpty) return 'Email is required';
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
        return 'Enter a valid email';
      }
      return null;
    },
  ),
  FormFieldConfig(
    label: 'Mobile',
    type: FormFieldType.text,
    name: 'mobile',
    validator: (value) {
      if (value == null || value.isEmpty) return 'Mobile number is required';
      return null;
    },
  ),
  FormFieldConfig(
    label: 'Beneficiary Name',
    type: FormFieldType.text,
    name: 'beneficiaryName',
    validator: (value) {
      if (value == null || value.isEmpty) return 'Beneficiary Name is required';
      return null;
    },
  ),
  FormFieldConfig(
    label: 'Status',
    type: FormFieldType.dropdown,
    name: 'status',
    options: ['Approved', 'Pending', 'Rejected'],
    validator: (value) {
      if (value == null || value.isEmpty) return 'Please select a status';
      return null;
    },
  ),
];

class AddVendorPage extends StatelessWidget {
  const AddVendorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ReusableForm(
          title: 'Add Vendor',
          fields: addVendorFields,
          onSubmit: (values) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Vendor saved successfully'),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Theme.of(context).colorScheme.primary,

              ),
            );
          },
          submitButtonBuilder: (onPressed) =>
              PrimaryButton(label: 'Save', onPressed: onPressed),
        ),
      ),
    );
  }
}
