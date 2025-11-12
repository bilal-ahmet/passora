import 'package:get_it/get_it.dart';
import '../services/database_service.dart';
import '../../features/passwords/presentation/cubit/passwords_cubit.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Services
  getIt.registerSingleton<DatabaseService>(DatabaseService.instance);
  
  // Cubits
  getIt.registerFactory<PasswordsCubit>(() => PasswordsCubit(getIt<DatabaseService>()));
  getIt.registerFactory<SettingsCubit>(() => SettingsCubit(getIt<DatabaseService>()));
}

// Reset dependencies for testing
void resetDependencies() => getIt.reset();