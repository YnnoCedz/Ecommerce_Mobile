import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/user_address.dart';

class EditAddressService {
  static Future<UserAddress?> getUserMainAddress(int userId) async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/get_user_address.php?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return UserAddress.fromJson(data['address']);
      }
    }
    return null;
  }

  static Future<List<UserAddress>> getUserAdditionalAddresses(
    int userId,
  ) async {
    final response = await http.get(
      Uri.parse('${Config.getAdditionalAddressesEndpoint}?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return (data['addresses'] as List)
            .map((json) => UserAddress.fromJson(json))
            .toList();
      }
    }
    return [];
  }

  static Future<bool> deleteUserAddress(int id) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/delete_user_address.php'),
      body: {'id': id.toString()},
    );

    final data = jsonDecode(response.body);
    print('🗑️ Delete response: $data');
    return data['status'] == 'success';
  }

  static Future<bool> updateUserOrAdditionalAddress({
    int? userId,
    int? addressId,
    required String street,
    required String barangay,
    required String city,
    required String province,
    required String zipCode,
  }) async {
    final body = {
      'street': street,
      'barangay': barangay,
      'city': city,
      'province': province,
      'zip_code': zipCode,
    };

    if (userId != null)
      body['user_id'] = userId.toString(); // ✅ only this should be set
    // No addressId for main address update

    final response = await http.post(
      Uri.parse(Config.updateUserAddressEndpoint),
      body: body,
    );

    final data = jsonDecode(response.body);
    print('🔁 Response from update_user_address.php: $data');
    return data['status'] == 'success';
  }

  static Future<bool> addUserAddress({
    required int userId,
    required String street,
    required String barangay,
    required String city,
    required String province,
    required String zipCode,
  }) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/add_user_address.php'),
      body: {
        'user_id': userId.toString(),
        'street': street,
        'barangay': barangay,
        'city': city,
        'province': province,
        'zip_code': zipCode,
      },
    );

    final data = jsonDecode(response.body);
    print('📦 Add Address Response: $data');
    return data['status'] == 'success';
  }
}
