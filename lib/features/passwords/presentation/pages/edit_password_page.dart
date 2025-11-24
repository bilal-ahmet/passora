import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/password_strength_indicator.dart';
import '../../domain/entities/password_entity.dart';
import '../cubit/passwords_cubit.dart';
import '../widgets/category_dropdown.dart';
import '../widgets/password_generator_bottom_sheet.dart';

class EditPasswordPage extends StatefulWidget {
  final PasswordEntity password;

  const EditPasswordPage({
    super.key,
    required this.password,
  });

  @override
  State<EditPasswordPage> createState() => _EditPasswordPageState();
}

class _EditPasswordPageState extends State<EditPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _websiteController;
  late final TextEditingController _notesController;

  final _titleFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _websiteFocusNode = FocusNode();
  final _notesFocusNode = FocusNode();

  late PasswordCategory _selectedCategory;
  late bool _isFavorite;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data
    _titleController = TextEditingController(text: widget.password.title);
    _usernameController = TextEditingController(text: widget.password.username);
    _emailController = TextEditingController(text: widget.password.email);
    _passwordController = TextEditingController(text: widget.password.password);
    _websiteController = TextEditingController(text: widget.password.website);
    _notesController = TextEditingController(text: widget.password.notes);
    
    _selectedCategory = widget.password.category;
    _isFavorite = widget.password.isFavorite;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _websiteController.dispose();
    _notesController.dispose();

    _titleFocusNode.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _websiteFocusNode.dispose();
    _notesFocusNode.dispose();

    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Implement actual password updating
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pop(context, true); // Return true to indicate success
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _deletePassword() async {
    setState(() => _isLoading = true);

    try {
      // Delete password using cubit (convert String id to int)
      final passwordId = int.parse(widget.password.id);
      await context.read<PasswordsCubit>().deletePassword(passwordId);
      
      if (mounted) {
        // Pop until we're back at the home page (pop both edit and detail pages)
        Navigator.popUntil(context, (route) => route.isFirst);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.passwordDeleted),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete password: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _generatePassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PasswordGeneratorBottomSheet(
        onPasswordGenerated: (password) {
          setState(() {
            _passwordController.text = password;
          });
        },
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_password_title'.tr()),
        content: Text(
          'delete_confirmation'.tr(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePassword();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value.length < 4) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value != null && value.isNotEmpty && !AppUtils.isValidEmail(value)) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.editPassword),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? AppColors.error : null,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
            tooltip: _isFavorite ? 'remove_from_favorites'.tr() : 'add_to_favorites'.tr(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text('delete_password_title'.tr(), style: const TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'password_information'.tr(),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          'created_date'.tr(),
                          AppUtils.formatDate(widget.password.createdAt),
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'last_modified'.tr(),
                          AppUtils.formatDate(widget.password.updatedAt),
                        ),
                      ),
                    ],
                  ),
                  if (widget.password.lastAccessed != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoItem(
                      'last_accessed'.tr(),
                      AppUtils.formatRelativeTime(widget.password.lastAccessed!),
                    ),
                  ],
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: -0.3, end: 0),

            // Title Field
            CustomTextField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              label: 'Title *',
              hint: 'e.g., Facebook, Gmail, Bank Account',
              prefixIcon: Icons.title_outlined,
              validator: _validateTitle,
              textCapitalization: TextCapitalization.words,
            )
                .animate(delay: 50.ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: -0.3, end: 0),

            const SizedBox(height: 16),

            // Website Field
            CustomTextField(
              controller: _websiteController,
              focusNode: _websiteFocusNode,
              label: 'Website/URL',
              hint: 'https://example.com',
              prefixIcon: Icons.language_outlined,
              keyboardType: TextInputType.url,
            )
                .animate(delay: 100.ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: -0.3, end: 0),

            const SizedBox(height: 16),

            // Username Field
            CustomTextField(
              controller: _usernameController,
              focusNode: _usernameFocusNode,
              label: AppStrings.username,
              hint: 'Your username or phone number',
              prefixIcon: Icons.person_outline,
            )
                .animate(delay: 150.ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: -0.3, end: 0),

            const SizedBox(height: 16),

            // Email Field
            CustomTextField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              label: AppStrings.emailAddress,
              hint: 'your.email@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            )
                .animate(delay: 200.ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: -0.3, end: 0),

            const SizedBox(height: 16),

            // Password Field
            CustomTextField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              label: 'Password *',
              hint: 'Enter or generate a secure password',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              validator: _validatePassword,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.grey600,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.auto_awesome,
                      color: AppColors.primaryBlue,
                    ),
                    onPressed: _generatePassword,
                    tooltip: AppStrings.generatePassword,
                  ),
                ],
              ),
              onChanged: (value) {
                setState(() {}); // Trigger rebuild for password strength
              },
            )
                .animate(delay: 250.ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: -0.3, end: 0),

            // Password Strength Indicator
            if (_passwordController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              PasswordStrengthIndicator(
                password: _passwordController.text,
              )
                  .animate()
                  .fadeIn(duration: 200.ms)
                  .slideY(begin: -0.3, end: 0),
            ],

            const SizedBox(height: 16),

            // Category Dropdown
            CategoryDropdown(
              selectedCategory: _selectedCategory,
              onChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            )
                .animate(delay: 300.ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: -0.3, end: 0),

            const SizedBox(height: 16),

            // Notes Field
            CustomTextField(
              controller: _notesController,
              focusNode: _notesFocusNode,
              label: AppStrings.notes,
              hint: 'Additional notes (optional)',
              prefixIcon: Icons.notes_outlined,
              maxLines: 3,
              minLines: 1,
            )
                .animate(delay: 350.ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: -0.3, end: 0),

            const SizedBox(height: 32),

            // Save Button
            CustomButton(
              text: 'save_changes'.tr(),
              onPressed: _isLoading ? null : _saveChanges,
              isLoading: _isLoading,
              width: double.infinity,
              icon: Icons.save_outlined,
            )
                .animate(delay: 400.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.grey600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}