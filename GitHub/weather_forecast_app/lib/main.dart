import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/favorites_repository.dart';
import 'data/repositories/weather_repository.dart';
import 'data/services/auth_local_service.dart';
import 'data/services/favorites_local_service.dart';
import 'data/services/weather_api_service.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/weather_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final weatherApi = WeatherApiService();
  final authService = AuthLocalService(prefs);
  final favoritesService = FavoritesLocalService(prefs);

  final weatherRepository = WeatherRepository(weatherApi);
  final authRepository = AuthRepository(authService);
  final favoritesRepository = FavoritesRepository(favoritesService);

  runApp(
    SkyCastApp(
      prefs: prefs,
      weatherRepository: weatherRepository,
      authRepository: authRepository,
      favoritesRepository: favoritesRepository,
    ),
  );
}

class SkyCastApp extends StatelessWidget {
  const SkyCastApp({
    super.key,
    required this.prefs,
    required this.weatherRepository,
    required this.authRepository,
    required this.favoritesRepository,
  });

  final SharedPreferences prefs;
  final WeatherRepository weatherRepository;
  final AuthRepository authRepository;
  final FavoritesRepository favoritesRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(favoritesRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => WeatherProvider(
            weatherRepository: weatherRepository,
            favoritesRepository: favoritesRepository,
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'SkyCast',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
