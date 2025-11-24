import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_utils.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showLabel;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final strength = AppUtils.calculatePasswordStrength(password);
    final strengthColor = _getStrengthColor(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Bar
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.grey200,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: strength.score,
            child: Container(
              decoration: BoxDecoration(
                color: strengthColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        
        if (showLabel && password.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            strength.labelKey.tr(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: strengthColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
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