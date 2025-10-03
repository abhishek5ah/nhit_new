import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/form_widget.dart';

final List<FormFieldConfig> addUserFields = [
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
    label: 'Employee Id',
    type: FormFieldType.text,
    name: 'employeeId',
    validator: (value) {
      if (value == null || value.isEmpty) return 'Employee Id is required';
      return null;
    },
  ),
  FormFieldConfig(
    label: 'Contact Number',
    type: FormFieldType.text,
    name: 'contactNumber',
    validator: (value) {
      if (value == null || value.isEmpty) return 'Contact Number is required';
      return null;
    },
  ),
  FormFieldConfig(
    label: 'Username',
    type: FormFieldType.text,
    name: 'username',
    validator: (value) {
      if (value == null || value.isEmpty) return 'Username is required';
      return null;
    },
  ),
  FormFieldConfig(
    label: 'Active',
    type: FormFieldType.dropdown,
    name: 'active',
    options: ['Active', 'Inactive'],
    validator: (value) {
      if (value == null || value.isEmpty) return 'Please select active status';
      return null;
    },
  ),
  FormFieldConfig(
    label: 'Email Address',
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
    label: 'Designation',
    type: FormFieldType.dropdown,
    name: 'designation',
    options: ['Manager', 'Developer'],
    validator: (value) {
      if (value == null || value.isEmpty) return 'Please select a designation';
      return null;
    },
  ),
  FormFieldConfig(
    label: 'Department',
    type: FormFieldType.dropdown,
    name: 'department',
    options: ['Operations', 'HR & Admin'],
    validator: (value) {
      if (value == null || value.isEmpty) return 'Please select a department';
      return null;
    },
  ),
  FormFieldConfig(
    label: 'Password',
    type: FormFieldType.password,
    name: 'password',
    validator: (value) {
      if (value == null || value.isEmpty) return 'Password is required';
      if (value.length < 6) return 'Password must be at least 6 characters';
      return null;
    },
  ),
  FormFieldConfig(
    label: 'Confirm Password',
    type: FormFieldType.password,
    name: 'confirmPassword',
    validator: (value) {
      if (value == null || value.isEmpty) return 'Confirm Password is required';
      return null;
    },
  ),
  FormFieldConfig(
    label: 'Roles',
    type: FormFieldType.text,
    name: 'roles',
    validator: (value) {},
  ),
  FormFieldConfig(
    label: 'Add Your Signature',
    type: FormFieldType.file,
    name: 'signature',
    validator: (value) {
      if (value == null) return 'Please upload your signature';
      return null;
    },
  ),

  FormFieldConfig(
    label: 'Name of Account holder',
    type: FormFieldType.text,
    name: 'accountHolder',
    validator: (value) {},
  ),
  FormFieldConfig(
    label: 'Bank Name',
    type: FormFieldType.text,
    name: 'bankName',
    validator: (value) {},
  ),
  FormFieldConfig(
    label: 'Bank Account',
    type: FormFieldType.text,
    name: 'bankAccount',
    validator: (value) {},
  ),
  FormFieldConfig(
    label: 'IFSC',
    type: FormFieldType.text,
    name: 'ifsc',
    validator: (value) {},
  ),
];

class AddUserPage extends StatelessWidget {
  const AddUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ReusableForm(
          title: 'Add User',
          fields: addUserFields,
          onSubmit: (values) {
            // Show success  notification at bottom
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('User saved successfully'),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating, //notification floating style
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
