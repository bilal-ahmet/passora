import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../shared/widgets/password_card.dart';
import '../../../../shared/widgets/gradient_scaffold.dart';
import '../../../../shared/widgets/modern_app_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/password_model.dart';
import '../cubit/passwords_cubit.dart';
import '../widgets/category_filter_chip.dart';
import 'add_password_page.dart';
import '../../../categories/presentation/pages/categories_page.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showSearchResults = false;
  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  List<PasswordModel> _favoritePasswords = [];
  bool _showFavorites = true; // Favorileri başlangıçta göster

  @override
  void initState() {
    super.initState();
    // Load categories first, then passwords
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<CategoriesCubit>().loadCategories();
      await Future.delayed(
        const Duration(milliseconds: 100),
      ); // Small delay to ensure categories are loaded
      context.read<PasswordsCubit>().loadPasswords();
      _loadFavorites();
    });
  }

  Future<void> _loadFavorites() async {
    final favorites = await context
        .read<PasswordsCubit>()
        .getFavoritePasswords();
    if (mounted) {
      setState(() {
        _favoritePasswords = favorites;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _showSearchResults = value.isNotEmpty;
    });

    if (value.isNotEmpty) {
      context.read<PasswordsCubit>().searchPasswords(value);
    } else {
      context.read<PasswordsCubit>().loadPasswords();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _showSearchResults = false;
    });
    context.read<PasswordsCubit>().loadPasswords();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CategoriesCubit, CategoriesState>(
          listener: (context, state) {
            print('Categories state changed: ${state.runtimeType}');
            if (state is CategoriesLoaded) {
              print('Categories loaded: ${state.categories.length} categories');
              for (var cat in state.categories) {
                print('Category ID: ${cat.id}, Name: ${cat.name}');
              }
              setState(() {
                _categories = state.categories;
              });
              // Force rebuild password list after categories are loaded
              context.read<PasswordsCubit>().loadPasswords();
            }
          },
        ),
      ],
      child: GradientScaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Modern Header
              _buildModernHeader(),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: _buildSearchBar(),
              ),

              // Category filter chips
              _buildCategoryFilters(),

              const SizedBox(height: 8),

              // Content area
              Expanded(
                child: BlocConsumer<PasswordsCubit, PasswordsState>(
                  listener: (context, state) {
                    if (state is PasswordsLoaded) {
                      print(
                        'Passwords reloaded: ${state.passwords.length} items',
                      );
                      _loadFavorites();
                    }
                  },
                  builder: (context, state) {
                    if (state is PasswordsLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBlueLight,
                        ),
                      );
                    }

                    if (state is PasswordsError) {
                      return _buildErrorState(state.message);
                    }

                    if (state is PasswordsLoaded) {
                      final passwords = _filterPasswords(state.passwords);

                      if (passwords.isEmpty) {
                        return _buildEmptyState();
                      }

                      return _buildPasswordList(passwords);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _buildGradientFAB(),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Title - Left aligned
          Text(
            'PASSORA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),

          const Spacer(),

          // Action buttons
          Row(
            children: [
              GlassActionButton(
                icon: Icons.settings_outlined,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );

                  if (result == 'imported' && mounted) {
                    context.read<PasswordsCubit>().loadPasswords();
                  }
                },
              ),
              const SizedBox(width: 8),
              GlassActionButton(
                icon: Icons.grid_view_rounded,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoriesPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'search_passwords'.tr(),
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 50,
      child: _categories.isEmpty
          ? Center(
              child: Text(
                'Loading...',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              ),
            )
          : ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // All categories chip
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryFilterChip(
                    label: 'All',
                    isSelected: _selectedCategory == null && !_showFavorites,
                    onSelected: () {
                      setState(() {
                        _selectedCategory = null;
                        _showFavorites = false;
                      });
                    },
                  ),
                ),
                // Favorites chip
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryFilterChip(
                    label: 'favorites'.tr(),
                    iconData: Icons.favorite,
                    isSelected: _showFavorites,
                    selectedColor: Colors.pinkAccent,
                    onSelected: () {
                      setState(() {
                        _showFavorites = !_showFavorites;
                        if (_showFavorites) {
                          _selectedCategory = null;
                        }
                      });
                    },
                  ),
                ),
                // Category chips
                ..._categories.map((category) {
                  final isSelected = _selectedCategory?.id == category.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CategoryFilterChip(
                      label: category.name,
                      icon: category.icon,
                      isSelected: isSelected,
                      selectedColor: _parseColor(category.color),
                      onSelected: () {
                        setState(() {
                          _selectedCategory = isSelected ? null : category;
                          _showFavorites = false;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildPasswordList(List<PasswordModel> passwords) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: passwords.length,
      itemBuilder: (context, index) {
        final password = passwords[index];
        CategoryModel? category;
        if (password.categoryId != null && _categories.isNotEmpty) {
          try {
            category = _categories.firstWhere(
              (cat) => cat.id == password.categoryId,
            );
          } catch (e) {
            category = null;
          }
        }
        return PasswordCard(
          password: password,
          category: category,
          onTap: () => _onPasswordTap(password),
          onEdit: () => _onEditPassword(password),
          onDelete: () => _onDeletePassword(password),
          onToggleFavorite: () => _onToggleFavorite(password.id!),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 64,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _showSearchResults
                ? 'no_passwords_found'.tr()
                : 'no_passwords_yet'.tr(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showSearchResults
                ? 'Try a different search term'
                : 'add_first_password'.tr(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Error loading passwords',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              context.read<PasswordsCubit>().loadPasswords();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlueLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primaryBlueLight.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  color: AppColors.primaryBlueLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientFAB() {
    return GradientFAB(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddPasswordPage()),
        );

        if (result == true && mounted) {
          context.read<PasswordsCubit>().loadPasswords();
        }
      },
      label: 'add_password'.tr(),
      icon: Icons.add,
    );
  }

  void _onPasswordTap(PasswordModel password) async {
    _showPasswordDetails(password);
  }

  void _showPasswordDetails(PasswordModel password) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(password.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem('Username', password.username),
              _buildDetailItem('Password', password.password, isPassword: true),
              if (password.website != null && password.website!.isNotEmpty)
                _buildDetailItem('Website', password.website!),

              // Banking-specific fields
              if (password.cardHolderName != null &&
                  password.cardHolderName!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Divider(color: Theme.of(context).colorScheme.primary),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'banking_info'.tr(),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDetailItem(
                  'card_holder_name'.tr(),
                  password.cardHolderName!,
                ),
              ],

              if (password.cardNumber != null &&
                  password.cardNumber!.isNotEmpty)
                _buildDetailItem('card_number'.tr(), password.cardNumber!),

              if (password.expiryDate != null &&
                  password.expiryDate!.isNotEmpty)
                _buildDetailItem('expiry_date'.tr(), password.expiryDate!),

              if (password.cvv != null && password.cvv!.isNotEmpty)
                _buildDetailItem('cvv'.tr(), password.cvv!),

              if (password.ibanNumbers != null &&
                  password.ibanNumbers!.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    'iban_numbers'.tr(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...password.ibanNumbers!.map((ibanEntry) {
                  final displayLabel =
                      ibanEntry.name != null && ibanEntry.name!.isNotEmpty
                      ? ibanEntry.name!
                      : 'IBAN';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ibanEntry.name != null &&
                            ibanEntry.name!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              displayLabel,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          child: Text(
                            ibanEntry.iban,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              if (password.notes != null && password.notes!.isNotEmpty)
                _buildDetailItem('Notes', password.notes!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context); // Close detail dialog first
              _onEditPassword(password);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context); // Close detail dialog first
              _onDeletePassword(password);
            },
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.error,
            ),
            label: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isPassword ? '•' * 8 : value,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    print('=== HOME PAGE DIALOG COPY ===');
                    print('Copying $label: "$value"');

                    try {
                      await Clipboard.setData(ClipboardData(text: value));

                      // Verify the copy worked
                      final clipboardData = await Clipboard.getData(
                        Clipboard.kTextPlain,
                      );
                      final copiedText = clipboardData?.text ?? '';
                      final success = copiedText == value;

                      print(
                        'Copy verification: ${success ? "SUCCESS" : "FAILED"}',
                      );
                      print('Expected: "$value"');
                      print('Got: "$copiedText"');

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? '$label copied to clipboard'
                                : 'Failed to copy $label',
                          ),
                          duration: const Duration(seconds: 2),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );

                      if (success) {
                        HapticFeedback.lightImpact();
                      }
                    } catch (e) {
                      print('Copy exception: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error copying $label: $e'),
                          duration: const Duration(seconds: 3),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onEditPassword(PasswordModel password) async {
    print('_onEditPassword called for: ${password.title}');

    try {
      // Don't pop context here - popup menu auto-closes and card tap doesn't need pop

      print('Navigating to edit page...');
      // Navigate to edit page and wait for result
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPasswordPage(editingPassword: password),
        ),
      );

      print('Edit page returned with result: $result');

      // If page returned true, refresh the password list
      if (result == true && mounted) {
        print('Refreshing password list...');
        context.read<PasswordsCubit>().loadPasswords();
        _loadFavorites();
      }
    } catch (e) {
      print('Error in _onEditPassword: $e');
    }
  }

  Future<void> _onDeletePassword(PasswordModel password) async {
    print('_onDeletePassword called for: ${password.title}');

    try {
      // Don't pop context here - popup menu auto-closes and card tap doesn't need pop

      print('Showing delete confirmation dialog...');
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('delete_password_title'.tr()),
          content: Text('delete_confirmation'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      print('Delete confirmation returned: $confirmed');

      if (confirmed == true && password.id != null && mounted) {
        print('Deleting password...');

        // If we're in a dialog/modal context, close it first
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        await context.read<PasswordsCubit>().deletePassword(password.id!);
        _loadFavorites();
      }
    } catch (e) {
      print('Error in _onDeletePassword: $e');
    }
  }

  Future<void> _onToggleFavorite(int passwordId) async {
    try {
      await context.read<PasswordsCubit>().toggleFavorite(passwordId);
      _loadFavorites();
    } catch (e) {
      print('Error toggling favorite: $e');
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
      return const Color(0xFF9E9E9E); // Material Grey
    }
  }

  List<PasswordModel> _filterPasswords(List<PasswordModel> passwords) {
    List<PasswordModel> filtered = passwords;

    // Filter by favorites
    if (_showFavorites) {
      filtered = _favoritePasswords;
      // Apply search on favorites if searching
      if (_searchQuery.isNotEmpty) {
        filtered = filtered.where((password) {
          return password.title.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              password.username.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              (password.website?.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ??
                  false);
        }).toList();
      }
      return filtered;
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((password) {
        return password.title.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            password.username.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            (password.website?.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ??
                false);
      }).toList();
    }

    // Filter by category
    if (_selectedCategory != null) {
      filtered = filtered.where((password) {
        return password.categoryId == _selectedCategory!.id;
      }).toList();
    }

    return filtered;
  }
}
