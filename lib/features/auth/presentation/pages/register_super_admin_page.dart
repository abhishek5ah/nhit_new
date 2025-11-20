import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/core/services/auth_service.dart';
import 'package:ppv_components/core/services/google_auth_service.dart';

class RegisterSuperAdminPage extends StatefulWidget {
  const RegisterSuperAdminPage({super.key});

  @override
  State<RegisterSuperAdminPage> createState() => _RegisterSuperAdminPageState();
}

class _RegisterSuperAdminPageState extends State<RegisterSuperAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // Validate form first - return early if validation fails
    if (!_formKey.currentState!.validate()) {
      print('📝 [RegisterPage] Form validation failed');
      return;
    }

    // Set loading state
    setState(() => _isLoading = true);
    print('⏳ [RegisterPage] Set loading state to true');

    try {
      // Get form values
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text; // Don't trim password
      
      print('🚀 [RegisterPage] Starting registration for user: $name, email: $email');
      
      // Call AuthService with individual parameters (NEW: createTenant)
      final result = await authService.createTenant(name, email, password);
      
      print('📥 [RegisterPage] AuthService result - Success: ${result.success}, Message: ${result.message}');
      
      // Set loading to false
      setState(() => _isLoading = false);
      print('⏳ [RegisterPage] Set loading state to false');

      // Check if widget is still mounted before UI operations
      if (!mounted) {
        print('⚠️  [RegisterPage] Widget not mounted, skipping UI updates');
        return;
      }

      if (result.success) {
        print('✅ [RegisterPage] Registration successful, showing success message');
        
        // Show success SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Registration successful! Proceeding to organization setup...'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
        
        print('⏰ [RegisterPage] Waiting 800ms for user feedback');
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Check mounted again before navigation
        if (!mounted) {
          print('⚠️  [RegisterPage] Widget not mounted after delay, skipping navigation');
          return;
        }
        
        print('🧭 [RegisterPage] Navigating to /register-organization');
        context.go('/register-organization');
      } else {
        print('❌ [RegisterPage] Registration failed, showing error message');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Registration failed'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('🚨 [RegisterPage] ERROR in _handleRegister:');
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

  Future<void> _handleGoogleRegister() async {
    setState(() => _isGoogleLoading = true);

    final result = await GoogleAuthService.signInWithGoogle();

    setState(() => _isGoogleLoading = false);

    if (result.success) {
      if (mounted) {
        context.go('/register-organization');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Google registration failed'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
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
            padding: const EdgeInsets.all(16),
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
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header with Admin Icon
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.admin_panel_settings,
                                size: 36,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Create Super Admin Account',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Step 1 of 2: Create your super admin account',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Name Field
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Full Name',
                            prefixIcon: const Icon(Icons.person_outline),
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
                              return 'Please enter your name';
                            }
                            if (value.trim().isEmpty) {
                              return 'Name cannot be empty';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            prefixIcon: const Icon(Icons.mail_outline),
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
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
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
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Continue Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              shadowColor: colorScheme.primary.withOpacity(0.3),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.onPrimary,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // OR Divider
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
                                'OR',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 14,
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

                        const SizedBox(height: 24),

                        // Social Login Buttons
                        Column(
                          children: [
                            // Google Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton(
                                onPressed: _isGoogleLoading ? null : _handleGoogleRegister,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: colorScheme.outline,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: colorScheme.surface,
                                ),
                                child: _isGoogleLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.network(
                                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDICQ3Gup2R71OCmbx5mEnXMa_-nFtzVMxE--Im0OeaHbXxsxEyCINHzrOf64IdixxS42cAIqCmDEK1hlMCWXDh-7teI9fyTFXUdLj6ot4iD92ldCED5_CvY8-0LWlV9qDjGqekeAi_guYwnQkZ8G7_10PMoabYh8sYESF7u8Q6unvafAtX9Tm9hkYJSCltWdzz9IFJrqf4m8k5BcReALPIAFtSNCj-9eHzvWjK2QcE0XAQeG645V1wwd8o89Li5DVjXv3o8RpV7fM',
                                            width: 20,
                                            height: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Continue with Google',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Microsoft Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Microsoft registration coming soon'),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: colorScheme.outline,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: colorScheme.surface,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Microsoft Logo
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Row(
                                        children: [
                                          Column(
                                            children: [
                                              Container(
                                                width: 9,
                                                height: 9,
                                                color: const Color(0xFFF25022),
                                              ),
                                              const SizedBox(height: 2),
                                              Container(
                                                width: 9,
                                                height: 9,
                                                color: const Color(0xFF00A4EF),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 2),
                                          Column(
                                            children: [
                                              Container(
                                                width: 9,
                                                height: 9,
                                                color: const Color(0xFF7FBA00),
                                              ),
                                              const SizedBox(height: 2),
                                              Container(
                                                width: 9,
                                                height: 9,
                                                color: const Color(0xFFFFB900),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Continue with Microsoft',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
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
