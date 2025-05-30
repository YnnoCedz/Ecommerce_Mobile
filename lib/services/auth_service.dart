import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class AuthService {
  static Future<bool> registerUser(Map<String, dynamic> userData) async {
    try {
      final res = await http.post(
        Uri.parse(Config.registerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );
      final json = jsonDecode(res.body);
      return json['status'] == 'success';
    } catch (e) {
      print('❌ JSON Decode Error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> loginUser(
    String email,
    String password,
  ) async {
    try {
      final res = await http.post(
        Uri.parse(Config.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final json = jsonDecode(res.body);
      return json['status'] == 'success' ? json['user'] : null;
    } catch (e) {
      print('❌ Login error: $e');
      return null;
    }
  }
}
