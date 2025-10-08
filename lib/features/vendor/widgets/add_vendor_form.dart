import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/form_widget.dart';

final List<FormFieldConfig> addVendorFields = [
  FormFieldConfig(
    label: 'From Account Type',
    name: 'fromAccountType',
    type: FormFieldType.dropdown,
    options: ['Internal', 'External'],
  ),
  FormFieldConfig(
    label: 'Project',
    name: 'project',
    type: FormFieldType.dropdown,
    options: ['Select Project', 'New Project', 'Old Project','Pending Project'],
  ),
  FormFieldConfig(
    label: 'Status',
    name: 'status',
    type: FormFieldType.dropdown,
    options: ['Active', 'Inactive'],
  ),
  FormFieldConfig(label: 'Vendor Name', name: 'name', type: FormFieldType.text),
  FormFieldConfig(label: 'Vendor Code', name: 'code', type: FormFieldType.text),
  FormFieldConfig(
    label: 'Vendor Email',
    name: 'email',
    type: FormFieldType.text,
  ),
  FormFieldConfig(
    label: 'Vendor Mobile',
    name: 'mobile',
    type: FormFieldType.text,
  ),
  FormFieldConfig(
    label: 'Country Name',
    name: 'countryName',
    type: FormFieldType.text,
  ),
  FormFieldConfig(
    label: 'State Name',
    name: 'stateName',
    type: FormFieldType.text,
  ),
  FormFieldConfig(label: 'PIN Code', name: 'pinCode', type: FormFieldType.text),
  FormFieldConfig(
    label: 'Account Number',
    name: 'accountNumber',
    type: FormFieldType.text,
  ),
  FormFieldConfig(label: 'IFSC', name: 'ifsc', type: FormFieldType.text),
  FormFieldConfig(
    label: 'Name of Bank',
    name: 'bankName',
    type: FormFieldType.text,
  ),
  FormFieldConfig(
    label: 'Beneficiary Name',
    name: 'beneficiaryName',
    type: FormFieldType.text,
  ),

  FormFieldConfig(label: 'PAN', name: 'pan', type: FormFieldType.text),
  FormFieldConfig(label: 'GSTIN', name: 'gstin', type: FormFieldType.text),
  FormFieldConfig(
    label: 'MSME Classification',
    name: 'msmeClassification',
    type: FormFieldType.dropdown,
    options: ['Micro', 'Small', 'Medium'],
  ),
  FormFieldConfig(
    label: 'Activity Type',
    name: 'activityType',
    type: FormFieldType.dropdown,
    options: ['N/A'],
  ),
  FormFieldConfig(
    label: 'MSME Start Date',
    name: 'msmeStartDate',
    type: FormFieldType.date,
  ),
  FormFieldConfig(
    label: 'Section 206AB Verified',
    name: 'section206AB',
    type: FormFieldType.text,
  ),
  FormFieldConfig(
    label: 'Remarks Address',
    name: 'accountName',
    type: FormFieldType.text,
  ),
  FormFieldConfig(
    label: 'Account Name',
    name: 'accountName',
    type: FormFieldType.text,
  ),
  FormFieldConfig(
    label: 'Short Name',
    name: 'shortName',
    type: FormFieldType.text,
  ),
  FormFieldConfig(label: 'Parent', name: 'parent', type: FormFieldType.text),
  FormFieldConfig(
    label: 'City Name',
    name: 'cityName',
    type: FormFieldType.text,
  ),
  FormFieldConfig(
    label: 'MSME Registration Number',
    name: 'msmeRegNumber',
    type: FormFieldType.text,
  ),
  FormFieldConfig(
    label: 'MSME End Date',
    name: 'msmeEndDate',
    type: FormFieldType.date,
  ),


  FormFieldConfig(
    label: 'Material Nature',
    name: 'materialNature',
    type: FormFieldType.text,
  ),
  FormFieldConfig(
    label: 'Gst Defaulted',
    name: 'gstDefaulted',
    type: FormFieldType.text,
  ),
  FormFieldConfig(
    label: 'Common Bank Details',
    name: 'commonBankDetails',
    type: FormFieldType.text,
  ),
  FormFieldConfig(
    label: 'Income Tax Type',
    name: 'incomeTaxType',
    type: FormFieldType.text,
  ),
  FormFieldConfig(
    label: 'Attach File',
    name: 'attachFile',
    type: FormFieldType.file,
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
