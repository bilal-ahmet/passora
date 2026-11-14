import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/database_service.dart';
import '../../../../shared/widgets/gradient_scaffold.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Verify current password
      final isCurrentPasswordValid = await DatabaseService.instance
          .verifyMasterPassword(_currentPasswordController.text.trim());
      
      if (!isCurrentPasswordValid) {
        _showError('Current password is incorrect');
        return;
      }

      // Validate new password
      final newPassword = _newPasswordController.text.trim();
      if (newPassword.length < 8) {
        _showError('New password must be at least 8 characters long');
        return;
      }

      // Confirm new password
      if (newPassword != _confirmPasswordController.text.trim()) {
        _showError('New passwords do not match');
        return;
      }

      // Change master password
      await DatabaseService.instance.changeMasterPassword(
        _currentPasswordController.text.trim(),
        newPassword,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Master password changed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Go back to settings
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError('Failed to change password: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Content
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 24.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Icon
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: AppColors.fabGradient,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.key,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ).animate().fadeIn(duration: 600.ms).scale(),
                          
                          const SizedBox(height: 24),
                          
                          const Text(
                            'Change Your Master Password',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            'Enter your current password and choose a new secure password',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                          
                          const SizedBox(height: 40),
                          
                          // Form
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Current Password Field
                                _buildPasswordField(
                                  controller: _currentPasswordController,
                                  label: 'Current Master Password',
                                  isVisible: _isCurrentPasswordVisible,
                                  onVisibilityToggle: () {
                                    setState(() {
                                      _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your current password';
                                    }
                                    return null;
                                  },
                                ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideX(),
                                
                                const SizedBox(height: 20),
                                
                                // New Password Field
                                _buildPasswordField(
                                  controller: _newPasswordController,
                                  label: 'New Master Password',
                                  isVisible: _isNewPasswordVisible,
                                  onVisibilityToggle: () {
                                    setState(() {
                                      _isNewPasswordVisible = !_isNewPasswordVisible;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a new password';
                                    }
                                    if (value.length < 8) {
                                      return 'Password must be at least 8 characters long';
                                    }
                                    return null;
                                  },
                                ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideX(),
                                
                                const SizedBox(height: 20),
                                
                                // Confirm Password Field
                                _buildPasswordField(
                                  controller: _confirmPasswordController,
                                  label: 'Confirm New Password',
                                  isVisible: _isConfirmPasswordVisible,
                                  onVisibilityToggle: () {
                                    setState(() {
                                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your new password';
                                    }
                                    if (value != _newPasswordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ).animate().fadeIn(duration: 600.ms, delay: 1000.ms).slideX(),
                                
                                const SizedBox(height: 40),
                                
                                // Password Requirements
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryPurple.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: AppColors.primaryPurple.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Password Requirements:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.accentPink,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text('• At least 8 characters long', style: TextStyle(color: AppColors.textSecondary)),
                                          Text('• Use a combination of letters, numbers, and symbols', style: TextStyle(color: AppColors.textSecondary)),
                                          Text('• Avoid common passwords', style: TextStyle(color: AppColors.textSecondary)),
                                          Text('• Don\'t reuse your current password', style: TextStyle(color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ).animate().fadeIn(duration: 600.ms, delay: 1200.ms),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Change Password Button
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: AppColors.fabGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentPink.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleChangePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Change Password',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ).animate().fadeIn(duration: 600.ms, delay: 1400.ms).slideY(),
                          
                          const SizedBox(height: 20),
                          
                          // Cancel Button
                          TextButton(
                            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ).animate().fadeIn(duration: 600.ms, delay: 1600.ms),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.glassWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Title
          const Text(
            'Change Password',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    required String? Function(String?) validator,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: !isVisible,
            validator: validator,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                ),
                onPressed: onVisibilityToggle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}