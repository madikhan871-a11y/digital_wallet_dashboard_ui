import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/movie_service.dart';
import 'movie_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MovieService _movieService = MovieService();

  List<Movie> _movies = [];
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _searchMovies() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _movies = [];
        _errorMessage = 'Please enter a movie name.';
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _movies = [];
    });

    try {
      final movies = await _movieService.searchMovies(query);

      if (!mounted) return;

      setState(() {
        _movies = movies;
        _isLoading = false;

        if (movies.isEmpty) {
          _errorMessage = 'No movies found for "$query".';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load movies. Please try again.';
      });
    }
  }

  void _openMovieDetails(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(movie: movie),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0F),
        elevation: 0,
        centerTitle: false,
        title: const Row(
          children: [
            Icon(
              Icons.movie_creation_outlined,
              color: Colors.redAccent,
              size: 28,
            ),
            SizedBox(width: 10),
            Text(
              'CineSearch',
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Find your next movie',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Search movies and discover something great.',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 22),

              _buildSearchBar(),

              const SizedBox(height: 24),

              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.redAccent,
                    ),
                  ),
                ),

              if (!_isLoading && _errorMessage != null)
                Expanded(
                  child: Center(
                    child: _buildMessage(),
                  ),
                ),

              if (!_isLoading && _movies.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _movies.length,
                    itemBuilder: (context, index) {
                      return _buildMovieCard(_movies[index]);
                    },
                  ),
                ),

              if (!_isLoading &&
                  _movies.isEmpty &&
                  _errorMessage == null)
                Expanded(
                  child: Center(
                    child: _buildWelcomeMessage(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF17171D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _searchMovies(),
        decoration: InputDecoration(
          hintText: 'Search movies...',
          hintStyle: TextStyle(
            color: Colors.grey.shade600,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade500,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(7),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(11),
              ),
              child: IconButton(
                onPressed: _searchMovies,
                icon: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 17,
            horizontal: 8,
          ),
        ),
      ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () => _openMovieDetails(movie),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF17171D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPoster(movie),

              const SizedBox(width: 14),

              Expanded(
                child: SizedBox(
                  height: 125,
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.grey.shade500,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            movie.year,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'VIEW DETAILS',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade700,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoster(Movie movie) {
    final hasPoster =
        movie.posterPath.isNotEmpty &&
            movie.posterPath != 'N/A';

    if (!hasPoster) {
      return _posterPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        movie.posterPath,
        width: 90,
        height: 125,
        fit: BoxFit.cover,

        // Fix for broken / 404 poster URLs.
        errorBuilder: (context, error, stackTrace) {
          return _posterPlaceholder();
        },

        // Shows a small loading indicator while poster loads.
        loadingBuilder: (
            context,
            child,
            loadingProgress,
            ) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(
            width: 90,
            height: 125,
            color: const Color(0xFF25252D),
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.redAccent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _posterPlaceholder() {
    return Container(
      width: 90,
      height: 125,
      decoration: BoxDecoration(
        color: const Color(0xFF25252D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_outlined,
            color: Colors.grey.shade600,
            size: 36,
          ),
          const SizedBox(height: 6),
          Text(
            'No Poster',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.search_off_rounded,
          color: Colors.grey.shade700,
          size: 65,
        ),
        const SizedBox(height: 15),
        Text(
          _errorMessage!,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeMessage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.local_movies_outlined,
          color: Colors.grey.shade800,
          size: 80,
        ),
        const SizedBox(height: 18),
        const Text(
          'Search for a movie',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Try Batman, Inception, or Interstellar.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}