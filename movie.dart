class MovieDetails {
  final int id;
  final String title;
  final String releaseYear;
  final double rating;
  final List<String> genres;
  final String director;
  final String details;
  final String imageUrl;

  MovieDetails({
    required this.id,
    required this.title,
    required this.releaseYear,
    required this.rating,
    required this.genres,
    required this.director,
    required this.details,
    required this.imageUrl,
  });
}