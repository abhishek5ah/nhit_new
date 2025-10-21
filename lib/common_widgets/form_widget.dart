import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ppv_components/common_widgets/file_picker.dart';

enum FormFieldType { text, password, dropdown, checkbox, file, date }

class FormFieldConfig {
  final String label;
  final FormFieldType type;
  final String name;
  final String? initialValue;
  final List<String>? options;
  final String? Function(dynamic value)? validator; // Optional validator
  final bool readOnly;

  FormFieldConfig({
    required this.label,
    required this.type,
    required this.name,
    this.initialValue,
    this.options,
    this.validator,
    this.readOnly = false,
  });
}

class ReusableForm extends StatefulWidget {
  final String title;
  final List<FormFieldConfig> fields;
  final void Function(Map<String, dynamic> values) onSubmit;

  /// Optional for custom submit button widget
  final Widget Function(VoidCallback onPressed)? submitButtonBuilder;

  const ReusableForm({
    super.key,
    required this.title,
    required this.fields,
    required this.onSubmit,
    this.submitButtonBuilder,
  });

  @override
  State<ReusableForm> createState() => _ReusableFormState();
}

class _ReusableFormState extends State<ReusableForm> {
  late final Map<String, TextEditingController> controllers;
  final Map<String, PlatformFile?> fileInputs = {};
  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>(); // Form Key added

  @override
  void initState() {
    super.initState();
    controllers = {
      for (var field in widget.fields)
        if (field.type == FormFieldType.text ||
            field.type == FormFieldType.password)
          field.name: TextEditingController(text: field.initialValue ?? ''),
    };
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget buildField(FormFieldConfig field) {
    switch (field.type) {
      case FormFieldType.text:
      case FormFieldType.password:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
            controller: controllers[field.name],
            obscureText: field.type == FormFieldType.password,
            decoration: InputDecoration(
              labelText: field.label,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            validator: field.validator,
          ),
        );
      case FormFieldType.dropdown:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: FormField<String>(
            initialValue: field.initialValue ?? (field.options?.first ?? ''),
            validator: (value) =>
            field.validator != null ? field.validator!(value) : null,
            builder: (state) {
              return InputDecorator(
                decoration: InputDecoration(
                  labelText: field.label,
                  border: const OutlineInputBorder(),
                  errorText: state.errorText,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                isEmpty: state.value == null || state.value!.isEmpty,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: state.value,
                    isExpanded: true,
                    items: field.options
                        ?.map(
                          (opt) => DropdownMenuItem<String>(
                        value: opt,
                        child: Text(opt),
                      ),
                    )
                        .toList(),
                    onChanged: (newValue) {
                      state.didChange(newValue);
                    },
                  ),
                ),
              );
            },
          ),
        );
      case FormFieldType.file:
        return FilePickerWidget(
          label: field.label,
          onChanged: (file) => fileInputs[field.name] = file,
        );
      case FormFieldType.checkbox:
        return FormField<bool>(
          initialValue: field.initialValue == 'true',
          validator: (value) => field.validator != null
              ? field.validator!(value == true ? 'true' : 'false')
              : null,
          builder: (state) {
            return CheckboxListTile(
              title: Text(field.label),
              value: state.value,
              onChanged: (bool? val) => state.didChange(val),
              subtitle: state.hasError
                  ? Text(
                state.errorText ?? '',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              )
                  : null,
            );
          },
        );
      case FormFieldType.date:
      // Controller to manage display of the selected date as text
        final controller =
            controllers[field.name] ??
                (controllers[field.name] = TextEditingController(
                  text: field.initialValue ?? '',
                ));
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              labelText: field.label,
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            validator: field.validator,
            onTap: () async {
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate:
                DateTime.tryParse(controller.text) ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (selectedDate != null) {
                controller.text =
                "${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}";
              }
            },
          ),
        );
    }
  }

  void handleSubmit() {
    // Validate form fields using Flutter Form validation
    if (_formKey.currentState?.validate() ?? false) {
      // Collect all values
      final Map<String, dynamic> values = {};
      for (final field in widget.fields) {
        if (controllers.containsKey(field.name)) {
          values[field.name] = controllers[field.name]?.text ?? '';
        } else if (field.type == FormFieldType.file) {
          values[field.name] = fileInputs[field.name];
        }
      }
      widget.onSubmit(values);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        List<List<FormFieldConfig>> fieldRows = [];
        final perRow = isWide ? 2 : 1;
        for (var i = 0; i < widget.fields.length; i += perRow) {
          fieldRows.add(
            widget.fields.sublist(
              i,
              (i + perRow) > widget.fields.length
                  ? widget.fields.length
                  : i + perRow,
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.colorScheme.outline, width: 1),
            ),
            child: Form(
              key: _formKey,
              //  assign key here to enable validation
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...fieldRows.map((row) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < row.length; i++) ...[
                          Expanded(child: buildField(row[i])),
                          if (i == 0 && row.length == 1 && isWide)
                            const SizedBox(width: 24),
                          if (i == 0 && row.length == 2)
                            const SizedBox(width: 24),
                        ],
                      ],
                    );
                  }),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: widget.submitButtonBuilder != null
                        ? widget.submitButtonBuilder!(handleSubmit)
                        : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: handleSubmit,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
