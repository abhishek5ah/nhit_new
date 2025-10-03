import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/form_widget.dart';

final List<FormFieldConfig> addRoleFields = [
  FormFieldConfig(
    label: 'Role Name',
    type: FormFieldType.text,
    name: 'roleName',
    validator: (value) {
      if (value == null || value.isEmpty) return 'Role Name is required';
      return null;
    },
  ),
  FormFieldConfig(
    label: 'Permissions (comma separated)',
    type: FormFieldType.text,
    name: 'permissions',
    validator: (value) {
      if (value == null || value.isEmpty) return 'Permissions are required';
      return null;
    },
  ),
];

class AddRolePage extends StatelessWidget {
  const AddRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ReusableForm(
          title: 'Add Role',
          fields: addRoleFields,
          onSubmit: (values) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Role saved successfully'),
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
