import 'package:flutter/material.dart';

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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Website Favicon/Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getCategoryColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        password.category.icon,
                        style: const TextStyle(fontSize: 24),
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
                          color: password.isFavorite ? AppColors.error : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          size: 20,
                        ),
                        onPressed: onToggleFavorite,
                        tooltip: password.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.copy_outlined,
                          size: 20,
                        ),
                        onPressed: onCopyPassword,
                        tooltip: 'Copy password',
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
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
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      password.category.displayName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getCategoryColor(),
                        fontWeight: FontWeight.w500,
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
    return password.website.isNotEmpty ? password.website : 'No website';
  }

  Color _getCategoryColor() {
    switch (password.category) {
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
        return const Color(0xFF9C27B0); // Purple
      case PasswordCategory.other:
        return AppColors.grey600;
    }
  }
}