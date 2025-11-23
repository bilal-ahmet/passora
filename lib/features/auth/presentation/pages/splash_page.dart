import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/database_service.dart';
import '../../../passwords/presentation/pages/home_page.dart';
import 'login_page.dart';
import 'setup_password_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simulate initialization delay
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      try {
        // Check if master password exists
        bool hasMasterPassword = await DatabaseService.instance.masterPasswordExists();
        
        if (hasMasterPassword) {
          // Master password var, settings'ten enabled olup olmadığını kontrol et
          final settings = await DatabaseService.instance.getSettings();
          
          if (settings.masterPasswordEnabled) {
            // Master password etkin, login sayfasına git
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
            );
          } else {
            // Master password devre dışı
            // Bypass mode ile default key kullan
            await DatabaseService.instance.setBypassMode(true);
            
            // Direkt ana sayfaya git
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          }
        } else {
          // Master password yok, ilk kurulum - setup sayfasına git
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SetupPasswordPage(),
            ),
          );
        }
      } catch (e) {
        // On error, navigate to setup page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SetupPasswordPage(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.security,
                  size: 64,
                  color: AppColors.primaryBlue,
                ),
              )
                  .animate()
                  .scale(
                    duration: AppConstants.longAnimationDuration,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(
                    duration: AppConstants.animationDuration,
                  ),
              
              const SizedBox(height: 32),
              
              // App Name
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              )
                  .animate(delay: 200.ms)
                  .fadeIn(
                    duration: AppConstants.animationDuration,
                  )
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    duration: AppConstants.animationDuration,
                    curve: Curves.easeOut,
                  ),
              
              const SizedBox(height: 16),
              
              // App Description
              Text(
                'Secure password manager for everyone',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              )
                  .animate(delay: 400.ms)
                  .fadeIn(
                    duration: AppConstants.animationDuration,
                  )
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    duration: AppConstants.animationDuration,
                    curve: Curves.easeOut,
                  ),
              
              const SizedBox(height: 64),
              
              // Loading Indicator
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.white.withValues(alpha: 0.8),
                  ),
                  strokeWidth: 3,
                ),
              )
                  .animate(delay: 400.ms)
                  .fadeIn(
                    duration: AppConstants.animationDuration,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}