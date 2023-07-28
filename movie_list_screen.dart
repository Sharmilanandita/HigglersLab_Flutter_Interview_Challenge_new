import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../model/movie.dart';
import 'movie_details_screen.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({Key? key}) : super(key: key);

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {

  Future<List<MovieDetails>> fetchMovies() async {
    final String apiKey = 'a17f9bbdad05467a765b19c128e1cee7';
    final String baseUrl = 'https://api.themoviedb.org/3';
    final String endpoint = '/movie/popular';

    final Uri uri = Uri.parse('$baseUrl$endpoint?api_key=$apiKey');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          final List<dynamic> results = data['results'];

          List<MovieDetails> movies = [];
          for (var movieData in results) {
            final movieId = movieData['id'];
            final movieDetails = await fetchMovieDetails(movieId, apiKey);
            movies.add(movieDetails);

          }
          print(movies[0].title);
          return movies;
      } else {
        Fluttertoast.showToast(msg: "Error, Status code os not equal to 200");
        return [];
      }
    } catch (e) {
      print("Error:: " + e.toString());
      return [];
    }

  }
  Future<MovieDetails> fetchMovieDetails(int movieId, String apiKey) async {
    final String baseUrl = 'https://api.themoviedb.org/3';
    final String endpoint = '/movie/$movieId';
    final String creditsEndpoint = '/movie/$movieId/credits';

    final Uri uri = Uri.parse('$baseUrl$endpoint?api_key=$apiKey');
    final Uri creditsUri = Uri.parse('$baseUrl$creditsEndpoint?api_key=$apiKey');

    final response = await http.get(uri);
    final creditsResponse = await http.get(creditsUri);

    if (response.statusCode == 200 && creditsResponse.statusCode == 200) {
      final Map<String, dynamic> movieData = json.decode(response.body);
      final Map<String, dynamic> creditsData = json.decode(creditsResponse.body);

      final genres = List<String>.from(movieData['genres'].map((genre) => genre['name']));
      final director = creditsData['crew'].firstWhere((person) => person['job'] == 'Director')['name'];

      return MovieDetails(
        id: movieData['id'],
        title: movieData['title'],
        releaseYear: movieData['release_date'],
        rating: movieData['vote_average'],
        genres: genres,
        director: director,
        details: movieData['overview'],
        imageUrl:'https://image.tmdb.org/t/p/w500${movieData['poster_path']}',
      );
    } else {
      throw Exception('Failed to fetch movie details');
    }
  }


  void _navigateToMovieDetails(BuildContext context, MovieDetails movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(movie: movie),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie List'),
      ),
      body: FutureBuilder<List<MovieDetails>>(
        future: fetchMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching movies'));
          } else {
            final movies = snapshot.data;
            return ListView.separated(
              itemCount: movies!.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.purple,
                thickness: 2.0,
              ),
              itemBuilder: (context, index) {
                final movie = movies[index];
                return ListTile(
                  title: Text(
                    movie.title,
                    style: TextStyle(fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[800]),
                  ),
                  subtitle: Text(
                    movie.releaseYear,
                    style: TextStyle(fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  onTap: () {
                    _navigateToMovieDetails(context, movie);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
