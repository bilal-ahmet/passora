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
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  CategoryModel? _selectedCategory;
  List<CategoryModel> _categories = [];

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
                  const SizedBox(height: 32),
                  
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