import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/services/database_service.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Master Password'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: LayoutBuilder(
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
                  // Header
                  const Icon(
                    Icons.key,
                    size: 80,
                    color: Colors.blue,
                  ).animate().fadeIn(duration: 600.ms).scale(),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'Change Your Master Password',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Enter your current password and choose a new secure password',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
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
                        CustomTextField(
                          controller: _currentPasswordController,
                          label: 'Current Master Password',
                          obscureText: !_isCurrentPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your current password';
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isCurrentPasswordVisible 
                                  ? Icons.visibility_off 
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                              });
                            },
                          ),
                        ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideX(),
                        
                        const SizedBox(height: 20),
                        
                        // New Password Field
                        CustomTextField(
                          controller: _newPasswordController,
                          label: 'New Master Password',
                          obscureText: !_isNewPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a new password';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters long';
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isNewPasswordVisible 
                                  ? Icons.visibility_off 
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isNewPasswordVisible = !_isNewPasswordVisible;
                              });
                            },
                          ),
                        ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideX(),
                        
                        const SizedBox(height: 20),
                        
                        // Confirm Password Field
                        CustomTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm New Password',
                          obscureText: !_isConfirmPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your new password';
                            }
                            if (value != _newPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible 
                                  ? Icons.visibility_off 
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ).animate().fadeIn(duration: 600.ms, delay: 1000.ms).slideX(),
                        
                        const SizedBox(height: 40),
                        
                        // Password Requirements
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Password Requirements:',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text('• At least 8 characters long'),
                              const Text('• Use a combination of letters, numbers, and symbols'),
                              const Text('• Avoid common passwords'),
                              const Text('• Don\'t reuse your current password'),
                            ],
                          ),
                        ).animate().fadeIn(duration: 600.ms, delay: 1200.ms),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Change Password Button
                  CustomButton(
                    text: 'Change Password',
                    onPressed: _isLoading ? null : _handleChangePassword,
                    isLoading: _isLoading,
                  ).animate().fadeIn(duration: 600.ms, delay: 1400.ms).slideY(),
                  
                  const SizedBox(height: 20),
                  
                  // Cancel Button
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ).animate().fadeIn(duration: 600.ms, delay: 1600.ms),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}