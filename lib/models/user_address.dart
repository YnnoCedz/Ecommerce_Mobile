class UserAddress {
  final int id; // For additional addresses only
  final int userId;
  final String street;
  final String barangay;
  final String city;
  final String province;
  final String zipCode;
  final String createdAt;
  final bool isMain;

  UserAddress({
    required this.id,
    required this.userId,
    required this.street,
    required this.barangay,
    required this.city,
    required this.province,
    required this.zipCode,
    required this.createdAt,
    this.isMain = true,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json.containsKey('id') ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      userId: int.parse(json['user_id'].toString()),
      street: json['street'] ?? '',
      barangay: json['barangay'] ?? '',
      city: json['city'] ?? '',
      province: json['province'] ?? '',
      zipCode: json['zip_code'] ?? '',
      createdAt: json['created_at'] ?? '',
      isMain: json['is_main'].toString() == '1',
    );
  }
}
