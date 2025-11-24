import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/entities/password_entity.dart';

class PasswordCard extends StatelessWidget {
  final PasswordEntity password;
  final VoidCallback onTap;
  final VoidCallback onCopyPassword;
  final VoidCallback onToggleFavorite;

  const PasswordCard({
    super.key,
    required this.password,
    required this.onTap,
    required this.onCopyPassword,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Website Favicon/Icon - More rounded, softer shadow
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getCategoryColor().withValues(alpha: 0.15),
                          _getCategoryColor().withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getCategoryColor().withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        password.category.icon,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Title and Website
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          password.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getDisplayDomain(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          password.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: password.isFavorite ? AppColors.categoryPink : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                          size: 22,
                        ),
                        onPressed: onToggleFavorite,
                        tooltip: password.isFavorite ? 'remove_from_favorites'.tr() : 'add_to_favorites'.tr(),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.copy_outlined,
                          size: 22,
                          color: AppColors.primaryBlue,
                        ),
                        onPressed: onCopyPassword,
                        tooltip: 'copy_password'.tr(),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Username/Email
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      password.username.isNotEmpty ? password.username : password.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Bottom Row: Category and Last Accessed
              Row(
                children: [
                  // Category Badge - More modern pill style
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getCategoryColor().withValues(alpha: 0.15),
                          _getCategoryColor().withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getCategoryColor().withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      password.category.displayName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getCategoryColor(),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Last Accessed
                  if (password.lastAccessed != null) ...[
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppUtils.formatRelativeTime(password.lastAccessed!),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDisplayDomain() {
    if (password.website.isNotEmpty) {
      final domain = AppUtils.extractDomain(password.website);
      if (domain != null) {
        return domain;
      }
    }
    return password.website.isNotEmpty ? password.website : 'no_website'.tr();
  }

  Color _getCategoryColor() {
    switch (password.category) {
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
}