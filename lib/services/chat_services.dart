import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/chat_item.dart';

class ChatService {
  static Future<List<ChatItem>> fetchChats(int userId) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/get_chats.php'),
      body: {'user_id': userId.toString()},
    );

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);
      return jsonData.map((chat) => ChatItem.fromJson(chat)).toList();
    } else {
      throw Exception('Failed to load chats');
    }
  }
}
