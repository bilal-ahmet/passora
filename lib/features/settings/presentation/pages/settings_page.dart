import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/csv_import_service.dart';
import '../../../auth/presentation/pages/change_password_page.dart';
import '../../../passwords/data/models/password_model.dart';
import '../../../passwords/presentation/cubit/passwords_cubit.dart';
import '../cubit/theme_cubit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isAutoLockEnabled = true;
  int _autoLockDuration = 5; // minutes
  bool _isMasterPasswordEnabled = true;
  bool _isLoading = true;
  bool _dataImported = false; // Track if data was imported

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      // Load current settings
      final settings = await DatabaseService.instance.getSettings();
      
      setState(() {
        _isAutoLockEnabled = settings.autoLockEnabled;
        _autoLockDuration = settings.autoLockDuration;
        _isMasterPasswordEnabled = settings.masterPasswordEnabled;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAutoLockSetting(bool value) async {
    setState(() {
      _isAutoLockEnabled = value;
    });
    
    await DatabaseService.instance.updateSettings(
      autoLockEnabled: value,
    );
  }

  Future<void> _saveAutoLockDuration(int value) async {
    setState(() {
      _autoLockDuration = value;
    });
    
    await DatabaseService.instance.updateSettings(
      autoLockDuration: value,
    );
  }

  Future<void> _saveMasterPasswordSetting(bool value) async {
    if (value) {
      // Master password'u etkinleştiriyoruz - master password var mı kontrol et
      final masterPasswordExists = await DatabaseService.instance.masterPasswordExists();
      if (!masterPasswordExists) {
        // Master password yok, kullanıcıyı uyar
        _showCreateMasterPasswordDialog();
        return;
      }
    }
    
    // Direkt ayarı güncelle - şifreleri değiştirme!
    setState(() {
      _isMasterPasswordEnabled = value;
    });
    
    await DatabaseService.instance.updateSettings(
      masterPasswordEnabled: value,
    );
    
    // Kullanıcıyı bilgilendir
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value 
              ? 'master_password_enabled'.tr() 
              : 'master_password_disabled'.tr()
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showCreateMasterPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('create_master_password'.tr()),
        content: Text('master_password_required_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Master password oluşturma sayfasına git
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordPage(),
                ),
              );
            },
            child: Text('create'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop && _dataImported) {
          // Return flag that data was imported
          Future.microtask(() {
            if (mounted && Navigator.canPop(context)) {
              // Already popped, but we can try to communicate via other means
            }
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('settings'.tr()),
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, _dataImported ? 'imported' : null);
            },
          ),
        ),
        body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            _buildSectionTitle('appearance'.tr()),
            const SizedBox(height: 16),
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) {
                bool isDark = false;
                if (state is ThemeLoaded) {
                  isDark = state.themeMode == ThemeMode.dark;
                }
                
                return _buildSwitchTile(
                  title: 'dark_mode'.tr(),
                  subtitle: 'toggle_dark_light_mode'.tr(),
                  icon: isDark ? Icons.dark_mode : Icons.light_mode,
                  value: isDark,
                  onChanged: (value) {
                    final newTheme = value ? ThemeMode.dark : ThemeMode.light;
                    context.read<ThemeCubit>().changeTheme(newTheme);
                  },
                );
              },
            ),
            
            // Language Selection
            _buildLanguageTile(),
            
            const SizedBox(height: 32),
            
            // Security Section
            _buildSectionTitle('security'.tr()),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'master_password_protection'.tr(),
              subtitle: 'require_master_password_on_startup'.tr(),
              icon: Icons.security,
              value: _isMasterPasswordEnabled,
              onChanged: _saveMasterPasswordSetting,
            ),
            _buildSwitchTile(
              title: 'auto_lock'.tr(),
              subtitle: 'automatically_lock_app'.tr(),
              icon: Icons.lock_clock,
              value: _isAutoLockEnabled,
              onChanged: _saveAutoLockSetting,
            ),
            if (_isAutoLockEnabled) _buildAutoLockDurationTile(),
            _buildActionTile(
              title: 'change_master_password'.tr(),
              subtitle: 'update_your_master_password'.tr(),
              icon: Icons.key,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordPage(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Data Management Section
            _buildSectionTitle('data_management'.tr()),
            const SizedBox(height: 16),
            _buildActionTile(
              title: 'import_data'.tr(),
              subtitle: 'import_passwords_csv'.tr(),
              icon: Icons.file_upload,
              onTap: _importData,
            ),
            _buildActionTile(
              title: 'export_data'.tr(),
              subtitle: 'export_passwords_json'.tr(),
              icon: Icons.file_download,
              onTap: _exportData,
            ),
            _buildActionTile(
              title: 'clear_all_data'.tr(),
              subtitle: 'permanently_delete_all_data'.tr(),
              icon: Icons.delete_forever,
              onTap: _showClearDataDialog,
            ),
            
            const SizedBox(height: 32),
            
            // About
            _buildActionTile(
              title: 'about'.tr(),
              subtitle: 'app_info_version'.tr(),
              icon: Icons.info,
              onTap: _showAboutDialog,
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
      ), // Close PopScope
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildLanguageTile() {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.language, color: Theme.of(context).colorScheme.primary),
        title: Text('language'.tr()),
        subtitle: Text(_getCurrentLanguageText()),
        trailing: DropdownButton<Locale>(
          value: context.locale,
          underline: const SizedBox(),
          items: [
            DropdownMenuItem(
              value: const Locale('en'),
              child: Text('english'.tr()),
            ),
            DropdownMenuItem(
              value: const Locale('tr'),
              child: Text('turkish'.tr()),
            ),
          ],
          onChanged: (locale) {
            if (locale != null) {
              context.setLocale(locale);
            }
          },
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2, end: 0);
  }

  String _getCurrentLanguageText() {
    switch (context.locale.languageCode) {
      case 'tr':
        return 'turkish'.tr();
      case 'en':
      default:
        return 'english'.tr();
    }
  }

  Widget _buildAutoLockDurationTile() {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.timer, color: Theme.of(context).colorScheme.primary),
        title: const Text('Auto Lock Duration'),
        subtitle: Text('$_autoLockDuration minutes'),
        trailing: DropdownButton<int>(
          value: _autoLockDuration,
          underline: const SizedBox(),
          items: [1, 5, 10, 15, 30].map((duration) {
            return DropdownMenuItem(
              value: duration,
              child: Text('$duration min'),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              _saveAutoLockDuration(value);
            }
          },
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2, end: 0);
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Passora'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Passora - Secure Password Manager'),
            SizedBox(height: 8),
            Text('Version 1.0.0'),
            SizedBox(height: 8),
            Text('A modern and secure password manager built with Flutter.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData() async {
    try {
      // Clear all data from database
      await DatabaseService.instance.clearAllData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data cleared successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      
      // Navigate back to setup screen
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
      }
    } catch (e) {
      print('Error clearing data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to clear data'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _importData() async {
    try {
      // Show file picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: false,
        withReadStream: false,
      );

      if (result == null || result.files.single.path == null) {
        return; // User cancelled
      }

      final filePath = result.files.single.path!;

      // Show loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'reading_file'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'please_wait'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.8, 0.8)),
        ),
      );

      // Parse CSV
      final csvImportService = CsvImportService();
      final passwords = await csvImportService.parsePasswordsFromCsv(filePath);

      // Close loading dialog
      if (!mounted) return;
      Navigator.pop(context);

      if (passwords.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('no_passwords_found'.tr()),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Show preview dialog
      _showImportPreviewDialog(passwords);
    } catch (e) {
      // Close loading dialog if open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      print('Error importing data: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${'import_failed'.tr()}: ${e.toString()}'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showImportPreviewDialog(List<PasswordModel> passwords) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('import_preview'.tr()),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${'found_passwords'.tr()}: ${passwords.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: passwords.length > 5 ? 5 : passwords.length,
                  itemBuilder: (context, index) {
                    final password = passwords[index];
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.password, size: 20),
                      title: Text(
                        password.title,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        password.username.isNotEmpty 
                            ? password.username 
                            : password.website ?? '',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              ),
              if (passwords.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${'and_more'.tr()} ${passwords.length - 5} ${'passwords'.tr()}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'import_confirmation'.tr(),
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _performImport(passwords);
            },
            child: Text('import'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _performImport(List<PasswordModel> passwords) async {
    try {
      // Show loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'importing'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${'importing_passwords'.tr()}...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.8, 0.8)),
        ),
      );

      int successCount = 0;
      for (final password in passwords) {
        try {
          await DatabaseService.instance.savePassword(password);
          successCount++;
        } catch (e) {
          print('Failed to import password ${password.title}: $e');
        }
      }

      // Close loading dialog
      if (!mounted) return;
      Navigator.pop(context);

      // Mark that data was imported
      setState(() {
        _dataImported = true;
      });

      // Refresh passwords in home page by reloading PasswordsCubit
      if (mounted) {
        // Import the PasswordsCubit to refresh the home page
        try {
          context.read<PasswordsCubit>().loadPasswords();
          print('Passwords reloaded after import');
        } catch (e) {
          print('Could not reload passwords cubit: $e');
          // This is okay if we're not in the home page context
        }
      }

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${'import_success'.tr()}: $successCount/${passwords.length}'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Close loading dialog if open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      print('Error performing import: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('import_failed'.tr()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _exportData() async {
    try {
      // Get all passwords
      final passwords = await DatabaseService.instance.getAllPasswords();
      final categories = await DatabaseService.instance.getAllCategories();
      
      // Create export data structure
      final exportData = {
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'passwords': passwords.map((password) => {
          'title': password.title,
          'username': password.username,
          'password': password.password, // Already decrypted by getAllPasswords
          'website': password.website,
          'notes': password.notes,
          'categoryId': password.categoryId,
          'createdAt': password.createdAt.toIso8601String(),
          'updatedAt': password.updatedAt.toIso8601String(),
        }).toList(),
        'categories': categories.map((category) => {
          'id': category.id,
          'name': category.name,
          'icon': category.icon,
          'color': category.color,
        }).toList(),
      };
      
      // Convert to JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      // Share the file
      await Share.share(
        jsonString,
        subject: 'Passora Password Export - ${DateTime.now().toString().split(' ')[0]}',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data exported successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      print('Error exporting data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to export data'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your passwords and settings. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllData();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}