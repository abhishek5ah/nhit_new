import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:provider/provider.dart';
import 'package:ppv_components/core/services/jwt_token_manager.dart';
import 'package:ppv_components/features/organization/data/models/organization_api_models.dart';
import 'package:ppv_components/features/organization/services/organizations_api_service.dart';

class CreateOrganizationScreen extends StatefulWidget {
  const CreateOrganizationScreen({super.key});

  @override
  State<CreateOrganizationScreen> createState() =>
      _CreateOrganizationScreenState();
}

class _CreateOrganizationScreenState extends State<CreateOrganizationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _descriptionController;

  final List<TextEditingController> _projectControllers = [];

  bool _isLoading = false;

  File? _logoFile;
  String? _logoFileName;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _codeController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    for (var controller in _projectControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Updated file picker that saves to permanent location
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

        // Check file size (max 2MB)
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

        // Copy file to permanent location
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String organizationLogosDir = '${appDir.path}/organization_logos';

        // Create directory if it doesn't exist
        final Directory logosDirectory = Directory(organizationLogosDir);
        if (!await logosDirectory.exists()) {
          await logosDirectory.create(recursive: true);
        }

        // Create unique filename
        final String timestamp = DateTime.now().millisecondsSinceEpoch
            .toString();
        final String extension = path.extension(result.files.single.name);
        final String newFileName = 'logo_$timestamp$extension';
        final String permanentPath = '$organizationLogosDir/$newFileName';

        // Copy file to permanent location
        final File permanentFile = await file.copy(permanentPath);

        setState(() {
          _logoFile = permanentFile;
          _logoFileName = result.files.single.name;
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

  void _addProject() {
    setState(() {
      _projectControllers.add(TextEditingController());
    });
  }

  void _removeProject(int index) {
    setState(() {
      _projectControllers[index].dispose();
      _projectControllers.removeAt(index);
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final orgService = context.read<OrganizationsApiService>();

        // Get current user data from JWT tokens (this is the correct source)
        final userName = await JwtTokenManager.getName();
        final userEmail = await JwtTokenManager.getEmail();
        
        print('👤 [CreateOrganization] Current user data:');
        print('   Name: "${userName ?? 'NULL'}"');
        print('   Email: "${userEmail ?? 'NULL'}"');

        // Ensure we have valid user data - this should never be empty after login
        if (userName == null || userName.isEmpty || userEmail == null || userEmail.isEmpty) {
          throw Exception('User data not available. Please login again.');
        }

        final superAdmin = SuperAdminRequest(
          name: userName,
          email: userEmail,
          password: '', // Empty password like in working registration flow
        );
        
        print('🔑 [CreateOrganization] SuperAdmin data:');
        print('   Name: "${superAdmin.name}"');
        print('   Email: "${superAdmin.email}"');

        // Get tenant ID and parent org ID
        final tenantId = await JwtTokenManager.getTenantId();
        final savedParentOrgId = await JwtTokenManager.getParentOrgId();
        final fallbackParentOrgId = orgService.currentOrganization?.orgId;
        
        print('🔑 [CreateOrganization] Context data:');
        print('   TenantId: "${tenantId ?? 'NULL'}"');
        print('   SavedParentOrgId: "${savedParentOrgId ?? 'NULL'}"');
        print('   FallbackParentOrgId: "${fallbackParentOrgId ?? 'NULL'}"');

        final request = CreateOrganizationRequest(
          tenantId: tenantId, // Include tenantId like in registration flow
          parentOrgId: savedParentOrgId?.isNotEmpty == true
              ? savedParentOrgId
              : fallbackParentOrgId,
          name: _nameController.text.trim(),
          code: _codeController.text.trim().toUpperCase(),
          description: _descriptionController.text.trim().isEmpty
              ? 'Main ${_nameController.text.trim()} Organization'
              : _descriptionController.text.trim(),
          superAdmin: superAdmin,
          createdBy: userName, // Explicitly set createdBy to current user's name
          initialProjects: _projectControllers
              .map((c) => c.text.trim())
              .where((p) => p.isNotEmpty)
              .toList(),
        );
        
        print('📦 [CreateOrganization] Request payload:');
        print('   TenantId: ${request.tenantId}');
        print('   ParentOrgId: ${request.parentOrgId}');
        print('   Name: ${request.name}');
        print('   Code: ${request.code}');
        print('   SuperAdmin: ${request.superAdmin.name} (${request.superAdmin.email})');
        print('   SuperAdmin Password: "${request.superAdmin.password}"');
        print('   CreatedBy: "${request.createdBy}"');
        print('   Projects: ${request.initialProjects}');
        print('   Full JSON: ${request.toJson()}');

        final result = await orgService.createOrganization(request);

        if (result.success && result.organization != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.message ?? 'Organization created successfully!',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          Navigator.pop(context, result.organization);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Failed to create organization'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
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
            // Header with Blue Background
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
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.green[600],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_business,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Organization',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add a new organization to the system',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Organization Name and Code
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _nameController,
                          label: 'Organization Name',
                          hintText: 'Enter organization name',
                          isRequired: true,
                          validator: (value) =>
                              _validateRequired(value, 'Organization name'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              controller: _codeController,
                              label: 'Organization Code',
                              hintText: 'ENTER UNIQUE CODE (E.G., NHIT)',
                              isRequired: true,
                              validator: (value) =>
                                  _validateRequired(value, 'Organization code'),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'This will be used to generate the database name.',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Description
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hintText: 'Enter organization description (optional)',
                    maxLines: 3,
                  ),

                  const SizedBox(height: 20),

                  // Organization Logo
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.3,
                          ),
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
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                side: BorderSide(
                                  color: colorScheme.outline.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              child: const Text('Choose File'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _logoFileName ?? 'No file chosen',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
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
                                  });
                                },
                                tooltip: 'Remove file',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Upload a logo image (JPEG, PNG, JPG, GIF, max 2MB).',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                      // Preview the uploaded logo
                      if (_logoFile != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(_logoFile!, fit: BoxFit.cover),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Projects Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.folder_outlined, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Projects',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(Optional - You can add these later in settings)',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Project Fields
                        ...List.generate(_projectControllers.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.folder_outlined, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _projectControllers[index],
                                    decoration: InputDecoration(
                                      hintText: 'Enter project name',
                                      hintStyle: TextStyle(
                                        color: colorScheme.onSurface.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: colorScheme.surface,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: colorScheme.outline.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: colorScheme.outline.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.close, size: 20),
                                        onPressed: () => _removeProject(index),
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        // Add Another Project Button
                        OutlinedButton.icon(
                          onPressed: _addProject,
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          label: const Text('Add Another Project'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                        Text(
                          'Add projects that will be available for this organization',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info Note Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Note:',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Creating an organization will:',
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.blue[900],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildInfoItem(
                                'Create a separate database for this organization',
                              ),
                              _buildInfoItem(
                                'Clone the current system structure to the new database',
                              ),
                              _buildInfoItem(
                                'Allow you to switch between organizations seamlessly',
                              ),
                              _buildInfoItem(
                                'Maintain user roles and permissions across organizations',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SecondaryButton(
                        onPressed: () => context.go('/organizations'),
                        label: 'Cancel',
                      ),

                      const SizedBox(width: 8),
                      PrimaryButton(
                        onPressed: _submitForm,
                        label: 'Create Organization',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: Colors.blue[900],
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.blue[900], fontSize: 13),
            ),
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
    bool obscureText = false,
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
          obscureText: obscureText,
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
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
