import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A modern glassmorphism-styled category filter chip.
/// Used in the home page for filtering passwords by category.
class CategoryFilterChip extends StatelessWidget {
  final String label;
  final String? icon;
  final IconData? iconData;
  final bool isSelected;
  final VoidCallback onSelected;
  final Color? selectedColor;

  const CategoryFilterChip({
    super.key,
    required this.label,
    this.icon,
    this.iconData,
    required this.isSelected,
    required this.onSelected,
    this.selectedColor,
  });

  IconData? _getIconDataFromString(String iconName) {
    switch (iconName) {
      // New icon name format
      case 'folder': return Icons.folder_rounded;
      case 'lock': return Icons.lock_rounded;
      case 'account_balance': return Icons.account_balance_rounded;
      case 'shopping_cart': return Icons.shopping_cart_rounded;
      case 'email': return Icons.email_rounded;
      case 'work': return Icons.work_rounded;
      case 'sports_esports': return Icons.sports_esports_rounded;
      case 'movie': return Icons.movie_rounded;
      case 'flight': return Icons.flight_rounded;
      case 'school': return Icons.school_rounded;
      case 'local_hospital': return Icons.local_hospital_rounded;
      case 'restaurant': return Icons.restaurant_rounded;
      case 'home': return Icons.home_rounded;
      case 'credit_card': return Icons.credit_card_rounded;
      case 'phone_android': return Icons.phone_android_rounded;
      case 'laptop': return Icons.laptop_rounded;
      case 'music_note': return Icons.music_note_rounded;
      case 'camera_alt': return Icons.camera_alt_rounded;
      case 'sports_soccer': return Icons.sports_soccer_rounded;
      case 'gps_fixed': return Icons.gps_fixed_rounded;
      case 'favorite': return Icons.favorite_rounded;
      case 'star': return Icons.star_rounded;
      case 'cloud': return Icons.cloud_rounded;
      case 'wifi': return Icons.wifi_rounded;
      case 'bluetooth': return Icons.bluetooth_rounded;
      case 'security': return Icons.security_rounded;
      case 'vpn_key': return Icons.vpn_key_rounded;
      case 'fingerprint': return Icons.fingerprint_rounded;
      case 'shield': return Icons.shield_rounded;
      case 'verified_user': return Icons.verified_user_rounded;
      // Old emoji format fallback
      case '🏦': return Icons.account_balance_rounded;
      case '🛒': return Icons.shopping_cart_rounded;
      case '📧': return Icons.email_rounded;
      case '📱': return Icons.phone_android_rounded;
      case '💼': return Icons.work_rounded;
      case '🎮': return Icons.sports_esports_rounded;
      case '🎬': return Icons.movie_rounded;
      case '✈️': return Icons.flight_rounded;
      case '🎓': return Icons.school_rounded;
      case '🏥': return Icons.local_hospital_rounded;
      case '🍔': return Icons.restaurant_rounded;
      case '🏠': return Icons.home_rounded;
      case '🔒': return Icons.lock_rounded;
      case '💳': return Icons.credit_card_rounded;
      case '💻': return Icons.laptop_rounded;
      case '🎵': return Icons.music_note_rounded;
      case '📷': return Icons.camera_alt_rounded;
      case '⚽': return Icons.sports_soccer_rounded;
      case '❤️': return Icons.favorite_rounded;
      case '🎯': return Icons.gps_fixed_rounded;
      case '📁': return Icons.folder_rounded;
      default: return Icons.folder_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = selectedColor ?? AppColors.primaryBlueLight;
    final resolvedIconData = iconData ?? (icon != null ? _getIconDataFromString(icon!) : null);
    
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? effectiveColor.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? effectiveColor.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (resolvedIconData != null) ...[
                    Icon(
                      resolvedIconData,
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
}