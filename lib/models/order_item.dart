class OrderItem {
  final int orderId;
  final int productId;
  final String productName;
  final String imagePath;
  final double totalPrice;
  final int quantity;
  final String orderStatus;
  final String description; // you added this
  final String storeName; // you added this

  OrderItem({
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.imagePath,
    required this.totalPrice,
    required this.quantity,
    required this.orderStatus,
    this.description = '',
    this.storeName = '',
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderId: json['order_id'],
      productId: json['product_id'],
      productName: json['product_name'] ?? '',
      imagePath: json['image_path'] ?? '',
      totalPrice:
          (json['total_price'] == null ||
                  json['total_price'].toString().isEmpty)
              ? 0.0
              : double.tryParse(json['total_price'].toString()) ?? 0.0,
      quantity:
          (json['quantity'] == null || json['quantity'].toString().isEmpty)
              ? 0
              : int.tryParse(json['quantity'].toString()) ?? 0,
      orderStatus: json['order_status'] ?? '',
      description: json['description'] ?? '', // Optional if available
      storeName: json['store_name'] ?? '', // Optional if available
    );
  }
}
