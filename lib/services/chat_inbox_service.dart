import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_inbox_item.dart';
import '../config.dart';

class ChatInboxService {
  static Future<List<ChatInboxItem>> fetchInbox(int userId) async {
    final url = "${Config.getUserChatInboxEndpoint}?user_id=$userId";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body['status'] == 'success') {
        return (body['chats'] as List)
            .map((item) => ChatInboxItem.fromJson(item))
            .toList();
      }
    }
    throw Exception('Failed to load chat inbox');
  }
}
