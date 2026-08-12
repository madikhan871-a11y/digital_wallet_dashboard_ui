import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/movie.dart';

class MovieService {
  static const String apiKey = '6929f6bf';

  Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.parse(
      'https://www.omdbapi.com/?apikey=$apiKey&s=${Uri.encodeComponent(query)}',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('API connection failed');
    }

    final data = jsonDecode(response.body);

    if (data['Response'] == 'False') {
      return [];
    }

    final List results = data['Search'] ?? [];

    return results
        .map(
          (item) => Movie.fromSearchJson(
        item as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  Future<Movie?> getMovieDetails(String imdbId) async {
    final url = Uri.parse(
      'https://www.omdbapi.com/?apikey=$apiKey&i=$imdbId&plot=full',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Details API failed');
    }

    final data = jsonDecode(response.body);

    if (data['Response'] == 'True') {
      return Movie.fromDetailsJson(data);
    }

    return null;
  }
}