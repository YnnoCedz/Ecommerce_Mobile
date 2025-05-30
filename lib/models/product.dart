class Product {
  final int productId;
  final String name;
  final String imagePath;
  final double price;
  final String? description;
  final int? quantitySold;
  final String? category;
  final String storeName;
  final int sellerId;

  Product({
    required this.productId,
    required this.name,
    required this.imagePath,
    required this.price,
    this.description,
    this.quantitySold,
    this.category,
    required this.storeName,
    required this.sellerId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String? rawCategory = json['category'];
    String? normalizedCategory;

    if (rawCategory != null) {
      switch (rawCategory.toLowerCase().trim()) {
        case 'books':
          normalizedCategory = 'Books';
          break;
        case 'movies':
          normalizedCategory = 'Movies';
          break;
        case 'games':
          normalizedCategory = 'Games';
          break;
        default:
          normalizedCategory = rawCategory.trim();
      }
    }

    return Product(
      productId:
          json['product_id'] != null
              ? int.parse(json['product_id'].toString())
              : 0,
      name: json['product_name'] ?? 'Unknown Title',
      imagePath: json['image_path'] ?? '',
      price:
          json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      description: json['description'],
      quantitySold:
          json['total_sold'] != null
              ? int.tryParse(json['total_sold'].toString())
              : null,
      category: normalizedCategory,
      storeName: json['store_name'] ?? 'Unknown Store',
      sellerId:
          json['seller_id'] != null
              ? int.parse(json['seller_id'].toString())
              : 0,
    );
  }
}
