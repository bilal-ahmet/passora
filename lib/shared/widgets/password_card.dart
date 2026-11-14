import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../../features/passwords/data/models/password_model.dart';
import '../../features/categories/data/models/category_model.dart';
import '../../core/theme/app_colors.dart';

/// Pixel-perfect modern glassmorphism password card with diagonal gradient effect.
/// Matches the design reference with:
/// - Frosted glass blur effect
/// - Diagonal color gradient on the right side
/// - Premium neon gradient aesthetics
/// - Professional typography (Google Fonts)
class PasswordCard extends StatelessWidget {
  final PasswordModel password;
  final VoidCallback onTap;
  final Future<void> Function() onEdit;
  final Future<void> Function() onDelete;
  final Future<void> Function()? onToggleFavorite;
  final CategoryModel? category;

  const PasswordCard({
    super.key,
    required this.password,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onToggleFavorite,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = _getCategoryColor();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 130, // Increased to accommodate the layered effect
      child: Stack(
        children: [
          // Layer 1: Bottom Colored Blurred Layer with soft shadow
          Positioned(
            left: 16,
            right: 16,
            bottom: 5,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: baseColor.withValues(alpha: 0.35),
                    blurRadius: 16,
                    spreadRadius: -4,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(
                    color: baseColor.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
          ),

          // Layer 2: Top Card with Semi-Transparent Background
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 120,
            child: GestureDetector(
              onTap: onTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      // Semi-transparent background to let the colored layer show through
                      color: const Color(0xFF1A1830).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        // Subtle category color tint on border
                        color: Color.lerp(
                          Colors.white.withValues(alpha: 0.15),
                          baseColor.withValues(alpha: 0.3),
                          1.5,
                        )!,
                        width: 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Left: Icon Box with gradient
                          _buildIconBox(baseColor),
                          const SizedBox(width: 14),

                          // Middle: Text Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Title - Bold and prominent
                                Text(
                                  password.title,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),

                                // Category Badge - Premium look
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: baseColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: baseColor.withValues(alpha: 0.4),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    category?.name ?? 'General',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Subtitle/Username - Muted
                                Text(
                                  password.username,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Diagonal Divider (/)
                          Transform.rotate(
                            angle: 0.35, // ~20 degrees tilt to the right
                            child: Container(
                              width: 1,
                              height: 80,
                              margin: const EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.0),
                                    Colors.white.withValues(alpha: 0.25),
                                    Colors.white.withValues(alpha: 0.25),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                  stops: const [0.0, 0.2, 0.8, 1.0],
                                ),
                              ),
                            ),
                          ),

                          // Right: Actions & Date with balanced padding
                          SizedBox(
                            width: 70,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Top: Actions Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Favorite Star (outline style for consistency)
                                    if (onToggleFavorite != null)
                                      GestureDetector(
                                        onTap: () async {
                                          await onToggleFavorite!();
                                        },
                                        child: Icon(
                                          password.isFavorite
                                              ? Icons.star_rounded
                                              : Icons.star_outline_rounded,
                                          color: password.isFavorite
                                              ? const Color(0xFFFFD700)
                                              : Colors.white.withValues(alpha: 0.35),
                                          size: 22,
                                        ),
                                      ),
                                    const SizedBox(width: 6),
                                    // More Menu
                                    _buildMoreMenu(context),
                                  ],
                                ),

                                // Bottom: Date - Well spaced
                                Text(
                                  _formatDateFull(password.updatedAt),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withValues(alpha: 0.45),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
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
            ),
          ),
        ],
      ),
    );
  }

  // Build the icon box with enhanced glassmorphism and consistent icon style
  Widget _buildIconBox(Color baseColor) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.08),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.15),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Icon(
        _getIconForCategory(),
        color: Colors.white.withValues(alpha: 0.9),
        size: 26,
      ),
    );
  }

  Widget _buildMoreMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'copy':
            _copyToClipboard(context);
            break;
          case 'favorite':
            if (onToggleFavorite != null) {
              await onToggleFavorite!();
            }
            break;
          case 'edit':
            await onEdit();
            break;
          case 'delete':
            await onDelete();
            break;
        }
      },
      color: const Color(0xFF1A1547),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1),
      ),
      offset: const Offset(0, 40),
      itemBuilder: (context) => [
        _buildPopupMenuItem(
          value: 'copy',
          icon: Icons.copy_rounded,
          label: 'copy'.tr(),
        ),
        if (onToggleFavorite != null)
          _buildPopupMenuItem(
            value: 'favorite',
            icon: password.isFavorite
                ? Icons.star_rounded
                : Icons.star_outline_rounded,
            label: password.isFavorite
                ? 'remove_from_favorites'.tr()
                : 'add_to_favorites'.tr(),
            iconColor: password.isFavorite ? Colors.amber : null,
          ),
        _buildPopupMenuItem(
          value: 'edit',
          icon: Icons.edit_rounded,
          label: 'edit'.tr(),
        ),
        _buildPopupMenuItem(
          value: 'delete',
          icon: Icons.delete_rounded,
          label: 'delete'.tr(),
          iconColor: AppColors.error,
          textColor: AppColors.error,
        ),
      ],
      child: Icon(
        Icons.more_horiz_rounded,
        color: Colors.white.withValues(alpha: 0.6),
        size: 24,
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required String label,
    Color? iconColor,
    Color? textColor,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: iconColor ?? Colors.white.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: textColor ?? Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: password.password)).then((_) {
      Clipboard.getData(Clipboard.kTextPlain).then((clipData) {
        final readText = clipData?.text ?? '';
        final success = readText == password.password;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'copied_to_clipboard'.tr() : 'copy_failed'.tr(),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: success
                ? AppColors.success.withValues(alpha: 0.9)
                : AppColors.error.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        if (success) {
          HapticFeedback.lightImpact();
        }
      });
    });
  }

  Color _getCategoryColor() {
    if (category != null) {
      return _parseColor(category!.color);
    }

    // Default color based on title keywords
    final lowerTitle = password.title.toLowerCase();

    if (lowerTitle.contains('bank') || lowerTitle.contains('banka')) {
      return AppColors.badgeGreen;
    } else if (lowerTitle.contains('shop') ||
        lowerTitle.contains('amazon') ||
        lowerTitle.contains('alışveriş')) {
      return AppColors.badgePurple;
    } else if (lowerTitle.contains('facebook') ||
        lowerTitle.contains('instagram') ||
        lowerTitle.contains('twitter') ||
        lowerTitle.contains('social')) {
      return AppColors.badgePink;
    } else if (lowerTitle.contains('work') ||
        lowerTitle.contains('iş') ||
        lowerTitle.contains('office')) {
      return AppColors.badgeBlue;
    } else if (lowerTitle.contains('netflix') ||
        lowerTitle.contains('spotify') ||
        lowerTitle.contains('youtube')) {
      return AppColors.badgeOrange;
    }

    return AppColors.primaryBlueLight;
  }

  IconData _getIconForCategory() {
    if (category != null) {
      final icon = category!.icon;
      // New icon name format
      switch (icon) {
        case 'folder':
          return Icons.folder_rounded;
        case 'lock':
          return Icons.lock_rounded;
        case 'account_balance':
          return Icons.account_balance_rounded;
        case 'shopping_cart':
          return Icons.shopping_cart_rounded;
        case 'email':
          return Icons.email_rounded;
        case 'work':
          return Icons.work_rounded;
        case 'sports_esports':
          return Icons.sports_esports_rounded;
        case 'movie':
          return Icons.movie_rounded;
        case 'flight':
          return Icons.flight_rounded;
        case 'school':
          return Icons.school_rounded;
        case 'local_hospital':
          return Icons.local_hospital_rounded;
        case 'restaurant':
          return Icons.restaurant_rounded;
        case 'home':
          return Icons.home_rounded;
        case 'credit_card':
          return Icons.credit_card_rounded;
        case 'phone_android':
          return Icons.phone_android_rounded;
        case 'laptop':
          return Icons.laptop_rounded;
        case 'music_note':
          return Icons.music_note_rounded;
        case 'camera_alt':
          return Icons.camera_alt_rounded;
        case 'sports_soccer':
          return Icons.sports_soccer_rounded;
        case 'gps_fixed':
          return Icons.gps_fixed_rounded;
        case 'favorite':
          return Icons.favorite_rounded;
        case 'star':
          return Icons.star_rounded;
        case 'cloud':
          return Icons.cloud_rounded;
        case 'wifi':
          return Icons.wifi_rounded;
        case 'bluetooth':
          return Icons.bluetooth_rounded;
        case 'security':
          return Icons.security_rounded;
        case 'vpn_key':
          return Icons.vpn_key_rounded;
        case 'fingerprint':
          return Icons.fingerprint_rounded;
        case 'shield':
          return Icons.shield_rounded;
        case 'verified_user':
          return Icons.verified_user_rounded;
      }
      // Fallback for old emoji format
      if (icon == '🏦') return Icons.account_balance_rounded;
      if (icon == '🛒') return Icons.shopping_cart_rounded;
      if (icon == '📧') return Icons.email_rounded;
      if (icon == '📱') return Icons.phone_android_rounded;
      if (icon == '💼') return Icons.work_rounded;
      if (icon == '🎮') return Icons.sports_esports_rounded;
      if (icon == '🎬') return Icons.movie_rounded;
      if (icon == '✈️') return Icons.flight_rounded;
      if (icon == '🎓') return Icons.school_rounded;
      if (icon == '🏥') return Icons.local_hospital_rounded;
      if (icon == '🍔') return Icons.restaurant_rounded;
      if (icon == '🏠') return Icons.home_rounded;
      if (icon == '🔒') return Icons.lock_rounded;
      if (icon == '💳') return Icons.credit_card_rounded;
      if (icon == '💻') return Icons.laptop_rounded;
      if (icon == '🎵') return Icons.music_note_rounded;
      if (icon == '📷') return Icons.camera_alt_rounded;
      if (icon == '⚽') return Icons.sports_soccer_rounded;
      if (icon == '❤️') return Icons.favorite_rounded;
      if (icon == '🎯') return Icons.gps_fixed_rounded;
    }

    final lowerTitle = password.title.toLowerCase();

    if (lowerTitle.contains('bank') || lowerTitle.contains('banka')) {
      return Icons.account_balance_rounded;
    } else if (lowerTitle.contains('facebook') ||
        lowerTitle.contains('social')) {
      return Icons.facebook_rounded;
    } else if (lowerTitle.contains('google') || lowerTitle.contains('gmail')) {
      return Icons.email_rounded;
    } else if (lowerTitle.contains('amazon') || lowerTitle.contains('shop')) {
      return Icons.shopping_cart_rounded;
    } else if (lowerTitle.contains('netflix') ||
        lowerTitle.contains('youtube')) {
      return Icons.play_circle_rounded;
    } else if (lowerTitle.contains('work') || lowerTitle.contains('office')) {
      return Icons.work_rounded;
    }

    return Icons.lock_rounded;
  }

  String _formatDateFull(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _parseColor(String colorString) {
    try {
      String hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return AppColors.primaryBlueLight;
    }
  }
}


