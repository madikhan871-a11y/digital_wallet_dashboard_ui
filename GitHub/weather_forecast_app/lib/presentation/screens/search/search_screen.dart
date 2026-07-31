import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/favorites_provider.dart';
import '../../../providers/weather_provider.dart';
import '../../widgets/city_search_bar.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  bool _searching = false;
  String? _localError;

  static const _suggestions = [
    'London',
    'New York',
    'Tokyo',
    'Paris',
    'Dubai',
    'Sydney',
    'Singapore',
    'Toronto',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search([String? city]) async {
    final query = (city ?? _controller.text).trim();
    if (query.isEmpty) {
      setState(() => _localError = 'Please enter a city name.');
      return;
    }

    setState(() {
      _searching = true;
      _localError = null;
    });

    await context.read<WeatherProvider>().fetchWeather(query);

    if (!mounted) return;

    final weather = context.read<WeatherProvider>();
    setState(() => _searching = false);

    if (weather.status == WeatherStatus.success) {
      Navigator.of(context).pop(weather.activeCity);
    } else {
      setState(() => _localError = weather.error ?? 'Search failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('Search city')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CitySearchBar(
                controller: _controller,
                onSearch: _search,
              ),
              const SizedBox(height: 16),
              if (_searching)
                const Expanded(
                  child: LoadingIndicator(message: 'Searching…'),
                )
              else if (_localError != null)
                Expanded(
                  child: ErrorView(
                    message: _localError!,
                    onRetry: _search,
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    children: [
                      if (favorites.isNotEmpty) ...[
                        Text(
                          'Favorites',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: favorites
                              .map(
                                (city) => ActionChip(
                                  avatar: const Icon(Icons.favorite_rounded, size: 16),
                                  label: Text(city),
                                  onPressed: () => _search(city),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                      Text(
                        'Popular cities',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      ..._suggestions.map(
                        (city) => ListTile(
                          leading: Icon(
                            Icons.location_city_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(city),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onTap: () {
                            _controller.text = city;
                            _search(city);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
