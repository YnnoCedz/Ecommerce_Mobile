class BookProduct {
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

  BookProduct({
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
  factory BookProduct.fromJson(Map<String, dynamic> json) {
    return BookProduct(
      productId: int.parse(json['product_id'].toString()),
      id: int.parse(json['product_id'].toString()),
      name: json['product_name'],
      description: json['description'],
      imagePath: json['image_path'],
      author: json['store_name'],
      price: double.parse(json['price'].toString()),
      rating: double.parse(json['avg_rating'].toString()),
      // ✅ Handle 'books' or 'Books' safely
      category: json['books'] ?? json['Books'] ?? 'Books',
      quantitySold:
          json['total_sold'] != null
              ? int.tryParse(json['total_sold'].toString())
              : null,
      sellerId:
          json['seller_id'] != null
              ? int.parse(json['seller_id'].toString())
              : 0,
    );
  }
}
