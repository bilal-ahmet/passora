import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CategoryFilterChip extends StatelessWidget {
  final String label;
  final String? icon;
  final bool isSelected;
  final VoidCallback onSelected;

  const CategoryFilterChip({
    super.key,
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Text(
              icon!,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.grey700,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primaryBlue,
      backgroundColor: AppColors.grey100,
      checkmarkColor: AppColors.white,
      side: BorderSide(
        color: isSelected ? AppColors.primaryBlue : AppColors.grey300,
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelPadding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      elevation: 0,
      pressElevation: 1,
    );
  }
}