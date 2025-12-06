import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class StatisticsDialog extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const StatisticsDialog({
    super.key,
    required this.statistics,
  });

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
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Text(
                            cat['categoryIcon'] as String? ?? '📁',
                            style: const TextStyle(fontSize: 24),
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
                              color: _parseColor(cat['categoryColor'] as String? ?? '#999999').withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              count.toString(),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _parseColor(cat['categoryColor'] as String? ?? '#999999'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  
                  // Uncategorized
                  if (uncategorizedCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const Text(
                            '📂',
                            style: TextStyle(fontSize: 24),
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
                              color: Colors.grey.withOpacity(0.15),
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
        color: color.withOpacity(0.1),
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
