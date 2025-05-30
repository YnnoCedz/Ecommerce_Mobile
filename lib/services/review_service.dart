import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/review.dart';
import '../config.dart';

class ReviewService {
  static Future<List<Review>> fetchReviews(int productId) async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/get_reviews.php?product_id=$productId'),
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => Review.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reviews');
    }
  }
}
