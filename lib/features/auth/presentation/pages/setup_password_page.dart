import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/encryption_service.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import 'login_page.dart';

class SetupPasswordPage extends StatefulWidget {
  const SetupPasswordPage({super.key});

  @override
  State<SetupPasswordPage> createState() => _SetupPasswordPageState();
}

class _SetupPasswordPageState extends State<SetupPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSetup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final password = _passwordController.text;
      
      // Save master password to database with salt
      await DatabaseService.instance.saveMasterPassword(password);
      
      // Initialize encryption service with DEFAULT key
      // Master password is ONLY for authentication, not for encrypting passwords!
      EncryptionService.initializeWithDefaultKey();
      
      // Store session master password (optional)
      DatabaseService.instance.setSessionMasterPassword(password);

      setState(() => _isLoading = false);

      if (mounted) {
        // Navigate to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Master password created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      print('Error creating master password: $e'); // Debug logging
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create master password: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'field_required'.tr();
    }
    if (value.length < 8) {
      return 'password_too_short'.tr();
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'field_required'.tr();
    }
    if (value != _passwordController.text) {
      return 'passwords_do_not_match'.tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                const SizedBox(height: 32),
                
                // App Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.security,
                    size: 48,
                    color: AppColors.white,
                  ),
                )
                    .animate()
                    .scale(duration: 500.ms, curve: Curves.elasticOut)
                    .fadeIn(),

                const SizedBox(height: 32),

                // Title
                Text(
                  'create_master_password'.tr(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey900,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 8),

                Text(
                  'create_strong_password_hint'.tr(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.grey600,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 48),

                // Master Password Field
                CustomTextField(
                  controller: _passwordController,
                  label: 'master_password'.tr(),
                  hint: 'password_hint'.tr(),
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.grey600,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: _validatePassword,
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.3, end: 0),

                const SizedBox(height: 24),

                // Confirm Password Field
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'confirm_master_password'.tr(),
                  hint: 'confirm_password_hint'.tr(),
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.grey600,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                  validator: _validateConfirmPassword,
                )
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.3, end: 0),

                const SizedBox(height: 32),

                // Create Button
                CustomButton(
                  text: 'create_master_password'.tr(),
                  onPressed: _isLoading ? null : _handleSetup,
                  isLoading: _isLoading,
                  width: double.infinity,
                )
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.3, end: 0),

                const Spacer(),

                // Back to Login Link
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: Text(
                    'already_have_password_login'.tr(),
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
                    .animate(delay: 700.ms)
                    .fadeIn(duration: 400.ms),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}