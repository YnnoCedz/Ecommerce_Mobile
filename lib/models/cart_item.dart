// cart_item.dart
class CartItem {
  final int id;
  final String shopName;
  final String imageUrl;
  final String title;
  final double price;
  final String category;
  int quantity;
  bool isSelected;
  int stocks;

  CartItem({
    required this.id,
    required this.shopName,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.quantity,
    this.isSelected = false,
    required this.stocks,
    required this.category,
  });

  /// Factory constructor to create a CartItem from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      shopName: json['shopName'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      isSelected: json['isSelected'] ?? false,
      stocks: json['stocks'],
      category: (json['category'] ?? '').trim(),
    );
  }

  /// Converts a CartItem instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopName': shopName,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'isSelected': isSelected,
      'stocks': stocks,
      'category': category, // ✅ Added missing category
    };
  }
}
