import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_product.dart';
import '../config.dart';

class MovieService {
  static Future<List<MovieProduct>> fetchMovies() async {
    final response = await http.get(Uri.parse(Config.moviesEndpoint));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((item) => MovieProduct.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }
}
