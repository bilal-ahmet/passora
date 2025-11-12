import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../domain/entities/password_entity.dart';
import 'edit_password_page.dart';

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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPasswordPage(password: widget.password),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.password.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _editPassword,
            tooltip: AppStrings.edit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card with Icon and Title
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getCategoryColor(),
                    _getCategoryColor().withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
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
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.password.category.displayName,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Information',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
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
                      'Last Accessed',
                      AppUtils.formatRelativeTime(widget.password.lastAccessed!),
                    ),
                  ],
                ],
              ),
            )
                .animate(delay: 350.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 32),

            // Edit Button
            CustomButton(
              text: AppStrings.edit,
              onPressed: _editPassword,
              width: double.infinity,
              icon: Icons.edit_outlined,
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

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    bool canCopy = false,
    bool isUrl = false,
    bool isMultiline = false,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.grey600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.grey600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (canCopy)
                IconButton(
                  icon: const Icon(
                    Icons.copy_outlined,
                    size: 18,
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isUrl ? AppColors.primaryBlue : null,
              decoration: isUrl ? TextDecoration.underline : null,
            ),
            maxLines: isMultiline ? null : 1,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordCard() {
    final strength = AppUtils.calculatePasswordStrength(widget.password.password);
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lock_outline,
                color: AppColors.grey600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Password',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.grey600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility_off : Icons.visibility,
                  size: 18,
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
                icon: const Icon(
                  Icons.copy_outlined,
                  size: 18,
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontFamily: _showPassword ? 'monospace' : null,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${AppStrings.passwordStrength}: ',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.grey600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStrengthColor(strength).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  strength.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _getStrengthColor(strength),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataItem(String label, String value) {
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
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor() {
    switch (widget.password.category) {
      case PasswordCategory.social:
        return AppColors.primaryBlue;
      case PasswordCategory.banking:
        return AppColors.success;
      case PasswordCategory.email:
        return AppColors.warning;
      case PasswordCategory.shopping:
        return AppColors.error;
      case PasswordCategory.work:
        return AppColors.secondaryTeal;
      case PasswordCategory.entertainment:
        return const Color(0xFF9C27B0);
      case PasswordCategory.other:
        return AppColors.grey600;
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