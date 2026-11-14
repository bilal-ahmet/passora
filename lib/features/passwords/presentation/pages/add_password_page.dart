import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/gradient_scaffold.dart';
import '../../data/models/password_model.dart';
import '../cubit/passwords_cubit.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';

class AddPasswordPage extends StatefulWidget {
  final PasswordModel? editingPassword;
  
  const AddPasswordPage({super.key, this.editingPassword});

  @override
  State<AddPasswordPage> createState() => _AddPasswordPageState();
}

class _AddPasswordPageState extends State<AddPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _websiteController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Banking-specific controllers
  final _cardHolderNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final List<Map<String, TextEditingController>> _ibanControllers = [];
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  CategoryModel? _selectedCategory;
  List<CategoryModel> _categories = [];
  bool _isBankingCategory = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.editingPassword != null) {
      _titleController.text = widget.editingPassword!.title;
      _usernameController.text = widget.editingPassword!.username;
      _passwordController.text = widget.editingPassword!.password;
      _websiteController.text = widget.editingPassword!.website ?? '';
      _notesController.text = widget.editingPassword!.notes ?? '';
      
      // Load banking fields if present
      _cardHolderNameController.text = widget.editingPassword!.cardHolderName ?? '';
      _cardNumberController.text = widget.editingPassword!.cardNumber ?? '';
      _expiryDateController.text = widget.editingPassword!.expiryDate ?? '';
      _cvvController.text = widget.editingPassword!.cvv ?? '';
      
      // Load IBAN numbers
      if (widget.editingPassword!.ibanNumbers != null && widget.editingPassword!.ibanNumbers!.isNotEmpty) {
        for (var ibanEntry in widget.editingPassword!.ibanNumbers!) {
          _ibanControllers.add({
            'iban': TextEditingController(text: ibanEntry.iban),
            'name': TextEditingController(text: ibanEntry.name ?? ''),
          });
        }
      }
      // Category will be loaded after categories are fetched
    }
  }

  Future<void> _loadCategories() async {
    context.read<CategoriesCubit>().loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    _cardHolderNameController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    for (var controllerMap in _ibanControllers) {
      controllerMap['iban']!.dispose();
      controllerMap['name']!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoriesCubit, CategoriesState>(
      listener: (context, state) {
        if (state is CategoriesLoaded) {
          setState(() {
            _categories = state.categories;
            if (widget.editingPassword?.categoryId != null) {
              try {
                _selectedCategory = _categories.firstWhere(
                  (cat) => cat.id == widget.editingPassword!.categoryId,
                );
                // Check if the category is banking to show banking fields
                _isBankingCategory = _selectedCategory?.name == 'Bankacılık';
                
                // If banking category and no IBAN controllers, add at least one
                if (_isBankingCategory && _ibanControllers.isEmpty) {
                  _ibanControllers.add({
                    'iban': TextEditingController(),
                    'name': TextEditingController(),
                  });
                }
              } catch (e) {
                _selectedCategory = null; // Category not found
              }
            }
          });
        }
      },
      child: GradientScaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Modern Header
              _buildHeader(),
              
              // Form Content
              Expanded(
                child: BlocListener<PasswordsCubit, PasswordsState>(
                  listener: (context, state) {
                    if (state is PasswordsError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Basic Information Section
                          _buildSectionCard(
                            title: 'basic_information'.tr(),
                            children: [
                              _buildTextField(
                                controller: _titleController,
                                label: 'title'.tr(),
                                hint: 'title_hint'.tr(),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'please_enter_title'.tr();
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildCategorySelector(),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Credentials Section
                          _buildSectionCard(
                            title: 'credentials'.tr(),
                            children: [
                              _buildTextField(
                                controller: _usernameController,
                                label: 'username_email'.tr(),
                                hint: 'username_email_hint'.tr(),
                                validator: null,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _passwordController,
                                label: 'password'.tr(),
                                hint: 'password_hint'.tr(),
                                obscureText: _obscurePassword,
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        size: 20,
                                        color: AppColors.textSecondary,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.autorenew, size: 20, color: AppColors.accentPink),
                                      onPressed: _generatePassword,
                                    ),
                                  ],
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'please_enter_password'.tr();
                                  }
                                  if (value.length < 6) {
                                    return 'password_min_length'.tr();
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Additional Details Section
                          _buildSectionCard(
                            title: 'additional_details'.tr(),
                            children: [
                              _buildTextField(
                                controller: _websiteController,
                                label: 'website_optional'.tr(),
                                hint: 'website_hint'.tr(),
                                keyboardType: TextInputType.url,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _notesController,
                                label: 'notes_optional'.tr(),
                                hint: 'notes_hint'.tr(),
                                maxLines: 4,
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Banking-specific fields (only show if banking category is selected)
                          if (_isBankingCategory) 
                            _buildSectionCard(
                              title: 'banking_info'.tr(),
                              children: [
                                _buildTextField(
                                  controller: _cardHolderNameController,
                                  label: 'card_holder_name'.tr(),
                                  hint: 'card_holder_name_hint'.tr(),
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                  controller: _cardNumberController,
                                  label: 'card_number'.tr(),
                                  hint: 'card_number_hint'.tr(),
                                  keyboardType: TextInputType.number,
                                  maxLength: 16,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(16),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _expiryDateController,
                                        label: 'expiry_date'.tr(),
                                        hint: 'MM/YY',
                                        keyboardType: TextInputType.number,
                                        maxLength: 5,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(4),
                                          _ExpiryDateFormatter(),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _cvvController,
                                        label: 'cvv'.tr(),
                                        hint: 'CVV',
                                        keyboardType: TextInputType.number,
                                        maxLength: 3,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(3),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4, bottom: 10),
                                      child: Text(
                                        'iban_numbers'.tr(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                    ..._buildIbanFields(),
                                    const SizedBox(height: 12),
                                    OutlinedButton.icon(
                                      onPressed: _addIbanField,
                                      icon: const Icon(Icons.add, size: 18),
                                      label: Text('add_iban'.tr()),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.accentPink,
                                        side: BorderSide(
                                          color: AppColors.accentPink.withValues(alpha: 0.5),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          
                          const SizedBox(height: 8),
                          
                          // Save button - Modern gradient design
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: AppColors.fabGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentPink.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _savePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      widget.editingPassword != null ? 'update_password'.tr() : 'save_password'.tr(),
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Close Button
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
                    Icons.close,
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
            widget.editingPassword != null ? 'edit_password'.tr() : 'add_password'.tr(),
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

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'category'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<CategoryModel>(
              isExpanded: true,
              value: _selectedCategory,
              hint: Text(
                'select_category'.tr(),
                style: TextStyle(
                  color: AppColors.textTertiary,
                ),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
              borderRadius: BorderRadius.circular(16),
              dropdownColor: AppColors.cardBackground,
              items: [
                ..._categories.map((CategoryModel category) {
                  return DropdownMenuItem<CategoryModel>(
                    value: category,
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _parseColor(category.color).withValues(alpha: 0.3),
                                _parseColor(category.color).withValues(alpha: 0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _parseColor(category.color).withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              _getIconData(category.icon),
                              size: 18,
                              color: _parseColor(category.color),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          category.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (CategoryModel? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                  _isBankingCategory = newValue?.name == 'Bankacılık';
                  
                  if (_isBankingCategory && _ibanControllers.isEmpty) {
                    _ibanControllers.add({
                      'iban': TextEditingController(),
                      'name': TextEditingController(),
                    });
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }

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
      default: return Icons.folder_rounded;
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

  // Modern Section Card Builder with Glassmorphism
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentPink,
                    letterSpacing: 0.5,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textTertiary,
            ),
            suffixIcon: suffixIcon,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.glassBorder,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.accentPink,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }

  void _addIbanField() {
    setState(() {
      _ibanControllers.add({
        'iban': TextEditingController(),
        'name': TextEditingController(),
      });
    });
  }

  void _removeIbanField(int index) {
    if (_ibanControllers.length > 1) {
      setState(() {
        _ibanControllers[index]['iban']!.dispose();
        _ibanControllers[index]['name']!.dispose();
        _ibanControllers.removeAt(index);
      });
    }
  }

  List<Widget> _buildIbanFields() {
    return List.generate(_ibanControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IBAN Name field
            TextFormField(
              controller: _ibanControllers[index]['name']!,
              decoration: InputDecoration(
                labelText: 'iban_name'.tr(),
                hintText: 'iban_name_hint'.tr(),
                prefixIcon: Icon(Icons.label_outline, 
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(height: 8),
            // IBAN Number field
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ibanControllers[index]['iban']!,
                    maxLength: 26,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      LengthLimitingTextInputFormatter(26),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        return TextEditingValue(
                          text: newValue.text.toUpperCase(),
                          selection: newValue.selection,
                        );
                      }),
                    ],
                    decoration: InputDecoration(
                      hintText: 'TR00 0000 0000 0000 0000 0000 00',
                      prefixIcon: Icon(Icons.account_balance_outlined, 
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                if (_ibanControllers.length > 1) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.delete_outline, 
                      color: Theme.of(context).colorScheme.error),
                    onPressed: () => _removeIbanField(index),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    });
  }

  void _generatePassword() {
    // Simple password generator
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = DateTime.now().millisecondsSinceEpoch;
    String password = '';
    
    for (int i = 0; i < 12; i++) {
      password += chars[(random + i) % chars.length];
    }
    
    setState(() {
      _passwordController.text = password;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password generated successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _savePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    print('Saving password with categoryId: ${_selectedCategory?.id} (${_selectedCategory?.name})');
    
    // Collect IBAN entries if banking category
    List<IbanEntry>? ibanNumbers;
    if (_isBankingCategory) {
      final entries = _ibanControllers
          .map((controllerMap) {
            final iban = controllerMap['iban']!.text.trim();
            final name = controllerMap['name']!.text.trim();
            if (iban.isNotEmpty) {
              return IbanEntry(
                iban: iban,
                name: name.isEmpty ? null : name,
              );
            }
            return null;
          })
          .where((entry) => entry != null)
          .cast<IbanEntry>()
          .toList();
      if (entries.isEmpty) {
        ibanNumbers = null;
      } else {
        ibanNumbers = entries;
      }
    }
    
    final password = PasswordModel(
      id: widget.editingPassword?.id,
      title: _titleController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      categoryId: _selectedCategory?.id,
      createdAt: widget.editingPassword?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      cardHolderName: _isBankingCategory && _cardHolderNameController.text.trim().isNotEmpty
          ? _cardHolderNameController.text.trim()
          : null,
      cardNumber: _isBankingCategory && _cardNumberController.text.trim().isNotEmpty
          ? _cardNumberController.text.trim()
          : null,
      ibanNumbers: ibanNumbers,
      expiryDate: _isBankingCategory && _expiryDateController.text.trim().isNotEmpty
          ? _expiryDateController.text.trim()
          : null,
      cvv: _isBankingCategory && _cvvController.text.trim().isNotEmpty
          ? _cvvController.text.trim()
          : null,
    );

    try {
      await context.read<PasswordsCubit>().savePassword(password);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.editingPassword != null ? 'Password updated successfully' : 'Password saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// Custom TextInputFormatter for expiry date (MM/YY format)
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Remove any non-digit characters
    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');
    
    // Limit to 4 digits
    final limitedDigits = digitsOnly.substring(0, digitsOnly.length > 4 ? 4 : digitsOnly.length);
    
    // Format as MM/YY
    String formatted = '';
    for (int i = 0; i < limitedDigits.length; i++) {
      if (i == 2) {
        formatted += '/';
      }
      formatted += limitedDigits[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}