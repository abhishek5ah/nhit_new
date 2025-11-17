import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ppv_components/core/services/auth_service.dart';
import 'package:ppv_components/features/organization/services/organization_service.dart';

class AddOrganizationDialog extends StatefulWidget {
  const AddOrganizationDialog({super.key});

  @override
  State<AddOrganizationDialog> createState() => _AddOrganizationDialogState();
}

class _AddOrganizationDialogState extends State<AddOrganizationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  // Note: Super admin creation is handled separately in the current flow
  
  bool _isLoading = false;
  final List<String> _selectedProjects = ['ERP', 'NHIT'];

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    // Admin controllers removed - handled in separate flow
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: isDesktop ? 600 : screenWidth * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.business,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Add New Organization',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Form
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Organization Details Section
                      Text(
                        'Organization Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Organization Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Organization Name *',
                          hintText: 'Enter organization name',
                          prefixIcon: const Icon(Icons.business),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Organization name is required';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          // Auto-generate code from name
                          if (value.isNotEmpty && _codeController.text.isEmpty) {
                            _codeController.text = value
                                .toUpperCase()
                                .replaceAll(RegExp(r'[^A-Z0-9]'), '')
                                .substring(0, value.length > 10 ? 10 : value.length);
                          }
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Organization Code
                      TextFormField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          labelText: 'Organization Code *',
                          hintText: 'Enter unique code',
                          prefixIcon: const Icon(Icons.code),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Organization code is required';
                          }
                          if (value.length < 2) {
                            return 'Code must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter organization description',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Initial Projects Section
                      Text(
                        'Initial Projects',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Default projects: ERP, NHIT',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                
                const SizedBox(width: 12),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _createOrganization,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Organization'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createOrganization() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = context.read<AuthService>();
      final organizationService = context.read<OrganizationService>();

      // Create organization using AuthService
      final result = await authService.createOrganization(
        organizationName: _nameController.text.trim(),
        organizationCode: _codeController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? 'Main ${_nameController.text.trim()} Organization' 
            : _descriptionController.text.trim(),
        initialProjects: _selectedProjects,
      );

      if (result.success) {
        // Reload organizations list
        await organizationService.loadOrganizations();
        
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Organization created successfully'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Failed to create organization'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
