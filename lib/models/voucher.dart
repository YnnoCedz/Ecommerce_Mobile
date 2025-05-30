class Voucher {
  final int id;
  final String voucherCode;
  final String description;
  final String category;
  final String voucherImage;

  Voucher({
    required this.id,
    required this.voucherCode,
    required this.description,
    required this.category,
    required this.voucherImage,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'],
      voucherCode: json['voucher_code'],
      description: json['description'],
      category: json['category'],
      voucherImage: json['voucher_image'],
    );
  }
}
