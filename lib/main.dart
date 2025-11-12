import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';

import 'core/constants/app_constants.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/services/database_service.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/passwords/presentation/cubit/passwords_cubit.dart';
import 'features/categories/presentation/cubit/categories_cubit.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/settings/presentation/cubit/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check if running on emulator and enable test mode for biometrics (DEBUG MODE ONLY)
  try {
    bool isDebugMode = false;
    assert(() {
      isDebugMode = true;
      return true;
    }());
    
    if (isDebugMode && Platform.isAndroid) {
      final model = await Process.run('getprop', ['ro.product.model']);
      final brand = await Process.run('getprop', ['ro.product.brand']);
      if (model.stdout.toString().toLowerCase().contains('sdk') || 
          brand.stdout.toString().toLowerCase().contains('generic')) {
        print('Emulator detected in DEBUG mode');
      } else {
        print('Real device detected in DEBUG mode');
      }
    } else {
      print('RELEASE mode');
    }
  } catch (e) {
    print('Could not detect emulator: $e');
  }
  
  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();
  
  // Initialize Database
  await DatabaseService.instance.initialize();
  
  // Update existing categories to Turkish
  await DatabaseService.instance.updateCategoriesToTurkish();
  
  // Configure dependency injection
  await configureDependencies();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const PassoraApp(),
    ),
  );
}

class PassoraApp extends StatelessWidget {
  const PassoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CategoriesCubit>(
          create: (context) => CategoriesCubit(DatabaseService.instance),
        ),
        BlocProvider<PasswordsCubit>(
          create: (context) => getIt<PasswordsCubit>(),
        ),
        BlocProvider<SettingsCubit>(
          create: (context) => getIt<SettingsCubit>(),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(DatabaseService.instance)..loadTheme(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          ThemeMode themeMode = ThemeMode.system;
          if (themeState is ThemeLoaded) {
            themeMode = themeState.themeMode;
          }
          
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: const SplashPage(),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(1.0), // Prevent text scaling
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
