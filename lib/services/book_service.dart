import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_product.dart';
import '../config.dart';

class BookService {
  static Future<List<BookProduct>> fetchBooks() async {
    final response = await http.get(Uri.parse(Config.booksEndpoint));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((item) => BookProduct.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }
}
