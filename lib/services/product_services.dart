import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../config.dart';

class ProductService {
  static Future<List<Product>> fetchProducts(String category) async {
    final response = await http.get(
      Uri.parse('${Config.getProductsByCategory}?category=$category'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<List<Product>> searchProducts(String query) async {
    final url = Uri.parse('${Config.baseUrl}/search_products.php?q=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search products');
    }
  }

  static Future<List<Product>> fetchProductsBySeller({
    int? sellerId,
    int? productId,
  }) async {
    if (sellerId == null && productId == null) {
      throw Exception('Either sellerId or productId must be provided.');
    }

    final query =
        sellerId != null ? '?seller_id=$sellerId' : '?product_id=$productId';

    final url = Uri.parse('${Config.getProductsBySellerEndpoint}$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        return (data['products'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch products');
      }
    } else {
      throw Exception('HTTP error: ${response.statusCode}');
    }
  }

  static Future<List<Product>> fetchBestSellers() async {
    final response = await http.get(Uri.parse(Config.bestSellersEndpoint));

    print('📥 Response Status: ${response.statusCode}');
    print('📄 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load best sellers');
    }
  }

  static Future<List<Product>> fetchNewArrivals() async {
    final response = await http.get(Uri.parse(Config.newArrivalsEndpoint));

    print('📥 Response Status: ${response.statusCode}');
    print('📄 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load best sellers');
    }
  }
}
