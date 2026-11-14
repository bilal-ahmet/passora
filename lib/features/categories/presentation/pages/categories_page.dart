import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/gradient_scaffold.dart';
import '../../data/models/category_model.dart';
import '../cubit/categories_cubit.dart';
import 'add_category_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  void initState() {
    super.initState();
    context.read<CategoriesCubit>().loadCategories();
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
              child: BlocListener<CategoriesCubit, CategoriesState>(
                listener: (context, state) {
                  if (state is CategoriesError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message.tr()),
                        backgroundColor: AppColors.error,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  } else if (state is CategoryDeleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('category_deleted'.tr()),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                child: BlocBuilder<CategoriesCubit, CategoriesState>(
                  builder: (context, state) {
                    if (state is CategoriesLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }
                    
                    if (state is CategoriesError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Error loading categories',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              style: TextStyle(color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.fabGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  context.read<CategoriesCubit>().loadCategories();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: const Text('Retry', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    if (state is CategoriesLoaded) {
                      final categories = state.categories;
                      
                      if (categories.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: 64,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'no_categories_found'.tr(),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return _buildCategoryCard(category);
                        },
                      );
                    }
                    
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildGradientFAB(),
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
            'categories'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientFAB() {
    return Container(
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
      child: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCategoryPage(),
            ),
          );
          
          if (result == true && mounted) {
            context.read<CategoriesCubit>().loadCategories();
          }
        },
        icon: const Icon(Icons.add, size: 20, color: Colors.white),
        label: Text(
          'add_category'.tr(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _parseColor(category.color).withValues(alpha: 0.4),
                    _parseColor(category.color).withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _parseColor(category.color).withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _parseColor(category.color).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _getIconData(category.icon),
                  size: 24,
                  color: _parseColor(category.color),
                ),
              ),
            ),
            title: Text(
              category.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              category.isDefault ? 'default_category'.tr() : 'custom_category'.tr(),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            trailing: category.isDefault
                ? null
                : PopupMenuButton<String>(
                    onSelected: (value) async {
                      switch (value) {
                        case 'edit':
                          await _onEditCategory(category);
                          break;
                        case 'delete':
                          await _onDeleteCategory(category);
                          break;
                      }
                    },
                    color: AppColors.cardBackground,
                    itemBuilder: (context) {
                      final isBanking = category.name.toLowerCase() == 'bankacılık' || 
                                       category.name.toLowerCase() == 'banking';
                      
                      return [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              const Text('Edit', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        if (!isBanking)
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: AppColors.error),
                                const SizedBox(width: 8),
                                Text('delete_category'.tr(), style: TextStyle(color: AppColors.error)),
                              ],
                            ),
                          ),
                      ];
                    },
                    child: Icon(Icons.more_vert, color: AppColors.textSecondary),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _onEditCategory(CategoryModel category) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCategoryPage(editingCategory: category),
      ),
    );
    
    if (result == true && mounted) {
      context.read<CategoriesCubit>().loadCategories();
    }
  }

  Future<void> _onDeleteCategory(CategoryModel category) async {
    // Extra protection: prevent deleting Banking category
    if (category.name.toLowerCase() == 'bankacılık' || 
        category.name.toLowerCase() == 'banking') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('banking_category_cannot_be_deleted'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_category'.tr()),
        content: Text('delete_category_confirmation_message'.tr(namedArgs: {'name': category.name})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete, size: 16),
                SizedBox(width: 4),
                Text(
                  'Delete',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true && category.id != null && mounted) {
      context.read<CategoriesCubit>().deleteCategory(category.id!);
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
      return Colors.grey;
    }
  }

  IconData _getIconData(String iconName) {
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
}