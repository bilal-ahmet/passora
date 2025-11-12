import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/password_strength_indicator.dart';

class PasswordGeneratorBottomSheet extends StatefulWidget {
  final Function(String) onPasswordGenerated;

  const PasswordGeneratorBottomSheet({
    super.key,
    required this.onPasswordGenerated,
  });

  @override
  State<PasswordGeneratorBottomSheet> createState() => _PasswordGeneratorBottomSheetState();
}

class _PasswordGeneratorBottomSheetState extends State<PasswordGeneratorBottomSheet> {
  int _length = 16;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  bool _excludeSimilar = false;
  String _generatedPassword = '';

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    final password = AppUtils.generatePassword(
      length: _length,
      includeUppercase: _includeUppercase,
      includeLowercase: _includeLowercase,
      includeNumbers: _includeNumbers,
      includeSymbols: _includeSymbols,
      excludeSimilar: _excludeSimilar,
    );
    
    setState(() {
      _generatedPassword = password;
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatedPassword));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.passwordCopied),
        duration: Duration(seconds: 1),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _usePassword() {
    widget.onPasswordGenerated(_generatedPassword);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.passwordGenerator,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Generated Password Display
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.grey50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.grey200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SelectableText(
                                  _generatedPassword,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy_outlined),
                                onPressed: _copyToClipboard,
                                tooltip: 'Copy password',
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh_outlined),
                                onPressed: _generatePassword,
                                tooltip: 'Generate new password',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          PasswordStrengthIndicator(password: _generatedPassword),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Length Slider
                    _buildSectionTitle('Password Length'),
                    Row(
                      children: [
                        Text(
                          '4',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: _length.toDouble(),
                            min: 4,
                            max: 128,
                            divisions: 124,
                            activeColor: AppColors.primaryBlue,
                            label: _length.toString(),
                            onChanged: (value) {
                              setState(() {
                                _length = value.round();
                              });
                              _generatePassword();
                            },
                          ),
                        ),
                        Text(
                          '128',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _length.toString(),
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Character Options
                    _buildSectionTitle('Character Types'),
                    _buildSwitchTile(
                      'Uppercase Letters (A-Z)',
                      'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                      _includeUppercase,
                      (value) {
                        setState(() => _includeUppercase = value);
                        _generatePassword();
                      },
                    ),
                    _buildSwitchTile(
                      'Lowercase Letters (a-z)',
                      'abcdefghijklmnopqrstuvwxyz',
                      _includeLowercase,
                      (value) {
                        setState(() => _includeLowercase = value);
                        _generatePassword();
                      },
                    ),
                    _buildSwitchTile(
                      'Numbers (0-9)',
                      '0123456789',
                      _includeNumbers,
                      (value) {
                        setState(() => _includeNumbers = value);
                        _generatePassword();
                      },
                    ),
                    _buildSwitchTile(
                      'Symbols (!@#\$%^&*)',
                      '!@#\$%^&*()_+-=[]{}|;:,.<>?',
                      _includeSymbols,
                      (value) {
                        setState(() => _includeSymbols = value);
                        _generatePassword();
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildSectionTitle('Options'),
                    _buildSwitchTile(
                      'Exclude Similar Characters',
                      'Avoid 0, O, l, I, 1 for better readability',
                      _excludeSimilar,
                      (value) {
                        setState(() => _excludeSimilar = value);
                        _generatePassword();
                      },
                    ),

                    const SizedBox(height: 32),

                    // Use Password Button
                    CustomButton(
                      text: 'Use This Password',
                      onPressed: _generatedPassword.isNotEmpty ? _usePassword : null,
                      width: double.infinity,
                      icon: Icons.check,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.grey800,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.grey600,
            fontFamily: subtitle.length > 30 ? null : 'monospace',
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryBlue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}