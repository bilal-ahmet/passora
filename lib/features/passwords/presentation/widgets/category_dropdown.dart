import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/password_entity.dart';

class CategoryDropdown extends StatelessWidget {
  final PasswordCategory selectedCategory;
  final ValueChanged<PasswordCategory> onChanged;

  const CategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.grey700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.grey300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<PasswordCategory>(
              value: selectedCategory,
              onChanged: (category) {
                if (category != null) {
                  onChanged(category);
                }
              },
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.grey600,
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey900,
              ),
              dropdownColor: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              items: PasswordCategory.values.map((category) {
                return DropdownMenuItem<PasswordCategory>(
                  value: category,
                  child: Row(
                    children: [
                      Text(
                        category.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        category.displayName,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}