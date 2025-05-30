import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../config.dart';

class TopProductService {
  static Future<List<Product>> fetchTopProducts() async {
    final response = await http.get(Uri.parse(Config.topProductsEndpoint));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load top products');
    }
  }
}
