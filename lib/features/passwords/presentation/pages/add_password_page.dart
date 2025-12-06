import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
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
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.editingPassword != null ? 'edit_password'.tr() : 'add_password'.tr()),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        body: BlocListener<PasswordsCubit, PasswordsState>(
          listener: (context, state) {
            if (state is PasswordsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
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
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.autorenew, size: 20),
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
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
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
                                foregroundColor: Theme.of(context).colorScheme.primary,
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
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
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
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
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
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
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
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
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              borderRadius: BorderRadius.circular(16),
              dropdownColor: Theme.of(context).colorScheme.surface,
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
                                _parseColor(category.color).withValues(alpha: 0.15),
                                _parseColor(category.color).withValues(alpha: 0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _parseColor(category.color).withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              category.icon,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          category.name,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                }).toList(),
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

  // Modern Section Card Builder
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            ...children,
          ],
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
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
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
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            suffixIcon: suffixIcon,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
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