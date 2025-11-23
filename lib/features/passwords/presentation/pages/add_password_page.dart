import 'package:flutter/material.dart';
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
  final List<TextEditingController> _ibanControllers = [];
  
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
        for (var iban in widget.editingPassword!.ibanNumbers!) {
          final controller = TextEditingController(text: iban);
          _ibanControllers.add(controller);
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
    for (var controller in _ibanControllers) {
      controller.dispose();
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
                  _ibanControllers.add(TextEditingController());
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
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title field
                  _buildTextField(
                    controller: _titleController,
                    label: 'title'.tr(),
                    hint: 'title_hint'.tr(),
                    icon: Icons.title,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'please_enter_title'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Category selection
                  _buildCategorySelector(),
                  const SizedBox(height: 16),
                  
                  // Username field (optional)
                  _buildTextField(
                    controller: _usernameController,
                    label: 'username_email'.tr(),
                    hint: 'username_email_hint'.tr(),
                    icon: Icons.person,
                    validator: null, // Made optional - no validation required
                  ),
                  const SizedBox(height: 16),
                  
                  // Password field
                  _buildTextField(
                    controller: _passwordController,
                    label: 'password'.tr(),
                    hint: 'password_hint'.tr(),
                    icon: Icons.lock,
                    obscureText: _obscurePassword,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
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
                  const SizedBox(height: 16),
                  
                  // Website field
                  _buildTextField(
                    controller: _websiteController,
                    label: 'website_optional'.tr(),
                    hint: 'website_hint'.tr(),
                    icon: Icons.web,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  
                  // Notes field
                  _buildTextField(
                    controller: _notesController,
                    label: 'notes_optional'.tr(),
                    hint: 'notes_hint'.tr(),
                    icon: Icons.notes,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  
                  // Banking-specific fields (only show if banking category is selected)
                  if (_isBankingCategory) ...[
                    // Section header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.account_balance, 
                            color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'banking_info'.tr(),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Card holder name
                    _buildTextField(
                      controller: _cardHolderNameController,
                      label: 'card_holder_name'.tr(),
                      hint: 'card_holder_name_hint'.tr(),
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    
                    // Card number
                    _buildTextField(
                      controller: _cardNumberController,
                      label: 'card_number'.tr(),
                      hint: 'card_number_hint'.tr(),
                      icon: Icons.credit_card,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    
                    // Expiry date and CVV in a row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _expiryDateController,
                            label: 'expiry_date'.tr(),
                            hint: 'MM/YY',
                            icon: Icons.calendar_today,
                            keyboardType: TextInputType.datetime,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _cvvController,
                            label: 'cvv'.tr(),
                            hint: 'CVV',
                            icon: Icons.lock_outline,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // IBAN numbers section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'iban_numbers'.tr(),
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._buildIbanFields(),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _addIbanField,
                          icon: const Icon(Icons.add),
                          label: Text('add_iban'.tr()),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _savePassword,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  widget.editingPassword != null ? Icons.update : Icons.save,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.editingPassword != null ? 'update_password'.tr() : 'save_password'.tr(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'category'.tr(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: _categories.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'loading_categories'.tr(),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<CategoryModel?>(
                    value: _selectedCategory,
                    isExpanded: true,
                    hint: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('select_category_optional'.tr()),
                    ),
                    items: [
                      DropdownMenuItem<CategoryModel?>(
                        value: null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('no_category'.tr()),
                        ),
                      ),
                      ..._categories.map((category) {
                        return DropdownMenuItem<CategoryModel?>(
                          value: category,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: _parseColor(category.color).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      category.icon,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(category.name),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                    onChanged: (CategoryModel? newValue) {
                      print('Category selected: ${newValue?.name ?? 'None'} (ID: ${newValue?.id})');
                      setState(() {
                        _selectedCategory = newValue;
                        _isBankingCategory = newValue?.name == 'Bankacılık';
                        
                        // Initialize one IBAN field if banking is selected and list is empty
                        if (_isBankingCategory && _ibanControllers.isEmpty) {
                          _ibanControllers.add(TextEditingController());
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
            suffixIcon: suffixIcon,
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
      ],
    );
  }

  void _addIbanField() {
    setState(() {
      _ibanControllers.add(TextEditingController());
    });
  }

  void _removeIbanField(int index) {
    if (_ibanControllers.length > 1) {
      setState(() {
        _ibanControllers[index].dispose();
        _ibanControllers.removeAt(index);
      });
    }
  }

  List<Widget> _buildIbanFields() {
    return List.generate(_ibanControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _ibanControllers[index],
                decoration: InputDecoration(
                  hintText: 'TR00 0000 0000 0000 0000 0000 00',
                  prefixIcon: Icon(Icons.account_balance_outlined, 
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
    
    // Collect IBAN numbers if banking category
    List<String>? ibanNumbers;
    if (_isBankingCategory) {
      ibanNumbers = _ibanControllers
          .map((controller) => controller.text.trim())
          .where((iban) => iban.isNotEmpty)
          .toList();
      if (ibanNumbers.isEmpty) {
        ibanNumbers = null;
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