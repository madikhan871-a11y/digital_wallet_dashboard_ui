class Movie {
  final String imdbId;
  final String title;
  final String posterPath;
  final String year;
  final double rating;
  final String genre;
  final String plot;
  final String director;
  final String actors;

  Movie({
    required this.imdbId,
    required this.title,
    required this.posterPath,
    required this.year,
    required this.rating,
    required this.genre,
    required this.plot,
    required this.director,
    required this.actors,
  });

  factory Movie.fromSearchJson(Map<String, dynamic> json) {
    return Movie(
      imdbId: json['imdbID'] ?? '',
      title: json['Title'] ?? 'Unknown',
      posterPath: json['Poster'] ?? '',
      year: json['Year'] ?? 'Unknown',
      rating: 0.0,
      genre: '',
      plot: '',
      director: '',
      actors: '',
    );
  }

  factory Movie.fromDetailsJson(Map<String, dynamic> json) {
    return Movie(
      imdbId: json['imdbID'] ?? '',
      title: json['Title'] ?? 'Unknown',
      posterPath: json['Poster'] ?? '',
      year: json['Year'] ?? 'Unknown',
      rating: double.tryParse(json['imdbRating'] ?? '0') ?? 0.0,
      genre: json['Genre'] ?? 'Unknown',
      plot: json['Plot'] ?? 'No plot available.',
      director: json['Director'] ?? 'Unknown',
      actors: json['Actors'] ?? 'Unknown',
    );
  }
}