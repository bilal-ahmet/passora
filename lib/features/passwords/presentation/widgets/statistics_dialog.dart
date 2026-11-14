import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class StatisticsDialog extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const StatisticsDialog({
    super.key,
    required this.statistics,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
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
      // Fallback for old emoji format
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
      case '📂': return Icons.folder_open_rounded;
      default: return Icons.folder_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = statistics['totalCount'] as int? ?? 0;
    final favoriteCount = statistics['favoriteCount'] as int? ?? 0;
    final categoryCounts = statistics['categoryCounts'] as List<dynamic>? ?? [];
    final uncategorizedCount = statistics['uncategorizedCount'] as int? ?? 0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'statistics'.tr(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Total and Favorites
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        icon: Icons.lock,
                        label: 'total_passwords'.tr(),
                        value: totalCount.toString(),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        icon: Icons.star,
                        label: 'favorites'.tr(),
                        value: favoriteCount.toString(),
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                
                if (categoryCounts.isNotEmpty || uncategorizedCount > 0) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 20),
                  
                  Text(
                    'by_category'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Category counts
                  ...categoryCounts.map((cat) {
                    final count = cat['count'] as int? ?? 0;
                    if (count == 0) return const SizedBox.shrink();
                    
                    final iconString = cat['categoryIcon'] as String? ?? 'folder';
                    final categoryColor = _parseColor(cat['categoryColor'] as String? ?? '#999999');
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getIconData(iconString),
                              size: 22,
                              color: categoryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              cat['categoryName'] as String? ?? 'Unknown',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              count.toString(),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: categoryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  
                  // Uncategorized
                  if (uncategorizedCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.folder_open_rounded,
                              size: 22,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'uncategorized'.tr(),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              uncategorizedCount.toString(),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }
}
