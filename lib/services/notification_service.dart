import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class NotificationService {
  static Future<List<Map<String, dynamic>>> fetchUserNotifications(
    int userId,
  ) async {
    final response = await http.get(
      Uri.parse("${Config.baseUrl}/get_notifications.php?user_id=$userId"),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        return List<Map<String, dynamic>>.from(jsonData['notifications']);
      } else {
        throw Exception(jsonData['message']);
      }
    } else {
      throw Exception('Failed to load notifications');
    }
  }
}
