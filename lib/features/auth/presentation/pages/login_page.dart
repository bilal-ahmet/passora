import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/encryption_service.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../passwords/presentation/pages/home_page.dart';
import 'setup_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _masterPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  @override
  void dispose() {
    _masterPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Check if master password is set
      final userExists = await DatabaseService.instance.masterPasswordExists();
      
      if (!userExists) {
        // No master password set, redirect to setup
        setState(() => _isLoading = false);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SetupPasswordPage()),
          );
        }
        return;
      }

      // Verify master password
      final enteredPassword = _masterPasswordController.text;
      final isValid = await DatabaseService.instance.verifyMasterPassword(enteredPassword);
      
      setState(() => _isLoading = false);

      if (isValid) {
        // Master password verified - but we use default key for encryption
        // Master password is ONLY for app authentication
        EncryptionService.initializeWithDefaultKey();
        
        // Store session master password for later use (optional)
        DatabaseService.instance.setSessionMasterPassword(enteredPassword);
        
        // Disable bypass mode (normal authentication)
        await DatabaseService.instance.setBypassMode(false);
        
        if (mounted) {
          // Navigate to home page
          _navigateToHome();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome to Passora!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        // Invalid password
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid master password. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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

                // Welcome Text
                Text(
                  'unlock_vault'.tr(),
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
                  'enter_master_password'.tr(),
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
                  controller: _masterPasswordController,
                  label: 'master_password'.tr(),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'field_required'.tr();
                    }
                    return null;
                  },
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.3, end: 0),

                const SizedBox(height: 32),

                // Login Button
                CustomButton(
                  text: 'unlock_vault'.tr(),
                  onPressed: _isLoading ? null : _handleLogin,
                  isLoading: _isLoading,
                  width: double.infinity,
                )
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 24),

                const Spacer(),

                // Setup Master Password Link
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SetupPasswordPage(),
                      ),
                    );
                  },
                  child: Text(
                    'first_time_create_password'.tr(),
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