import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/weather_provider.dart';
import '../../widgets/current_weather_card.dart';
import '../../widgets/error_view.dart';
import '../../widgets/forecast_day_tile.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/weather_details_grid.dart';
import '../auth/login_screen.dart';
import '../favorites/favorites_screen.dart';
import '../forecast/forecast_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().initialize();
    });
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width > 900 ? width * 0.12 : (width > 600 ? 32.0 : 16.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        actions: [
          IconButton(
            tooltip: theme.isDark ? 'Light mode' : 'Dark mode',
            onPressed: () => theme.toggleDarkLight(),
            icon: Icon(
              theme.isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Favorites',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
            icon: const Icon(Icons.favorite_rounded),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') _logout();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Text(
                  auth.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.logout_rounded),
                  title: Text('Log out'),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final city = await Navigator.of(context).push<String>(
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          );
          if (city != null && city.isNotEmpty && mounted) {
            await context.read<WeatherProvider>().fetchWeather(city);
          }
        },
        icon: const Icon(Icons.search_rounded),
        label: const Text('Search'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<WeatherProvider>().refresh(),
        child: _buildBody(context, weather, favorites, horizontal),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WeatherProvider weather,
    FavoritesProvider favorites,
    double horizontal,
  ) {
    if (weather.isLoading && !weather.hasData) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 180),
          LoadingIndicator(message: 'Fetching weather…'),
        ],
      );
    }

    if (weather.status == WeatherStatus.error && !weather.hasData) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.55,
            child: ErrorView(
              message: weather.error ?? 'Something went wrong',
              onRetry: () => context.read<WeatherProvider>().refresh(),
            ),
          ),
        ],
      );
    }

    final current = weather.current;
    if (current == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 180),
          LoadingIndicator(message: 'Preparing…'),
        ],
      );
    }

    final days = weather.dailyForecast;
    final preview = days.take(5).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 100),
      children: [
        if (weather.isLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: LinearProgressIndicator(minHeight: 2),
          ),
        if (weather.error != null && weather.hasData)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MaterialBanner(
              content: Text(weather.error!),
              actions: [
                TextButton(
                  onPressed: () =>
                      context.read<WeatherProvider>().clearError(),
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          ),
        CurrentWeatherCard(
          weather: current,
          isFavorite: favorites.isFavorite(current.cityName),
          onToggleFavorite: () async {
            await favorites.toggleFavorite(current.cityName);
            if (!context.mounted) return;
            final added = favorites.isFavorite(current.cityName);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  added
                      ? '${current.cityName} added to favorites'
                      : '${current.cityName} removed from favorites',
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        WeatherDetailsGrid(weather: current),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: Text(
                '7-day forecast',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ForecastScreen()),
                );
              },
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (preview.isEmpty)
          Text(
            'Forecast unavailable',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: preview.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 108,
                  child: ForecastDayTile(
                    day: preview[index],
                    compact: true,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ForecastScreen(),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
