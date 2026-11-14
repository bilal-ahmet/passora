import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../shared/widgets/gradient_scaffold.dart';
import '../../domain/entities/password_entity.dart';
import '../../data/models/password_model.dart';
import 'add_password_page.dart';

class PasswordDetailsPage extends StatefulWidget {
  final PasswordEntity password;

  const PasswordDetailsPage({
    super.key,
    required this.password,
  });

  @override
  State<PasswordDetailsPage> createState() => _PasswordDetailsPageState();
}

class _PasswordDetailsPageState extends State<PasswordDetailsPage> {
  bool _showPassword = false;

  void _copyToClipboard(String text, String message) async {
    print('=== SIMPLE COPY TEST ===');
    print('Copying: "$text"');
    
    // Farklı yöntemler deneyelim
    bool method1Success = false;
    bool method2Success = false;
    bool method3Success = false;
    
    // Method 1: Basic setData
    try {
      await Clipboard.setData(ClipboardData(text: text));
      final verify1 = await Clipboard.getData(Clipboard.kTextPlain);
      method1Success = verify1?.text == text;
      print('Method 1 (basic): ${method1Success ? "SUCCESS" : "FAILED"}');
    } catch (e) {
      print('Method 1 exception: $e');
    }
    
    // Method 2: With delay
    try {
      await Future.delayed(Duration(milliseconds: 100));
      await Clipboard.setData(ClipboardData(text: text));
      await Future.delayed(Duration(milliseconds: 100));
      final verify2 = await Clipboard.getData(Clipboard.kTextPlain);
      method2Success = verify2?.text == text;
      print('Method 2 (with delay): ${method2Success ? "SUCCESS" : "FAILED"}');
    } catch (e) {
      print('Method 2 exception: $e');
    }
    
    // Method 3: Alternative platform channel
    try {
      const platform = MethodChannel('flutter/platform');
      await platform.invokeMethod('Clipboard.setData', {'text': text});
      final verify3 = await Clipboard.getData(Clipboard.kTextPlain);
      method3Success = verify3?.text == text;
      print('Method 3 (platform channel): ${method3Success ? "SUCCESS" : "FAILED"}');
    } catch (e) {
      print('Method 3 exception: $e');
    }
    
    final overallSuccess = method1Success || method2Success || method3Success;
    print('Overall result: ${overallSuccess ? "SUCCESS" : "ALL METHODS FAILED"}');
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(overallSuccess 
            ? '$message (Method ${method1Success ? "1" : method2Success ? "2" : "3"} worked)' 
            : 'All copy methods failed'),
          duration: const Duration(seconds: 4),
          backgroundColor: overallSuccess ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      if (overallSuccess) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _editPassword() async {
    // Convert PasswordEntity to PasswordModel for editing
    final passwordModel = PasswordModel(
      id: int.tryParse(widget.password.id),
      title: widget.password.title,
      username: widget.password.username,
      password: widget.password.password,
      website: widget.password.website,
      notes: widget.password.notes,
      categoryId: null, // Will be set from category in AddPasswordPage
      createdAt: widget.password.createdAt,
      updatedAt: DateTime.now(),
    );
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPasswordPage(editingPassword: passwordModel),
      ),
    );

    if (result == 'deleted') {
      Navigator.pop(context, 'deleted');
    } else if (result == true) {
      Navigator.pop(context, true);
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card with Icon and Title
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _getCategoryColor().withValues(alpha: 0.4),
                                _getCategoryColor().withValues(alpha: 0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getCategoryColor().withValues(alpha: 0.5),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.password.category.icon,
                                    style: const TextStyle(fontSize: 40),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.password.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.password.category.displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: -0.3, end: 0),

                    const SizedBox(height: 24),

                    // Details Section
                    if (widget.password.website.isNotEmpty)
                      _buildDetailCard(
                        icon: Icons.language_outlined,
                        title: 'Website',
                        value: widget.password.website,
                        isUrl: true,
                        canCopy: true,
                      )
                          .animate(delay: 100.ms)
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: -0.3, end: 0),

