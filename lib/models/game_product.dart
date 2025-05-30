class GameProduct {
  final int id;
  final String name;
  final String description;
  final String imagePath;
  final String author; // store_name
  final double price;
  final double rating;
  final int productId;
  final int? quantitySold;
  final String category;
  final int sellerId;

  GameProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.author,
    required this.price,
    required this.rating,
    required this.productId,
    required this.category,
    this.quantitySold,
    required this.sellerId,
  });

  factory GameProduct.fromJson(Map<String, dynamic> json) {
    return GameProduct(
      productId: int.parse(json['product_id'].toString()),
      id: int.parse(json['product_id'].toString()),
      name: json['product_name'],
      description: json['description'],
      imagePath: json['image_path'],
      author: json['store_name'],
      price: double.parse(json['price'].toString()),
      rating: double.tryParse(json['avg_rating'].toString()) ?? 0.0,
      category: (json['category'] ?? 'Games').toString().trim(), // ✅ Fixed
      quantitySold:
          json['quantity_sold'] != null
              ? int.tryParse(json['quantity_sold'].toString())
              : null,
      sellerId:
          json['seller_id'] != null
              ? int.parse(json['seller_id'].toString())
              : 0,
    );
  }
}
