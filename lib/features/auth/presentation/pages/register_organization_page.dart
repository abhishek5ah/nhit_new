import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/core/services/auth_service.dart';

class RegisterOrganizationPage extends StatefulWidget {
  const RegisterOrganizationPage({super.key});

  @override
  State<RegisterOrganizationPage> createState() => _RegisterOrganizationPageState();
}

class _RegisterOrganizationPageState extends State<RegisterOrganizationPage> {
  final _formKey = GlobalKey<FormState>();
  final _orgNameController = TextEditingController();
  final _orgCodeController = TextEditingController();
  final _orgDescriptionController = TextEditingController();
  final List<TextEditingController> _projectControllers = [
    TextEditingController()
  ];

  bool _isLoading = false;
  
  // Error states for specific fields
  String? _orgCodeError;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    // Check if we have tenant data from Step 1
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authService.currentTenantId == null) {
        // No tenant data, redirect back to step 1
        context.go('/tenants');
        return;
      }
    });
  }

  @override
  void dispose() {
    _orgNameController.dispose();
    _orgCodeController.dispose();
    _orgDescriptionController.dispose();
    for (var controller in _projectControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addProjectField() {
    setState(() {
      _projectControllers.add(TextEditingController());
    });
  }

  void _removeProjectField(int index) {
    if (_projectControllers.length > 1) {
      setState(() {
        _projectControllers[index].dispose();
        _projectControllers.removeAt(index);
      });
    }
  }

  Future<void> _handleCreateOrganization() async {
    // Clear previous errors
    setState(() {
      _orgCodeError = null;
      _generalError = null;
    });

    // Validate form first - return early if validation fails
    if (!_formKey.currentState!.validate()) {
      print('📝 [CreateOrgPage] Form validation failed');
      return;
    }

    // Set loading state
    setState(() => _isLoading = true);
    print('⏳ [CreateOrgPage] Set loading state to true');

    try {
      // Get form values
      final orgName = _orgNameController.text.trim();
      final orgCode = _orgCodeController.text.trim().toUpperCase();
      final orgDescription = _orgDescriptionController.text.trim();

      // Get project names
      final projects = _projectControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      print('🏢 [CreateOrgPage] Starting organization creation: $orgName (Code: $orgCode)');
      print('📋 [CreateOrgPage] Initial projects: $projects');

      // Call AuthService with new parameters
      final result = await authService.createOrganization(
        organizationName: orgName,
        organizationCode: orgCode,
        description: orgDescription,
        initialProjects: projects,
      );

      print('📥 [CreateOrgPage] AuthService result - Success: ${result.success}, Message: ${result.message}');

      // Set loading to false
      setState(() => _isLoading = false);
      print('⏳ [CreateOrgPage] Set loading state to false');

      // Check if widget is still mounted before UI operations
      if (!mounted) {
        print('⚠️  [CreateOrgPage] Widget not mounted, skipping UI updates');
        return;
      }

      if (result.success && result.data != null) {
        print('✅ [CreateOrgPage] Organization creation successful, showing success message');

        // Show success SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Organization created successfully! Please login to continue.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );

        print('⏰ [CreateOrgPage] Waiting 1200ms for user feedback');
        await Future.delayed(const Duration(milliseconds: 1200));

        // Check mounted again before navigation
        if (!mounted) {
          print('⚠️  [CreateOrgPage] Widget not mounted after delay, skipping navigation');
          return;
        }

        // Navigate to login screen (Step 3) with pre-filled email
        print('🧭 [CreateOrgPage] Navigating to /login');
        context.go('/login');
      } else {
        print('❌ [CreateOrgPage] Organization creation failed, showing error message');
        
        // Handle specific error types
        if (result.isDuplicateCode) {
          print('🔴 [CreateOrgPage] Duplicate organization code error');
          setState(() {
            _orgCodeError = result.message ?? 'This organization code already exists';
          });
          
          // Revalidate form to show the error
          _formKey.currentState!.validate();
          
          // Show SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Organization code already exists'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        } else if (result.isDuplicateEmail) {
          print('🔴 [CreateOrgPage] Duplicate email error (super admin)');
          setState(() {
            _generalError = result.message ?? 'This email is already registered';
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Email already exists'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          // Generic error
          print('🔴 [CreateOrgPage] General error: ${result.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Organization creation failed'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _handleCreateOrganization,
              ),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('🚨 [CreateOrgPage] ERROR in _handleCreateOrganization:');
      print('   Error: $e');
      print('   StackTrace: $stackTrace');

      // Ensure loading is set to false
      if (mounted) {
        setState(() => _isLoading = false);
      }

      // Show error SnackBar if widget is still mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleBack() {
    context.go('/tenants');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 450 : double.infinity,
              ),
              child: Card(
                elevation: 8,
                shadowColor: colorScheme.shadow.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header with Icon - centered in circle
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.apartment,
                                size: 32,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create Your Organization',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Step 2 of 2: Set up your organization',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Show general error if exists
                        if (_generalError != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _generalError!,
                                    style: TextStyle(color: Colors.red, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Organization Name Field
                        TextFormField(
                          controller: _orgNameController,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'Organization Name',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                            ),
                            prefixIcon: Icon(
                              Icons.business_outlined,
                              color: colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.outline,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.outline,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.error,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.error,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter organization name';
                            }
                            if (value.trim().isEmpty) {
                              return 'Organization name cannot be empty';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 8),

                        // Organization Code Field with error handling
                        TextFormField(
                          controller: _orgCodeController,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'Organization Code (e.g., NHIT, ERP)',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                            ),
                            prefixIcon: Icon(
                              Icons.code,
                              color: _orgCodeError != null 
                                  ? Colors.red 
                                  : colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            suffixIcon: _orgCodeError != null
                                ? Icon(Icons.error, color: Colors.red, size: 20)
                                : null,
                            filled: true,
                            fillColor: _orgCodeError != null
                                ? Colors.red.withOpacity(0.05)
                                : colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _orgCodeError != null 
                                    ? Colors.red 
                                    : colorScheme.outline,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _orgCodeError != null 
                                    ? Colors.red 
                                    : colorScheme.outline,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _orgCodeError != null 
                                    ? Colors.red 
                                    : colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.red,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                          ),
                          onChanged: (value) {
                            // Clear error when user types
                            if (_orgCodeError != null) {
                              setState(() {
                                _orgCodeError = null;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter organization code';
                            }
                            if (!RegExp(r'^[A-Z0-9_]+$').hasMatch(value.toUpperCase())) {
                              return 'Code must be alphanumeric and uppercase';
                            }
                            // Show backend error if exists
                            if (_orgCodeError != null) {
                              return _orgCodeError;
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 8),

                        // Organization Description Field
                        TextFormField(
                          controller: _orgDescriptionController,
                          maxLines: 3,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'Organization Description',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(bottom: 50),
                              child: Icon(
                                Icons.description_outlined,
                                color: colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.outline,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.outline,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.error,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.error,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter organization description';
                            }
                            if (value.trim().length < 10) {
                              return 'Description must be at least 10 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 8),

                        // OPTIONAL Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: colorScheme.outlineVariant,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OPTIONAL',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: colorScheme.outlineVariant,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Initial Projects Label
                        Text(
                          'Initial Projects',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Project Fields
                        ..._projectControllers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final controller = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: controller,
                                    style: TextStyle(color: colorScheme.onSurface),
                                    decoration: InputDecoration(
                                      hintText: 'Project ${index + 1}',
                                      hintStyle: TextStyle(
                                        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.work_outline,
                                        color: colorScheme.onSurfaceVariant,
                                        size: 20,
                                      ),
                                      filled: true,
                                      fillColor: colorScheme.surfaceContainerHighest,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: colorScheme.outline,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: colorScheme.outline,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: colorScheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_projectControllers.length > 1) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () => _removeProjectField(index),
                                    icon: Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Remove project',
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),

                        // Add Project Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: _addProjectField,
                            icon: Icon(
                              Icons.add,
                              size: 18,
                              color: colorScheme.onSurface,
                            ),
                            label: Text(
                              'Add Another Project',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: colorScheme.outline,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: colorScheme.surface,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Super Admin Info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.outline,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.person_outline,
                                  color: colorScheme.onPrimaryContainer,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Super Admin: ${authService.currentUserName ?? 'N/A'}',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      authService.currentUserEmail ?? 'N/A',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Create Organization Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleCreateOrganization,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              shadowColor: colorScheme.primary.withOpacity(0.3),
                              disabledBackgroundColor: colorScheme.primary.withOpacity(0.5),
                            ),
                            child: _isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            colorScheme.onPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Creating...',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onPrimary,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    'Create Organization',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Back Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _handleBack,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: colorScheme.outline,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: colorScheme.surface,
                            ),
                            child: Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Already have account link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an organization? ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/login'),
                              style: TextButton.styleFrom(
                                foregroundColor: colorScheme.primary,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
