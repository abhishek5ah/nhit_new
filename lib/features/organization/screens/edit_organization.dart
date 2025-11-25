import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:ppv_components/features/organization/model/organization_model.dart';
import 'package:ppv_components/features/organization/data/models/organization_api_models.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/outlined_button.dart';
import 'package:ppv_components/common_widgets/dropdown.dart';
import 'package:ppv_components/features/organization/services/organizations_api_service.dart';

class EditOrganizationScreen extends StatefulWidget {
  final Organization organization;
  final OrganizationModel? organizationModel;

  const EditOrganizationScreen({
    super.key,
    required this.organization,
    this.organizationModel,
  });

  @override
  State<EditOrganizationScreen> createState() => _EditOrganizationScreenState();
}

class _EditOrganizationScreenState extends State<EditOrganizationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _descriptionController;
  late String _selectedStatus;
  final List<String> _statusOptions = ['Active', 'Inactive'];

  File? _logoFile;
  String? _logoFileName;
  String? _permanentLogoPath;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.organization.name);
    _codeController = TextEditingController(text: widget.organization.code);
    _descriptionController =
        TextEditingController(text: widget.organization.description ?? '');
    _selectedStatus = widget.organization.status;
    _permanentLogoPath = widget.organization.logoPath;

    // Initialize logo file if path exists
    if (_permanentLogoPath != null && _permanentLogoPath!.isNotEmpty) {
      _logoFile = File(_permanentLogoPath!);
      _logoFileName = path.basename(_permanentLogoPath!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  Future<void> _pickLogoFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        int fileSizeInBytes = await file.length();
        double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 2) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File size must be less than 2MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        final Directory appDir = await getApplicationDocumentsDirectory();
        final String organizationLogosDir = '${appDir.path}/organization_logos';

        final Directory logosDirectory = Directory(organizationLogosDir);
        if (!await logosDirectory.exists()) {
          await logosDirectory.create(recursive: true);
        }

        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String extension = path.extension(result.files.single.name);
        final String newFileName = 'logo_$timestamp$extension';
        final String permanentPath = '$organizationLogosDir/$newFileName';

        final File permanentFile = await file.copy(permanentPath);

        setState(() {
          _logoFile = permanentFile;
          _logoFileName = result.files.single.name;
          _permanentLogoPath = permanentPath;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final organizationModel = widget.organizationModel;
    if (organizationModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update: missing organization context'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => _isSubmitting = true);

      final service = context.read<OrganizationsApiService>();
      final request = UpdateOrganizationRequest(
        orgId: organizationModel.orgId,
        name: _nameController.text.trim(),
        code: _codeController.text.trim().toUpperCase(),
        description: _descriptionController.text.trim(),
        logo: _permanentLogoPath ?? organizationModel.logo,
        status: _selectedStatus == 'Active' ? 'activated' : 'deactivated',
      );

      final result = await service.updateOrganization(organizationModel.orgId, request);

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Organization updated successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, result.organization ?? organizationModel);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Failed to update organization'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating organization: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

 Widget _buildOrganizationLogo() {
  final colorScheme = Theme.of(context).colorScheme;
  final nameText = _nameController.text.trim();
  String badgeText;
  if (nameText.isEmpty) {
    badgeText = 'O'; // Fallback badge
  } else if (nameText.length == 1) {
    badgeText = nameText[0];
  } else {
    final nameParts = nameText.split(' ');
    if (nameParts.length >= 2 && nameParts[0].isNotEmpty && nameParts[1].isNotEmpty) {
      badgeText = nameParts[0][0] + nameParts[1][0];
    } else {
      badgeText = nameText.substring(0, 2);
    }
  }

  if (_logoFile != null && _logoFile!.existsSync()) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _logoFile!,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  return Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      color: colorScheme.primary,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: Text(
        badgeText.toUpperCase(),
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Logo, Name, Code, Status, and Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  _buildOrganizationLogo(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nameController.text.isEmpty ? 'Organization Name' : _nameController.text,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _codeController.text.isEmpty ? 'CODE' : _codeController.text.toUpperCase(),
                                style: textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedStatus == 'Active'
                                    ? Colors.green
                                    : Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _selectedStatus,
                                style: textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      PrimaryButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        label: _isSubmitting ? 'Saving...' : 'Save',
                        icon: Icons.save_outlined,
                      ),
                      const SizedBox(width: 8),
                      SecondaryButton(
                        label: 'Back',
                        onPressed: () => Navigator.pop(context),
                        icon: Icons.arrow_back,
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Basic Information Form Card
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Basic Information',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildInfoRow('Organization Name:', _nameController.text),
            _buildInfoRow('Code:', _codeController.text.toUpperCase()),
            _buildInfoRow('Status:', _selectedStatus),
            _buildInfoRow('Created By:', widget.organization.createdBy),
            _buildInfoRow('Created At:', widget.organization.createdDate),
            _buildInfoRow('Last Updated:', widget.organization.createdDate),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            _buildTextField(
              controller: _nameController,
              label: 'Organization Name',
              hintText: 'Enter organization name',
              isRequired: true,
              validator: (value) => _validateRequired(value, 'Organization name'),
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _codeController,
              label: 'Organization Code',
              hintText: 'Enter organization code',
              isRequired: true,
              validator: (value) => _validateRequired(value, 'Organization code'),
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hintText: 'Enter description',
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Status', true),
                const SizedBox(height: 8),
                CustomDropdown(
                  value: _selectedStatus,
                  items: _statusOptions,
                  hint: 'Select Status',
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Logo Upload Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Organization Logo',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      OutlinedButton(
                        onPressed: _pickLogoFile,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          side: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Text('Choose File'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _logoFileName ?? 'No file chosen',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_logoFile != null)
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            setState(() {
                              _logoFile = null;
                              _logoFileName = null;
                              _permanentLogoPath = null;
                            });
                          },
                          tooltip: 'Remove file',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label, bool isRequired) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return RichText(
      text: TextSpan(
        text: label,
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String label,
    String? hintText,
    bool isRequired = false,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          onChanged: (value) {
            if (controller == _nameController || controller == _codeController) {
              setState(() {});
            }
          },
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
