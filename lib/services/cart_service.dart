import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';
import '../config.dart';

class CartService {
  static Future<Map<String, dynamic>> addToCart({
    required int userId,
    required int productId,
    required int quantity,
  }) async {
    final url = Uri.parse(Config.addToCartEndpoint);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'product_id': productId,
        'quantity': quantity,
      }),
    );

    final data = jsonDecode(response.body);
    return {
      'success': data['status'] == 'success',
      'message': data['message'] ?? 'Something went wrong',
      'cart_id': data['cart_id'],
    };
  }

  static Future<void> updateCartItemQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    final url = Uri.parse(Config.updateCartQuantityEndpoint);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cart_id': cartItemId, 'quantity': quantity}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update cart item');
    }
  }

  static Future<Map<String, dynamic>> buyNowCheckout({
    required int userId,
    required int productId,
    required int quantity,
    required String address,
    String? voucher,
  }) async {
    final url = Uri.parse(Config.buyNowCheckoutEndpoint);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'product_id': productId,
        'quantity': quantity,
        'address': address,
        'voucher': voucher ?? '',
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<int?> fetchProductStock(int productId) async {
    final url = Uri.parse(
      '${Config.productStockEndpoint}?product_id=$productId',
    );
    final response = await http.get(url);
    final data = jsonDecode(response.body);
    return data['status'] == 'success' ? data['stocks'] : null;
  }

  static Future<Map<String, List<CartItem>>> fetchGroupedCart(
    int userId,
  ) async {
    final response = await http.get(
      Uri.parse('${Config.getCartEndpoint}?user_id=$userId'),
    );

    final data = jsonDecode(response.body);

    if (data['status'] == 'success') {
      Map<String, List<CartItem>> groupedCart = {};
      for (var item in data['cart']) {
        final storeName =
            item['shopName'] ?? item['store_name'] ?? 'Unknown Store';
        final category =
            (item['category'] ?? '').toString().toLowerCase().trim();

        groupedCart.putIfAbsent(storeName, () => []);
        groupedCart[storeName]!.add(
          CartItem(
            id: item['id'] ?? item['cart_id'],
            shopName: storeName,
            imageUrl:
                '${Config.imageBaseUrl}/${item['imageUrl'] ?? item['image_path']}',
            title: item['title'] ?? item['product_name'],
            price: double.tryParse(item['price'].toString()) ?? 0,
            quantity: item['quantity'] ?? 1,
            stocks: item['stocks'] ?? 0,
            category: category,
            isSelected: false,
          ),
        );
      }
      return groupedCart;
    }

    throw Exception("Failed to load cart");
  }
}
