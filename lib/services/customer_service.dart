import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config.dart';
import 'package:final_ecommerce/models/chat_message.dart';

class CustomerService {
  static const String adminChatBase = '${Config.baseUrl}/admin';

  // 🔹 Admin: Fetch all chat messages with a specific user
  static Future<List<ChatMessage>> fetchChatWithUser(int userId) async {
    final response = await http.get(Uri.parse('$adminChatBase/chat/$userId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List messages = data['messages'];
      return messages.map((json) => ChatMessage.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chat messages');
    }
  }

  // 🔹 Admin: Send message to user
  static Future<bool> sendAdminMessage({
    required int adminId,
    required int userId,
    required String message,
    File? attachment,
  }) async {
    var uri = Uri.parse(Config.sendChatMessage);
    var request = http.MultipartRequest('POST', uri);
    request.fields['message'] = message;

    if (attachment != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'attachment_url',
          attachment.path,
          contentType: MediaType('image', 'jpeg'), // adjust as needed
        ),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final data = json.decode(responseBody);

    return data['status'] == 'success';
  }

  // 🔹 Admin: Fetch inbox for chat preview
  static Future<List<Map<String, dynamic>>> fetchAdminInbox() async {
    final response = await http.get(
      Uri.parse('$adminChatBase/user_chat_management'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['inbox']);
    } else {
      throw Exception('Failed to load admin inbox');
    }
  }

  // 🔹 User: Fetch all messages between user and admin
  static Future<List<ChatMessage>> fetchChatWithAdmin(int userId) async {
    final response = await http.get(
      Uri.parse('${Config.getChatMessages}?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List messages = data['messages'];
      return messages.map((json) => ChatMessage.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chat messages');
    }
  }

  // 🔹 User: Send message to admin (with optional image)
  static Future<bool> sendUserMessage({
    required int userId,
    required String message,
    File? attachment,
  }) async {
    var uri = Uri.parse('$adminChatBase/chat/$userId');
    var request = http.MultipartRequest('POST', uri);
    request.fields['message'] = message;

    if (attachment != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'attachment_url',
          attachment.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final data = json.decode(responseBody);

    return data['status'] == 'success';
  }
}
