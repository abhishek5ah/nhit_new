import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/form_widget.dart';
import 'package:ppv_components/features/department/providers/department_provider.dart';

final List<FormFieldConfig> addDepartmentFields = [
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
    label: 'Description',
    type: FormFieldType.text,
    name: 'description',
    validator: (value) {
      if (value == null || value.isEmpty) return 'Description is required';
      return null;
    },
  ),
];

class AddDepartmentPage extends StatelessWidget {
  final VoidCallback? onDepartmentAdded;
  
  const AddDepartmentPage({super.key, this.onDepartmentAdded});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ReusableForm(
          title: 'Add Department',
          fields: addDepartmentFields,
          onSubmit: (values) async {
            final provider = context.read<DepartmentProvider>();
            
            final result = await provider.createDepartment(
              name: values['name'] ?? '',
              description: values['description'] ?? '',
            );
            
            if (context.mounted) {
              if (result.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.message ?? 'Department created successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                onDepartmentAdded?.call();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.message ?? 'Failed to create department'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          submitButtonBuilder: (onPressed) =>
              PrimaryButton(label: 'Save', onPressed: onPressed),
        ),
      ),
    );
  }
}
