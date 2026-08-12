import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/movie_service.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
  });

  @override
  State<MovieDetailsScreen> createState() =>
      _MovieDetailsScreenState();
}

class _MovieDetailsScreenState
    extends State<MovieDetailsScreen> {
  final MovieService _movieService = MovieService();

  Movie? _movie;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final result = await _movieService.getMovieDetails(
        widget.movie.imdbId,
      );

      if (!mounted) return;

      setState(() {
        _movie = result ?? widget.movie;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _movie = widget.movie;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = _movie ?? widget.movie;

    return Scaffold(
      backgroundColor: const Color(0xFF09090D),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.redAccent,
        ),
      )
          : CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildPosterHeader(movie),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                24,
                20,
                40,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _buildTitle(movie),

                  const SizedBox(height: 16),

                  _buildMetaInfo(movie),

                  const SizedBox(height: 30),

                  _buildSectionTitle('Overview'),

                  const SizedBox(height: 10),

                  _buildPlot(movie),

                  const SizedBox(height: 28),

                  _buildSectionTitle('Genre'),

                  const SizedBox(height: 12),

                  _buildGenre(movie),

                  const SizedBox(height: 28),

                  _buildInfoCard(
                    title: 'Director',
                    icon: Icons.movie_creation_outlined,
                    value: movie.director,
                  ),

                  const SizedBox(height: 16),

                  _buildInfoCard(
                    title: 'Cast',
                    icon: Icons.people_outline,
                    value: movie.actors,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterHeader(Movie movie) {
    final hasPoster =
        movie.posterPath.isNotEmpty &&
            movie.posterPath != 'N/A';

    return SliverAppBar(
      expandedHeight: 480,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF09090D),
      foregroundColor: Colors.white,
      title: const Text(
        'Movie Details',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (hasPoster)
              Image.network(
                movie.posterPath,
                fit: BoxFit.cover,
                errorBuilder: (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return _largePosterPlaceholder();
                },
                loadingBuilder: (
                    context,
                    child,
                    loadingProgress,
                    ) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return _largePosterLoading();
                },
              )
            else
              _largePosterPlaceholder(),

            _buildPosterGradient(),
          ],
        ),
      ),
    );
  }

  Widget _buildPosterGradient() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.transparent,
              const Color(0xFF09090D).withOpacity(0.95),
            ],
            stops: const [
              0.0,
              0.45,
              1.0,
            ],
          ),
        ),
      ),
    );
  }

  Widget _largePosterPlaceholder() {
    return Container(
      color: const Color(0xFF17171D),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF25252D),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.movie_outlined,
                color: Colors.grey,
                size: 48,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Poster unavailable',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _largePosterLoading() {
    return Container(
      color: const Color(0xFF17171D),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.redAccent,
        ),
      ),
    );
  }

  Widget _buildTitle(Movie movie) {
    return Text(
      movie.title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 30,
        fontWeight: FontWeight.w800,
        height: 1.15,
      ),
    );
  }

  Widget _buildMetaInfo(Movie movie) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildMetaChip(
          icon: Icons.calendar_today_outlined,
          text: movie.year,
        ),
        _buildRatingChip(movie.rating),
      ],
    );
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF18181F),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.grey.shade500,
            size: 17,
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingChip(double rating) {
    final ratingText =
    rating == 0 ? 'N/A' : rating.toString();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.amber.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: Colors.amber,
            size: 19,
          ),
          const SizedBox(width: 6),
          Text(
            ratingText,
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'IMDb',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPlot(Movie movie) {
    final plot = movie.plot.trim();

    return Text(
      plot.isEmpty || plot == 'N/A'
          ? 'No plot information available.'
          : plot,
      style: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 15,
        height: 1.7,
      ),
    );
  }

  Widget _buildGenre(Movie movie) {
    final genre = movie.genre.trim();

    if (genre.isEmpty || genre == 'N/A') {
      return Text(
        'Not available',
        style: TextStyle(
          color: Colors.grey.shade600,
        ),
      );
    }

    final genres = genre.split(',');

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genres.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.redAccent.withOpacity(0.20),
            ),
          ),
          child: Text(
            item.trim(),
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String value,
  }) {
    final cleanValue = value.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14141A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.redAccent,
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  cleanValue.isEmpty ||
                      cleanValue == 'N/A'
                      ? 'Not available'
                      : cleanValue,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}