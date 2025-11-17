import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/core/services/auth_service.dart';
import 'package:ppv_components/features/auth/presentation/widgets/auth_text_field.dart';

class LoginFinalStepPage extends StatefulWidget {
  const LoginFinalStepPage({super.key});

  @override
  State<LoginFinalStepPage> createState() => _LoginFinalStepPageState();
}

class _LoginFinalStepPageState extends State<LoginFinalStepPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill email from previous steps
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authService.currentUserEmail != null) {
        _emailController.text = authService.currentUserEmail!;
      } else {
        // No organization data, redirect back to step 1
        context.go('/tenants');
        return;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Validate form first - return early if validation fails
    if (!_formKey.currentState!.validate()) {
      print('📝 [LoginFinalStepPage] Form validation failed');
      return;
    }

    // Set loading state
    setState(() => _isLoading = true);
    print('⏳ [LoginFinalStepPage] Set loading state to true');

    try {
      // Get form values
      final email = _emailController.text.trim();
      final password = _passwordController.text; // Don't trim password
      
      print('🔑 [LoginFinalStepPage] Starting login for user: $email');
      
      // Call AuthService login method
      final result = await authService.login(email, password);
      
      print('📥 [LoginFinalStepPage] AuthService result - Success: ${result.success}, Message: ${result.message}');
      
      // Set loading to false
      setState(() => _isLoading = false);
      print('⏳ [LoginFinalStepPage] Set loading state to false');

      // Check if widget is still mounted before UI operations
      if (!mounted) {
        print('⚠️  [LoginFinalStepPage] Widget not mounted, skipping UI updates');
        return;
      }

      if (result.success) {
        print('✅ [LoginFinalStepPage] Login successful, showing success message');
        
        // Show success SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Login successful! Welcome to your dashboard.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        print('⏰ [LoginFinalStepPage] Waiting 800ms for user feedback');
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Check mounted again before navigation
        if (!mounted) {
          print('⚠️  [LoginFinalStepPage] Widget not mounted after delay, skipping navigation');
          return;
        }
        
        print('🧭 [LoginFinalStepPage] Navigating to /dashboard');
        // Direct navigation to avoid router redirect issues
        try {
          context.go('/dashboard');
        } catch (e) {
          print('⚠️ [LoginFinalStepPage] Navigation error: $e');
          // Fallback: try push replacement
          context.pushReplacement('/dashboard');
        }
      } else {
        print('❌ [LoginFinalStepPage] Login failed, showing error message');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Login failed'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('🚨 [LoginFinalStepPage] ERROR in _handleLogin:');
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
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _handleBack() {
    context.go('/create-organization');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;
    final organizationName = authService.organizationData?.organization.name ?? 'Your Organization';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWideScreen ? 48.0 : 24.0,
              vertical: 32.0,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWideScreen ? 400 : double.infinity,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Step indicator
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Step 3 of 3: Login to Your Account',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Organization info
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.business,
                            color: theme.colorScheme.onSecondaryContainer,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Organization: $organizationName',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Login to Dashboard',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use your super admin credentials to access the dashboard',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Email Field
                    AuthTextField(
                      controller: _emailController,
                      labelText: 'Email Address',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    AuthTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true, // AuthTextField has built-in visibility toggle
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    FilledButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : Text(
                              'Login to Dashboard',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Back Button
                    OutlinedButton(
                      onPressed: _handleBack,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Back to Organization Setup',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Help Text
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'After successful login, you will have full access to your organization\'s dashboard and can manage users, projects, and settings.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
