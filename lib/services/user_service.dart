import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../config.dart';

class UserService {
  static Future<User> fetchUser(int userId) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/get_user.php'),
      body: {'user_id': userId.toString()},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  static Future<bool> updateUser({
    required int userId,
    required String firstName,
    required String lastName,
  }) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/update_user.php'),
      body: {
        'user_id': userId.toString(),
        'first_name': firstName,
        'last_name': lastName,
      },
    );

    final data = json.decode(response.body);
    return data['status'] == 'success';
  }

  static Future<bool> updatePrivacy({
    required int userId,
    required String email,
    required String phone,
    String? password,
  }) async {
    final body = {
      'user_id': userId.toString(),
      'email': email,
      'phone_number': phone,
    };

    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }

    final response = await http.post(
      Uri.parse('${Config.baseUrl}/update_user_privacy.php'),
      body: body,
    );

    final data = json.decode(response.body);

    if (data['status'] == 'success') return true;
    throw Exception(
      data['message'] ?? 'Update failed',
    ); // 👈 error message from PHP
  }
}
