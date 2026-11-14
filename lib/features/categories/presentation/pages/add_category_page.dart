import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/gradient_scaffold.dart';
import '../../data/models/category_model.dart';
import '../cubit/categories_cubit.dart';

class AddCategoryPage extends StatefulWidget {
  final CategoryModel? editingCategory;
  
  const AddCategoryPage({super.key, this.editingCategory});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String _selectedIcon = 'folder';
  String _selectedColor = '#2196F3';
  bool _isLoading = false;

  // Modern icon names mapped to Material Icons
  final List<String> _availableIcons = [
    'folder', 'lock', 'account_balance', 'shopping_cart', 'email',
    'work', 'sports_esports', 'movie', 'flight', 'school',
    'local_hospital', 'restaurant', 'home', 'credit_card', 'phone_android',
    'laptop', 'music_note', 'camera_alt', 'sports_soccer', 'gps_fixed',
    'favorite', 'star', 'cloud', 'wifi', 'bluetooth',
    'security', 'vpn_key', 'fingerprint', 'shield', 'verified_user',
  ];

  // Map icon names to IconData
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
      default: return Icons.folder_rounded;
    }
  }

  final List<String> _availableColors = [
    '#2196F3', '#4CAF50', '#FF9800', '#F44336', '#9C27B0', '#673AB7',
    '#3F51B5', '#009688', '#795548', '#607D8B', '#E91E63', '#FF5722',
    '#8BC34A', '#CDDC39', '#FFEB3B', '#FFC107', '#00BCD4', '#9E9E9E'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editingCategory != null) {
      _nameController.text = widget.editingCategory!.name;
      _selectedIcon = widget.editingCategory!.icon;
      _selectedColor = widget.editingCategory!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Preview Card
                      _buildPreviewCard(),
                      const SizedBox(height: 24),
                      
                      // Name Field
                      Text(
                        'category_name'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.glassWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: TextFormField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'enter_category_name'.tr(),
                                hintStyle: TextStyle(color: AppColors.textTertiary),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                prefixIcon: Icon(Icons.label, color: AppColors.textSecondary),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'please_enter_category_name'.tr();
                                }
                                if (value.trim().length < 2) {
                                  return 'category_name_min_length'.tr();
                                }
                                return null;
                              },
                              onChanged: (value) => setState(() {}),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Icon Selection
                      Text(
                        'category_icon'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildIconSelector(),
                      const SizedBox(height: 24),
                      
                      // Color Selection
                      Text(
                        'category_color'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildColorSelector(),
                      const SizedBox(height: 32),
                      
                      // Save Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppColors.fabGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentPink.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveCategory,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      widget.editingCategory != null ? Icons.update : Icons.add,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.editingCategory != null ? 'update_category'.tr() : 'create_category'.tr(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.glassWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Title
          Text(
            widget.editingCategory != null ? 'edit_category'.tr() : 'add_category'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    final color = _parseColor(_selectedColor);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.3),
                color.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.4),
                      color.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _getIconData(_selectedIcon),
                    size: 24,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text.isEmpty ? 'category_name_preview'.tr() : _nameController.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Preview',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _availableIcons.length,
            itemBuilder: (context, index) {
              final iconName = _availableIcons[index];
              final isSelected = iconName == _selectedIcon;
              final color = _parseColor(_selectedColor);
              
              return GestureDetector(
                onTap: () => setState(() => _selectedIcon = iconName),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isSelected 
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withValues(alpha: 0.4),
                              color.withValues(alpha: 0.2),
                            ],
                          )
                        : null,
                    color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? color.withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.1),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Center(
                    child: Icon(
                      _getIconData(iconName),
                      size: 22,
                      color: isSelected ? color : Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _availableColors.length,
            itemBuilder: (context, index) {
              final color = _availableColors[index];
              final isSelected = color == _selectedColor;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  decoration: BoxDecoration(
                    color: _parseColor(color),
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected 
                        ? Border.all(color: Colors.white, width: 3)
                        : Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                  ),
                  child: isSelected 
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final category = CategoryModel(
        id: widget.editingCategory?.id,
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
        isDefault: false,
        createdAt: widget.editingCategory?.createdAt ?? now,
        updatedAt: now,
      );

      await context.read<CategoriesCubit>().saveCategory(category);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.editingCategory != null 
                  ? 'Category updated successfully'
                  : 'Category created successfully'
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Color _parseColor(String colorString) {
    try {
      String hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }
}