                    if (widget.password.username.isNotEmpty)
                      _buildDetailCard(
                        icon: Icons.person_outline,
                        title: AppStrings.username,
                        value: widget.password.username,
                        canCopy: true,
                      )
                          .animate(delay: 150.ms)
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: -0.3, end: 0),

                    if (widget.password.email.isNotEmpty)
                      _buildDetailCard(
                        icon: Icons.email_outlined,
                        title: AppStrings.emailAddress,
                        value: widget.password.email,
                        canCopy: true,
                      )
                          .animate(delay: 200.ms)
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: -0.3, end: 0),

                    // Password Card
                    _buildPasswordCard()
                        .animate(delay: 250.ms)
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: -0.3, end: 0),

                    if (widget.password.notes.isNotEmpty)
                      _buildDetailCard(
                        icon: Icons.notes_outlined,
                        title: AppStrings.notes,
                        value: widget.password.notes,
                        isMultiline: true,
                        canCopy: true,
                      )
                          .animate(delay: 300.ms)
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: -0.3, end: 0),

                    const SizedBox(height: 24),

                    // Metadata Section
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.glassWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Information',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accentPink,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildMetadataItem(
                                      'Created',
                                      AppUtils.formatDate(widget.password.createdAt),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildMetadataItem(
                                      'Modified',
                                      AppUtils.formatDate(widget.password.updatedAt),
                                    ),
                                  ),
                                ],
                              ),
                              if (widget.password.lastAccessed != null) ...[
                                const SizedBox(height: 12),
                                _buildMetadataItem(
                                  'last_accessed'.tr(),
                                  AppUtils.formatRelativeTime(widget.password.lastAccessed!),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    )
                        .animate(delay: 350.ms)
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 32),

                    // Edit Button
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
                      child: ElevatedButton.icon(
                        onPressed: _editPassword,
                        icon: const Icon(Icons.edit_outlined, color: Colors.white),
                        label: Text(
                          AppStrings.edit,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    )
                        .animate(delay: 400.ms)
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 16),
                  ],
                ),
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
          Expanded(
            child: Text(
              widget.password.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Edit Button
          GestureDetector(
            onTap: _editPassword,
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
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    bool canCopy = false,
    bool isUrl = false,
    bool isMultiline = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (canCopy)
                    IconButton(
                      icon: Icon(
                        Icons.copy_outlined,
                        size: 18,
                        color: AppColors.accentPink,
                      ),
                      onPressed: () {
                        _copyToClipboard(value, '$title copied to clipboard');
                      },
                      tooltip: 'Copy $title',
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SelectableText(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isUrl ? AppColors.accentPink : Colors.white,
                  decoration: isUrl ? TextDecoration.underline : null,
                ),
                maxLines: isMultiline ? null : 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordCard() {
    final strength = AppUtils.calculatePasswordStrength(widget.password.password);
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Password',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                    tooltip: _showPassword ? AppStrings.hidePassword : AppStrings.showPassword,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.copy_outlined,
                      size: 18,
                      color: AppColors.accentPink,
                    ),
                    onPressed: () {
                      _copyToClipboard(widget.password.password, AppStrings.passwordCopied);
                    },
                    tooltip: AppStrings.copyPassword,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SelectableText(
                _showPassword ? widget.password.password : '•' * widget.password.password.length,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: _showPassword ? 'monospace' : null,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '${AppStrings.passwordStrength}: ',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStrengthColor(strength).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      strength.labelKey.tr(),
                      style: TextStyle(
                        color: _getStrengthColor(strength),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor() {
    switch (widget.password.category) {
      case PasswordCategory.social:
        return AppColors.categoryLavender; // Soft lavender for social
      case PasswordCategory.banking:
        return AppColors.success; // Soft green
      case PasswordCategory.email:
        return AppColors.categorySky; // Soft sky blue
      case PasswordCategory.shopping:
        return AppColors.categoryCoral; // Soft coral
      case PasswordCategory.work:
        return AppColors.categoryMint; // Soft mint
      case PasswordCategory.entertainment:
        return AppColors.categoryPurple; // Soft purple
      case PasswordCategory.other:
        return AppColors.categoryPeach; // Soft peach
    }
  }

  Color _getStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return AppColors.weak;
      case PasswordStrength.medium:
        return AppColors.medium;
      case PasswordStrength.strong:
        return AppColors.strong;
      case PasswordStrength.veryStrong:
        return AppColors.veryStrong;
    }
  }
}