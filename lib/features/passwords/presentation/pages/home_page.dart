import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../shared/widgets/password_card.dart';
import '../../data/models/password_model.dart';
import '../cubit/passwords_cubit.dart';
import '../widgets/statistics_dialog.dart';
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
  Map<String, dynamic> _statistics = {};
  List<PasswordModel> _favoritePasswords = [];
  bool _showFavorites = true; // Favorileri başlangıçta göster

  @override
  void initState() {
    super.initState();
    // Load categories first, then passwords
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<CategoriesCubit>().loadCategories();
      await Future.delayed(const Duration(milliseconds: 100)); // Small delay to ensure categories are loaded
      context.read<PasswordsCubit>().loadPasswords();
      _loadStatistics();
      _loadFavorites();
    });
  }

  Future<void> _loadStatistics() async {
    final stats = await context.read<PasswordsCubit>().getPasswordStatistics();
    if (mounted) {
      setState(() {
        _statistics = stats;
      });
    }
  }

  Future<void> _loadFavorites() async {
    final favorites = await context.read<PasswordsCubit>().getFavoritePasswords();
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'app_name'.tr(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'statistics'.tr(),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => StatisticsDialog(statistics: _statistics),
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.category),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CategoriesPage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
                
                // Reload passwords if data was imported
                if (result == 'imported' && mounted) {
                  context.read<PasswordsCubit>().loadPasswords();
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Search bar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'search_passwords'.tr(),
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                ),
              ),
            ),
            
            // Category filter chips
            const SizedBox(height: 16),
            Container(
              height: 50,
              child: _categories.isEmpty 
                ? Center(child: Text('Loading categories...', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)))
                : ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // All categories chip
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('All'),
                        selected: _selectedCategory == null && !_showFavorites,
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedCategory = null;
                            _showFavorites = false;
                          });
                        },
                        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    // Favorites chip
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        avatar: const Icon(Icons.star, size: 16),
                        label: Text('favorites'.tr()),
                        selected: _showFavorites,
                        onSelected: (bool selected) {
                          setState(() {
                            _showFavorites = selected;
                            if (selected) {
                              _selectedCategory = null;
                            }
                          });
                        },
                        selectedColor: Colors.amber.withOpacity(0.2),
                        checkmarkColor: Colors.amber,
                      ),
                    ),
                    // Category chips
                    ..._categories.map((category) {
                      final isSelected = _selectedCategory?.id == category.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          avatar: Text(category.icon, style: const TextStyle(fontSize: 16)),
                          label: Text(category.name),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedCategory = selected ? category : null;
                              _showFavorites = false;
                            });
                          },
                          selectedColor: _parseColor(category.color).withOpacity(0.2),
                          checkmarkColor: _parseColor(category.color),
                        ),
                      );
                    }).toList(),
                  ],
                ),
            ),
            
            // Content area
            Expanded(
              child: BlocConsumer<PasswordsCubit, PasswordsState>(
                listener: (context, state) {
                  if (state is PasswordsLoaded) {
                    print('Passwords reloaded: ${state.passwords.length} items');
                    _loadStatistics();
                    _loadFavorites();
                  }
                },
                builder: (context, state) {
                  if (state is PasswordsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  if (state is PasswordsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading passwords',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<PasswordsCubit>().loadPasswords();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  if (state is PasswordsLoaded) {
                    final passwords = _filterPasswords(state.passwords);
                    
                    if (passwords.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _showSearchResults ? 'no_passwords_found'.tr() : 'no_passwords_yet'.tr(),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _showSearchResults 
                                  ? 'Try a different search term'
                                  : 'add_first_password'.tr(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    
                    // Show passwords list (filtered)
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: passwords.length,
                      itemBuilder: (context, index) {
                        final password = passwords[index];
                        CategoryModel? category;
                        if (password.categoryId != null && _categories.isNotEmpty) {
                          try {
                            category = _categories.firstWhere(
                              (cat) => cat.id == password.categoryId,
                            );
                            print('Found category for password ${password.title}: ${category.name}');
                          } catch (e) {
                            print('Category not found for password ${password.title}, categoryId: ${password.categoryId}');
                            category = null; // Category not found
                          }
                        } else {
                          print('Password ${password.title}: categoryId=${password.categoryId}, categories count=${_categories.length}');
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PasswordCard(
                            password: password,
                            category: category,
                            onTap: () => _onPasswordTap(password),
                            onEdit: () => _onEditPassword(password),
                            onDelete: () => _onDeletePassword(password),
                            onToggleFavorite: () => _onToggleFavorite(password.id!),
                          ),
                        );
                      },
                    );
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddPasswordPage(),
              ),
            );
            
            if (result == true && mounted) {
              context.read<PasswordsCubit>().loadPasswords();
            }
          },
          icon: const Icon(Icons.add, size: 20),
          label: Text(
            'add_password'.tr(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
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
              if (password.cardHolderName != null && password.cardHolderName!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Divider(color: Theme.of(context).colorScheme.primary),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance, 
                        color: Theme.of(context).colorScheme.primary, size: 20),
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
                _buildDetailItem('card_holder_name'.tr(), password.cardHolderName!),
              ],
              
              if (password.cardNumber != null && password.cardNumber!.isNotEmpty)
                _buildDetailItem('card_number'.tr(), password.cardNumber!),
              
              if (password.expiryDate != null && password.expiryDate!.isNotEmpty)
                _buildDetailItem('expiry_date'.tr(), password.expiryDate!),
              
              if (password.cvv != null && password.cvv!.isNotEmpty)
                _buildDetailItem('cvv'.tr(), password.cvv!, isPassword: true),
              
              if (password.ibanNumbers != null && password.ibanNumbers!.isNotEmpty) ...[
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
                ...password.ibanNumbers!.asMap().entries.map((entry) =>
                  _buildDetailItem('IBAN ${entry.key + 1}', entry.value),
                ),
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
            icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
            label: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {bool isPassword = false}) {
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
              color: Theme.of(context).colorScheme.surfaceVariant,
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
                      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                      final copiedText = clipboardData?.text ?? '';
                      final success = copiedText == value;
                      
                      print('Copy verification: ${success ? "SUCCESS" : "FAILED"}');
                      print('Expected: "$value"');
                      print('Got: "$copiedText"');
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success 
                            ? '$label copied to clipboard' 
                            : 'Failed to copy $label'),
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
          builder: (context) => AddPasswordPage(
            editingPassword: password,
          ),
        ),
      );
      
      print('Edit page returned with result: $result');
      
      // If page returned true, refresh the password list
      if (result == true && mounted) {
        print('Refreshing password list...');
        context.read<PasswordsCubit>().loadPasswords();
        _loadStatistics();
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
        _loadStatistics();
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
      _loadStatistics();
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
          return password.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 password.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 (password.website?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        }).toList();
      }
      return filtered;
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((password) {
        return password.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               password.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (password.website?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
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