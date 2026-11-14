import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/entities/password_entity.dart';

/// A modern glassmorphism-styled password card for PasswordEntity.
/// This is the entity-based version of the password card.
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // Diagonal gradient overlay
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            _getCategoryColor().withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon container
                            _buildIconContainer(),
                            const SizedBox(width: 14),
                            
                            // Title, subtitle and category
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title
                                  Text(
                                    password.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  
                                  // Category badge
                                  _buildCategoryBadge(),
                                  const SizedBox(height: 6),
                                  
                                  // Username/email
                                  Text(
                                    password.username.isNotEmpty 
                                        ? password.username 
                                        : password.email,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            
                            // Actions column
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Favorite star
                                    GestureDetector(
                                      onTap: onToggleFavorite,
                                      child: Icon(
                                        Icons.star,
                                        color: password.isFavorite 
                                            ? Colors.amber 
                                            : Colors.white.withValues(alpha: 0.3),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    
                                    // Copy button
                                    GestureDetector(
                                      onTap: onCopyPassword,
                                      child: Icon(
                                        Icons.copy_outlined,
                                        color: Colors.white.withValues(alpha: 0.6),
                                        size: 22,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 36),
                                
                                // Last accessed
                                if (password.lastAccessed != null)
                                  Text(
                                    AppUtils.formatRelativeTime(password.lastAccessed!),
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: _getCategoryColor().withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _getCategoryColor().withValues(alpha: 0.3),
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
      ),
    );
  }

  Widget _buildCategoryBadge() {
    final badgeColor = _getCategoryColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        password.category.displayName,
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (password.category) {
      case PasswordCategory.social:
        return AppColors.categoryLavender;
      case PasswordCategory.banking:
        return AppColors.badgeGreen;
      case PasswordCategory.email:
        return AppColors.categorySky;
      case PasswordCategory.shopping:
        return AppColors.badgePurple;
      case PasswordCategory.work:
        return AppColors.badgeBlue;
      case PasswordCategory.entertainment:
        return AppColors.badgeOrange;
      case PasswordCategory.other:
        return AppColors.primaryBlueLight;
    }
  }
}