import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/form_widget.dart';

final List<FormFieldConfig> addDesignationFields = [
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

class AddDesignationPage extends StatelessWidget {
  const AddDesignationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReusableForm(
        title: 'Add Designation',
        fields: addDesignationFields,
        onSubmit: (values) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Designation saved successfully'),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.primary,

            ),
          );
        },
        submitButtonBuilder: (onPressed) =>
            PrimaryButton(label: 'Save', onPressed: onPressed),
      ),
    );
  }
}
